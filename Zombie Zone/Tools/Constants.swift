//
//  Constants.swift
//  Zombie Zone
//
//  Created by Banghua Zhao on 6/25/20.
//  Copyright © 2020 Banghua Zhao. All rights reserved.
//

import UIKit

struct Constants {
    static let bannerAdUnitID = Bundle.main.object(forInfoDictionaryKey: "bannerViewAdUnitID") as? String ?? ""
    static let interstitialAdID = Bundle.main.object(forInfoDictionaryKey: "interstitialAdID") as? String ?? ""
}

struct UserDefaultsKeys {
    static let FETCH_COUNT = "FETCH_COUNT"
}

let maxLevel = 8
