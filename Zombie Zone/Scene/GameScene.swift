//
//  GameScene.swift
//  Zombie Zone
//
//  Created by Banghua Zhao on 9/13/20.
//  Copyright © 2020 Banghua Zhao. All rights reserved.
//

import GameplayKit
import GoogleMobileAds
import SpriteKit

class GameScene: SKScene {
    var interstitial: GADInterstitialAd!
    var background: SKTileMapNode!
    var obstaclesTileMap: SKTileMapNode!
    var pillsTileMap: SKTileMapNode!
    var player = Player()
    let cameraNode = SKCameraNode()
    let zombiesNode = SKNode()
    var hud = HUD()
    var timeLimit: Int = 20
    var elapsedTime: Int = 0
    var startTime: Int?
    var gameState: GameState = .initial {
        didSet {
            hud.updateGameState(from: oldValue, to: gameState)
        }
    }

    var currentLevel: Int = 1
    let recoverZombieSound: SKAction = SKAction.playSoundFileNamed(
        "碰到僵尸.mp3", waitForCompletion: false)
    let touchFireZombieSound: SKAction = SKAction.playSoundFileNamed(
        "碰到红僵尸.mp3", waitForCompletion: false)
    let eatPillSound: SKAction = SKAction.playSoundFileNamed(
        "吃药.mp3", waitForCompletion: false)
    let hitRockSound: SKAction = SKAction.playSoundFileNamed(
        "碰撞岩石.mp3", waitForCompletion: false)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addObservers()
    }

    override func didMove(to view: SKView) {
        if let timeLimit = userData?.object(forKey: "timeLimit") as? Int {
            self.timeLimit = timeLimit
        }
        bannerView.isHidden = false
        gameState = .start
        background = childNode(withName: "background") as? SKTileMapNode
        obstaclesTileMap = childNode(withName: "obstacles") as? SKTileMapNode
        pillsTileMap = childNode(withName: "pills") as? SKTileMapNode
        addChild(player)
        addChild(cameraNode)
        setupCamera()
        setupWorldPhysics()
        createZombies()
        setupObstacles()
        setupPills()
        setupHUD()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        switch gameState {
        // 1
        case .start:
            gameState = .play
            bannerView.isHidden = true
            isPaused = false
            startTime = nil
            elapsedTime = 0
        // 2
        case .play:
            player.move(to: touch.location(in: self))
        case .win:
            transitionToScene(level: currentLevel + 1)
        case .lose:
            GADInterstitialAd.load(withAdUnitID: Constants.interstitialAdID, request: GADRequest()) { ad, error in
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    print("interstitial not ready")
                    self.transitionToScene(level: self.currentLevel)
                    return
                }
                self.interstitial = ad
                self.interstitial.fullScreenContentDelegate = self
                if let ad = self.interstitial, let rootViewController = self.view?.window?.rootViewController {
                    ad.present(fromRootViewController: rootViewController)
                } else {
                    print("interstitial Ad wasn't ready")
                }
            }
        case .reload: // 1
            if let touchedNode =
                atPoint(touch.location(in: self)) as? SKLabelNode {
                // 2
                if touchedNode.name == HUDMessages.yes {
                    isPaused = false
                    startTime = nil
                    gameState = .play
                    // 3
                } else if touchedNode.name == HUDMessages.no {
                    transitionToScene(level: 1)
                }
            }
        default:
            break
        }
    }

    override func update(_ currentTime: TimeInterval) {
        if gameState != .play {
            isPaused = true
            return
        }
        updateHUD(currentTime: currentTime)
        if !player.hasPill {
            updatePills()
        }
        advanceBreakableTile(locatedAt: player.position)
        checkEndGame()
    }

    func setupCamera() {
        camera = cameraNode
        cameraNode.position = CGPoint(x: 0, y: 0)

        let zeroDistance = SKRange(constantValue: 0)
        let playerConstraint = SKConstraint.distance(zeroDistance, to: player)

        let xInset = min(view!.bounds.width / 2 * camera!.xScale,
                         background.frame.width / 2)
        let yInset = min(view!.bounds.height / 2 * camera!.yScale,
                         background.frame.height / 2)

        let constraintRect = background.frame.insetBy(dx: xInset, dy: yInset)
        let xRange = SKRange(lowerLimit: constraintRect.minX, upperLimit: constraintRect.maxX)
        let yRange = SKRange(lowerLimit: constraintRect.minY, upperLimit: constraintRect.maxY)
        let edgeConstraint = SKConstraint.positionX(xRange, y: yRange)
        edgeConstraint.referenceNode = background

        cameraNode.constraints = [playerConstraint, edgeConstraint]
    }

    func setupWorldPhysics() {
        background.physicsBody = SKPhysicsBody(edgeLoopFrom: background.frame)
        background.physicsBody?.categoryBitMask = PhysicsCategory.Edge
        physicsWorld.contactDelegate = self
    }

    func createZombies() {
        guard let zombiesMap = childNode(withName: "zombies") as? SKTileMapNode else { return }
        for row in 0 ..< zombiesMap.numberOfRows {
            for col in 0 ..< zombiesMap.numberOfColumns {
                if let zombieTile = zombiesMap.tileDefinition(atColumn: col, row: row) {
                    let zombie: Zombie
                    if zombieTile.userData?.object(forKey: "fireZombie") != nil {
                        zombie = FireZombie()
                    } else {
                        zombie = Zombie()
                    }
                    zombie.position = zombiesMap.centerOfTile(atColumn: col, row: row)
                    zombie.move()
                    zombiesNode.addChild(zombie)
                }
            }
        }
        zombiesNode.name = "Zombies"
        addChild(zombiesNode)
        zombiesMap.removeFromParent()
    }

    func setupObstacles() {
        for row in 0 ..< obstaclesTileMap.numberOfRows {
            for col in 0 ..< obstaclesTileMap.numberOfColumns {
                guard let obstacleTile = obstaclesTileMap.tileDefinition(atColumn: col, row: row) else { continue }
                guard obstacleTile.userData?.object(forKey: "obstacle") != nil else { continue }
                let node = SKNode()
                node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 32, height: 32))
                node.physicsBody?.isDynamic = false
                node.physicsBody?.friction = 0.1
                node.physicsBody?.categoryBitMask = PhysicsCategory.Breakable
                node.position = obstaclesTileMap.centerOfTile(atColumn: col, row: row)
                obstaclesTileMap.addChild(node)
            }
        }
    }

    func setupPills() {
        pillsTileMap.name = "Pills"
    }

    func updatePills() {
        let col = pillsTileMap.tileColumnIndex(fromPosition: player.position)
        let row = pillsTileMap.tileRowIndex(fromPosition: player.position)
        if pillsTileMap.tileDefinition(atColumn: col, row: row) != nil {
            pillsTileMap.setTileGroup(nil, forColumn: col, row: row)
            player.hasPill = true
            run(eatPillSound)
        }
    }

    func advanceBreakableTile(locatedAt nodePosition: CGPoint) {
        guard let obstaclesTileMap = obstaclesTileMap else { return }
        let col = pillsTileMap.tileColumnIndex(fromPosition: nodePosition)
        let row = pillsTileMap.tileRowIndex(fromPosition: nodePosition)
        let obstacleTile = obstaclesTileMap.tileDefinition(atColumn: col, row: row)
        guard let nextTileGroupName = obstacleTile?.userData?.object(forKey: "breakable") as? String else { return }
        if let nextTileGroup = obstaclesTileMap.tileSet.tileGroups.filter({ $0.name == nextTileGroupName }).first {
            obstaclesTileMap.setTileGroup(nextTileGroup, forColumn: col, row: row)
        }
    }

    func setupHUD() {
        cameraNode.addChild(hud)
        hud.addTimer(time: timeLimit)
        hud.addZombieCount(with: zombiesNode.children.count)
        hud.addLevel(with: currentLevel)
    }

    func updateHUD(currentTime: TimeInterval) {
        // 1
        if let startTime = startTime {
            // 2
            elapsedTime = Int(currentTime) - startTime
        } else {
            // 3
            startTime = Int(currentTime) - elapsedTime
        }
        // 4
        hud.updateTimer(time: timeLimit - elapsedTime)
    }
}

