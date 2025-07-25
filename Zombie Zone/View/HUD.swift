//
//  HUD.swift
//  Zombie Zone
//
//  Created by Banghua Zhao on 9/21/20.
//  Copyright © 2020 Banghua Zhao. All rights reserved.
//

import Localize_Swift
import SpriteKit

enum HUDSettings {
    static let font = "Noteworthy-Bold"
    static let fontSize: CGFloat = 50
}

enum HUDMessages {
    static let tapToStart = "Tap to Start".localized()
    static let win = "You Win!".localized()
    static let lose = "Out of Time!".localized()
    static let nextLevel = "Tap for Next Level".localized()
    static let playAgain = "Tap to Play Again".localized()
    static let reload = "Continue Previous Game?".localized()
    static let yes = "Yes".localized()
    static let no = "No".localized()
}

class HUD: SKNode {
    var timerLabel: SKLabelNode?
    var zombieCountLabel: SKLabelNode?
    var levelLabel: SKLabelNode?

    override init() {
        super.init()
        name = "HUD"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func add(message: String,
             position: CGPoint,
             fontSize: CGFloat = HUDSettings.fontSize) {
        let label: SKLabelNode
        label = SKLabelNode(fontNamed: HUDSettings.font)
        label.text = message
        label.name = message
        label.zPosition = 100
        addChild(label)
        label.fontSize = fontSize
        label.position = position
    }

    func updateTimer(time: Int) {
        let minutes = (time / 60) % 60
        let seconds = time % 60
        let timeText = String(format: "%02d:%02d", minutes, seconds)
        timerLabel?.text = timeText
    }

    func addTimer(time: Int) {
        guard let scene = scene else { return }

        let position = CGPoint(x: 0,
                               y: scene.frame.height / 2 - 10)
        add(message: "Timer", position: position, fontSize: 24)

        timerLabel = childNode(withName: "Timer") as? SKLabelNode
        timerLabel?.verticalAlignmentMode = .top
        timerLabel?.fontName = "Menlo"
        updateTimer(time: time)
    }

    func addZombieCount(with count: Int) {
        guard let scene = scene else { return }
        let position = CGPoint(x: scene.frame.width / 2 - 30,
                               y: scene.frame.height / 2 - 10)
        add(message: "Zombie Count", position: position, fontSize: 24)
        // 2
        zombieCountLabel = childNode(withName: "Zombie Count") as? SKLabelNode
        zombieCountLabel?.verticalAlignmentMode = .top
        zombieCountLabel?.horizontalAlignmentMode = .right
        zombieCountLabel?.fontName = "Menlo"
        updateZombieCount(with: count)
    }

    func updateZombieCount(with count: Int) {
        zombieCountLabel?.text = "\("Zombies".localized()): \(count)"
    }

    func addLevel(with level: Int) {
        guard let scene = scene else { return }
        let position = CGPoint(x: -scene.frame.width / 2 + 30,
                               y: scene.frame.height / 2 - 10)
        add(message: "Level", position: position, fontSize: 24)
        // 2
        levelLabel = childNode(withName: "Level") as? SKLabelNode
        levelLabel?.verticalAlignmentMode = .top
        levelLabel?.horizontalAlignmentMode = .left
        levelLabel?.fontName = "Menlo"
        levelLabel?.text = "\("Level".localized()): \(level)"
    }

    func updateGameState(from: GameState, to: GameState) {
        clearUI(gameState: from)
        updateUI(gameState: to)
    }

    private func updateUI(gameState: GameState) {
        switch gameState {
        case .start:
            add(message: HUDMessages.tapToStart, position: .zero)
            SKTAudio.sharedInstance().playSoundEffect("首页音乐.mp3")
        case .win:
            add(message: HUDMessages.win, position: .zero)
            add(message: HUDMessages.nextLevel, position: CGPoint(x: 0, y: -100))
            SKTAudio.sharedInstance().playSoundEffect("胜利.mp3")
        case .lose:
            add(message: HUDMessages.lose, position: .zero)
            add(message: HUDMessages.playAgain, position: CGPoint(x: 0, y: -100))
            SKTAudio.sharedInstance().playSoundEffect("失败.mp3")
        case .reload:
            add(message: HUDMessages.reload, position: .zero, fontSize: 40)
            add(message: HUDMessages.yes, position: CGPoint(x: -140, y: -100))
            add(message: HUDMessages.no, position: CGPoint(x: 130, y: -100))
            SKTAudio.sharedInstance().resumeBackgroundMusic()
        case .play:
            SKTAudio.sharedInstance().playSoundEffect("背景音乐.mp3")
        case .pause:
            SKTAudio.sharedInstance().pauseBackgroundMusic()
        default:
            break
        }
    }

    private func clearUI(gameState: GameState) {
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        switch gameState {
        case .start:
            remove(message: HUDMessages.tapToStart)
        case .win:
            remove(message: HUDMessages.win)
            remove(message: HUDMessages.nextLevel)
        case .lose:
            remove(message: HUDMessages.lose)
            remove(message: HUDMessages.playAgain)
        case .reload:
            remove(message: HUDMessages.reload)
            remove(message: HUDMessages.yes)
            remove(message: HUDMessages.no)
        default:
            break
        }
    }

    private func remove(message: String) {
        childNode(withName: message)?.removeFromParent()
    }
}
