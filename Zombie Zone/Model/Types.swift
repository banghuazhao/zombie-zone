//
//  Types.swift
//  Zombie Zone
//
//  Created by Banghua Zhao on 9/19/20.
//  Copyright © 2020 Banghua Zhao. All rights reserved.
//

import Foundation

enum Direction: Int {
    case forward = 0, backward, left, right
}

struct PhysicsCategory {
    static let None: UInt32 = 0b00000
    static let All: UInt32 = 0xFFFFFFFF
    static let Edge: UInt32 = 0b00001
    static let Player: UInt32 = 0b00010
    static let Zombie: UInt32 = 0b00100
    static let FireZombie: UInt32 = 0b01000
    static let Breakable: UInt32 = 0b10000
}

enum GameState: Int {
    case initial = 0, start, play, win, lose, reload, pause
}