// MARK: - Game State

extension GameScene {
    func checkEndGame() {
        if zombiesNode.children.count == 0 {
            player.physicsBody?.linearDamping = 1
            gameState = .win
        } else if timeLimit - elapsedTime <= 0 {
            player.physicsBody?.linearDamping = 1
            gameState = .lose
        }
    }

    func transitionToScene(level: Int) {
        var nextLevel = level
        if level > maxLevel {
            nextLevel = 1
        }
        guard let newScene = SKScene(fileNamed: "Level\(nextLevel)") as? GameScene else {
            fatalError("Level: \(nextLevel) not found")
        }
        newScene.currentLevel = nextLevel
        view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.5))
    }
}

// MARK: - SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {
    func remove(zombie: Zombie) {
        run(recoverZombieSound)
        zombie.removeFromParent()
        background.addChild(zombie)
        zombie.recover()
        hud.updateZombieCount(with: zombiesNode.children.count)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask ==
            PhysicsCategory.Player ? contact.bodyB : contact.bodyA
        switch other.categoryBitMask {
        case PhysicsCategory.Zombie:
            if let zombie = other.node as? Zombie {
                remove(zombie: zombie)
                hud.updateZombieCount(with: zombiesNode.children.count)
            }
        case PhysicsCategory.FireZombie:
            if player.hasPill {
                if let fireZombie = other.node as? FireZombie {
                    remove(zombie: fireZombie)
                    player.hasPill = false
                }
            } else {
                run(touchFireZombieSound)
            }
        case PhysicsCategory.Breakable:
            if let obstacleNode = other.node {
                run(hitRockSound)
                // 1
                advanceBreakableTile(locatedAt: obstacleNode.position)
                // 2
                obstacleNode.removeFromParent()
            }
        default:
            break
        }

        if let physicsBody = player.physicsBody {
            if physicsBody.velocity.length() > 0 {
                player.checkDirection()
            }
        }
    }
}

// MARK: - Notifications

extension GameScene {
    func addObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] _ in
            self?.applicationDidBecomeActive()
        }
        notificationCenter.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { [weak self] _ in
            self?.applicationWillResignActive()
        }
        notificationCenter.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self] _ in
            self?.applicationDidEnterBackground()
        }
    }

    func applicationDidBecomeActive() {
        print("* applicationDidBecomeActive")
        if gameState == .pause {
            gameState = .reload
        }
    }

    func applicationWillResignActive() {
        print("* applicationWillResignActive")
        if gameState != .lose {
            gameState = .pause
        }
    }

    func applicationDidEnterBackground() {
        print("* applicationDidEnterBackground")
    }
}

// MARK: - GADFullScreenContentDelegate

extension GameScene: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("interstitialDidDismissScreen")
        transitionToScene(level: currentLevel)
    }
}
