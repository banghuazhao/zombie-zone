//
//  GameViewController.swift
//  Zombie Zone
//
//  Created by Banghua Zhao on 9/13/20.
//  Copyright © 2020 Banghua Zhao. All rights reserved.
//

import GameplayKit
import GoogleMobileAds
import SnapKit
import SpriteKit
import UIKit

var bannerView: GADBannerView = {
    let bannerView = GADBannerView()
    bannerView.adUnitID = Constants.bannerAdUnitID
    bannerView.load(GADRequest())
    return bannerView
}()

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "Level1") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .resizeFill

                // Present the scene
                view.presentScene(scene)
            }

            view.ignoresSiblingOrder = true

            #if DEBUG
//                view.showsFPS = true
//                view.showsNodeCount = true
//                view.showsPhysics = true
            #endif
        }

        view.addSubview(bannerView)
        bannerView.rootViewController = self
        bannerView.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
