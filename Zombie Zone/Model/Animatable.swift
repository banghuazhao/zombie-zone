//
//  Animatable.swift
//  Zombie Zone
//
//  Created by Banghua Zhao on 9/19/20.
//  Copyright © 2020 Banghua Zhao. All rights reserved.
//

import SpriteKit

protocol Animatable: class {
    var animations: [SKAction] { get set }
}

extension Animatable {
    func animationDirection(directionVector: CGVector) -> Direction {
        if abs(directionVector.dx) > abs(directionVector.dy) {
            if directionVector.dx < 0 {
                return .left
            } else {
                return .right
            }
        } else {
            if directionVector.dy < 0 {
                return .forward
            } else {
                return .backward
            }
        }
    }

    func createAnimation(character: String) {
        let actionForward: SKAction = SKAction.animate(
            with: [
                SKTexture(imageNamed: "\(character)_ft1"),
                SKTexture(imageNamed: "\(character)_ft2"),
            ],
            timePerFrame: 0.2)
        let actionBackward: SKAction = SKAction.animate(
            with: [
                SKTexture(imageNamed: "\(character)_bk1"),
                SKTexture(imageNamed: "\(character)_bk2"),
            ],
            timePerFrame: 0.2)
        let actionLeft: SKAction = SKAction.animate(
            with: [
                SKTexture(imageNamed: "\(character)_lt1"),
                SKTexture(imageNamed: "\(character)_lt2"),
            ],
            timePerFrame: 0.2)
        let actionRight: SKAction = actionLeft
        animations.append(SKAction.repeat(actionForward, count: 16))
        animations.append(SKAction.repeat(actionBackward, count: 16))
        animations.append(SKAction.repeat(actionLeft, count: 16))
        animations.append(SKAction.repeat(actionRight, count: 16))
    }
}
