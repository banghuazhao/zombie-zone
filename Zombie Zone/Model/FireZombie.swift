//
//  FireZombie.swift
//  Zombie Zone
//
//  Created by Banghua Zhao on 9/20/20.
//  Copyright © 2020 Banghua Zhao. All rights reserved.
//

import SpriteKit

class FireZombie: Zombie {
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override init() {
        super.init()
        name = "FireZombie"
        color = .red
        colorBlendFactor = 0.6
        physicsBody?.categoryBitMask = PhysicsCategory.FireZombie
    }
}
