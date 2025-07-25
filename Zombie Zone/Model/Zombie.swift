//
//  Zombie.swift
//  Zombie Zone
//
//  Created by Banghua Zhao on 9/20/20.
//  Copyright © 2020 Banghua Zhao. All rights reserved.
//

import SpriteKit

enum ZombieSettring {
    static let distance: CGFloat = 16
}

class Zombie: SKSpriteNode, Animatable {
    var animations: [SKAction] = []

    init() {
        let texture = SKTexture(pixelImageNamed: "zombie_ft1")
        super.init(texture: texture, color: .white, size: CGSize(width: 32, height: 32))
        name = "zombie"
        zPosition = 50

        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.restitution = 0.4
        physicsBody?.linearDamping = 0.4
        physicsBody?.friction = 0.1
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.Zombie

        createAnimation(character: "zombie")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func move() {
        let randomX = CGFloat(Int.random(min: -1, max: 1))
        let randomY = CGFloat(Int.random(min: -1, max: 1))
        let vector = CGVector(dx: randomX * ZombieSettring.distance,
                              dy: randomY * ZombieSettring.distance)
        let moveBy = SKAction.move(by: vector, duration: 1)
        let moveAgain = SKAction.run(move)
        let direction = animationDirection(directionVector: vector)
        if direction == .left {
            xScale = abs(xScale)
        } else if direction == .right {
            xScale = -abs(xScale)
        }
        run(animations[direction.rawValue], withKey: "animation")
        run(SKAction.sequence([moveBy, moveAgain]))
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

    func recover() {
        removeAllActions()
        let random = Int.random(min: 1, max: 2)
        texture = SKTexture(pixelImageNamed: "player_ft\(random)")
        physicsBody = nil
        run(SKAction.sequence([SKAction.fadeOut(withDuration: 1),
                               SKAction.removeFromParent()]))
    }
}
