//
//  StoreReviewHelper.swift
//  Zombie Zone
//
//  Created by Banghua Zhao on 12/2/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import Foundation
import StoreKit

let Defaults = UserDefaults.standard

struct StoreReviewHelper {
    static func incrementFetchCount() { // called from appdelegate didfinishLaunchingWithOptions:
        guard var fetchCount = Defaults.value(forKey: UserDefaultsKeys.FETCH_COUNT) as? Int else {
            Defaults.set(1, forKey: UserDefaultsKeys.FETCH_COUNT)
            return
        }
        fetchCount += 1
        Defaults.set(fetchCount, forKey: UserDefaultsKeys.FETCH_COUNT)
    }

    static func checkAndAskForReview() { // call this whenever appropriate
        // this will not be shown everytime. Apple has some internal logic on how to show this.
        guard let fetchCount = Defaults.value(forKey: UserDefaultsKeys.FETCH_COUNT) as? Int else {
            Defaults.set(1, forKey: UserDefaultsKeys.FETCH_COUNT)
            return
        }

        switch fetchCount {
        case 3, 15:
            StoreReviewHelper().requestReview()
        case _ where fetchCount % 100 == 0:
            StoreReviewHelper().requestReview()
        default:
            print("Fetch count is: \(fetchCount)")
            break
        }
    }

    func requestReview() {
        SKStoreReviewController.requestReview()
    }
}
