import SpriteKit

/**
 * Allows you to perform actions with custom timing functions.
 *
 * Unfortunately, SKAction does not have a concept of a timing function, so
 * we need to replicate the actions using SKTEffect subclasses.
 */
class SKTEffect {
    unowned var node: SKNode
    var duration: TimeInterval
    var timingFunction: ((CGFloat) -> CGFloat)?

    init(node: SKNode, duration: TimeInterval) {
        self.node = node
        self.duration = duration
        timingFunction = SKTTimingFunctionLinear
    }

    func update(_ t: CGFloat) {
        // subclasses implement this
    }
}

/**
 * Moves a node from its current position to a new position.
 */
class SKTMoveEffect: SKTEffect {
    var startPosition: CGPoint
    var delta: CGPoint
    var previousPosition: CGPoint

    init(node: SKNode, duration: TimeInterval, startPosition: CGPoint, endPosition: CGPoint) {
        previousPosition = node.position
        self.startPosition = startPosition
        delta = endPosition - startPosition
        super.init(node: node, duration: duration)
    }

    override func update(_ t: CGFloat) {
        // This allows multiple SKTMoveEffect objects to modify the same node
        // at the same time.
        let newPosition = startPosition + delta * t
        let diff = newPosition - previousPosition
        previousPosition = newPosition
        node.position += diff
    }
}

/**
 * Scales a node to a certain scale factor.
 */
class SKTScaleEffect: SKTEffect {
    var startScale: CGPoint
    var delta: CGPoint
    var previousScale: CGPoint

    init(node: SKNode, duration: TimeInterval, startScale: CGPoint, endScale: CGPoint) {
        previousScale = CGPoint(x: node.xScale, y: node.yScale)
        self.startScale = startScale
        delta = endScale - startScale
        super.init(node: node, duration: duration)
    }

    override func update(_ t: CGFloat) {
        let newScale = startScale + delta * t
        let diff = newScale / previousScale
        previousScale = newScale
        node.xScale *= diff.x
        node.yScale *= diff.y
    }
}

/**
 * Rotates a node to a certain angle.
 */
class SKTRotateEffect: SKTEffect {
    var startAngle: CGFloat
    var delta: CGFloat
    var previousAngle: CGFloat

    init(node: SKNode, duration: TimeInterval, startAngle: CGFloat, endAngle: CGFloat) {
        previousAngle = node.zRotation
        self.startAngle = startAngle
        delta = endAngle - startAngle
        super.init(node: node, duration: duration)
    }

    override func update(_ t: CGFloat) {
        let newAngle = startAngle + delta * t
        let diff = newAngle - previousAngle
        previousAngle = newAngle
        node.zRotation += diff
    }
}

/**
 * Wrapper that allows you to use SKTEffect objects as regular SKActions.
 */
extension SKAction {
    class func actionWithEffect(_ effect: SKTEffect) -> SKAction {
        return SKAction.customAction(withDuration: effect.duration) { _, elapsedTime in
            var t = elapsedTime / CGFloat(effect.duration)

            if let timingFunction = effect.timingFunction {
                t = timingFunction(t) // the magic happens here
            }

            effect.update(t)
        }
    }
}
