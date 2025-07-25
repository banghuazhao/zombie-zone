//
//  Player.swift
//  Zombie Zone
//
//  Created by Banghua Zhao on 9/16/20.
//  Copyright © 2020 Banghua Zhao. All rights reserved.
//

import SpriteKit

enum PlayerSettring {
    static let speed: CGFloat = 200.0
}

class Player: SKSpriteNode, Animatable {
    var animations: [SKAction] = []
    var hasPill: Bool = false {
        didSet {
            blink(color: .blue, on: hasPill)
            if hasPill {
                physicsBody?.restitution = 0.4
                physicsBody?.linearDamping = 0.2
            } else {
                physicsBody?.restitution = 0.8
                physicsBody?.linearDamping = 0.4
            }
        }
    }

    init() {
        let texture = SKTexture(pixelImageNamed: "player_ft1")
        super.init(texture: texture, color: .white, size: CGSize(width: 32, height: 32))
        name = "Player"
        zPosition = 50

        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.restitution = 0.8
        physicsBody?.linearDamping = 0.4
        physicsBody?.friction = 0.1
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.Player
        physicsBody?.contactTestBitMask = PhysicsCategory.All

        createAnimation(character: "player")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func move(to: CGPoint) {
        let newVelocity = (to - position).normalized() * PlayerSettring.speed
        physicsBody?.velocity = CGVector(point: newVelocity)
        checkDirection()
    }

    func checkDirection() {
        guard let physicsBody = physicsBody else { return }
        let velocity = physicsBody.velocity
        let direction = animationDirection(directionVector: velocity)
        if direction == .left {
            xScale = abs(xScale)
        }
        if direction == .right {
            xScale = -abs(xScale)
        }
        run(animations[direction.rawValue], withKey: "animation")
    }

    func blink(color: SKColor, on: Bool) {
        // 1
        let blinkOff = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2)
        if on {
            let blinkOn = SKAction.colorize(with: color, colorBlendFactor: 0.4, duration: 0.2)
            let blink = SKAction.repeatForever(SKAction.sequence([blinkOn, blinkOff]))
            xScale = xScale < 0 ? -1.2 : 1.2
            yScale = 1.2
            run(blink, withKey: "blink")
        } else { // 3
            xScale = xScale < 0 ? -1.0 : 1.0
            yScale = 1.0
            removeAction(forKey: "blink")
            run(blinkOff)
        }
    }
}
