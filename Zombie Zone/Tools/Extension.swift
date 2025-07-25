//
//  Extension.swift
//  Zombie Zone
//
//  Created by Banghua Zhao on 9/20/20.
//  Copyright © 2020 Banghua Zhao. All rights reserved.
//

import SpriteKit

extension SKTexture {
    convenience init(pixelImageNamed: String) {
        self.init(imageNamed: pixelImageNamed)
        filteringMode = .nearest
    }
}
