//
//  GameScene.swift
//  SpriteKitApp
//
//  Created by NikoS on 24.05.2023.
//

import SpriteKit
import GameplayKit
import Foundation
import WebKit

protocol WebSceneDelegate: AnyObject {
    func didTapBackButton()
}

enum GameResult {
    case success
    case failure
}

final class GameScene: SKScene, WebSceneDelegate {
    
    private var menuContainer: SKNode!
    private var validArea: SKSpriteNode!
    private var timer: Timer?
    private var startButtonNode: SKSpriteNode!
    private var aimNode: SKSpriteNode!
    private var aimSize: CGSize!
    private var cumulativeNumberOfTouches = 0
    private var timerLabelNode: SKLabelNode!
    private var remainingTime: TimeInterval = Constants.gameTime
    
    private let gameNetworkManager = GameNetworkManager()
    
    var gameResult: GameResult?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        scene?.size = UIScreen.main.bounds.size
        
        setupBackground()
        setupStartButton()
        setupValidArea()
        setupTimer()
        
        showRulesIfNedeed()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self)
        let touchedNode = atPoint(touchLocation)
        
        if touchedNode.isTouched(name: Constants.rulesWindowButtonNodeName) {
            onRulesWindowButtonTouch()
        } else if touchedNode.isTouched(name: Constants.startButtonNodeName) {
            onStartButtonTouch()
        } else if touchedNode.isTouched(name: Constants.gameAimNodeName) {
            onAimTouch()
        }
    }
    
    private func onRulesWindowButtonTouch() {
        hideNode(duration: 0.3, node: menuContainer)
    }
    
    private func onStartButtonTouch() {
        startTimer()
        hideNode(duration: 0, node: startButtonNode)
        setupAim()
    }
    
    private func onAimTouch() {
        cumulativeNumberOfTouches += 1
        switch cumulativeNumberOfTouches {
        case Constants.finishGameTaps :
            onSuccessGameFinished()
        default:
            onGameContinued()
        }
    }
    
    private func onSuccessGameFinished() {
        cumulativeNumberOfTouches = 0
        stopTimer()
        aimNode.removeFromParent()
        gameResult = .success
        navigateToWebView()
    }
    
    private func onGameContinued() {
        let scaleInAction = SKAction.scale(to: 0.5, duration: 0.1)
        let backToNormalAction = SKAction.scale(to: 1, duration: 0.1)
        let sequenceAction = SKAction.sequence([scaleInAction, backToNormalAction])
        
        aimNode.run(sequenceAction)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.setupAimRandomLocation()
        }
    }
    
    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.frame.size
        background.zPosition = -1
        self.addChild(background)
    }
    
    private func setUpRulesPopUpWindow() {
        menuContainer = SKNode()
        menuContainer.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(menuContainer)
        
        let windowSize = CGSize(width: 200, height: 300)
        let window = SKSpriteNode(color: .white, size: windowSize)
        window.zPosition = 5
        
        let rulesLabel = SKLabelNode(text: Constants.gameRules)
        rulesLabel.numberOfLines = 0
        rulesLabel.fontName = Constants.appFont
        rulesLabel.fontSize = 14
        rulesLabel.verticalAlignmentMode = .center
        rulesLabel.horizontalAlignmentMode = .center
        rulesLabel.position = CGPoint(x: 0, y: windowSize.height * 0.1)
        rulesLabel.preferredMaxLayoutWidth = windowSize.width * 0.8
        rulesLabel.fontColor = .black
        window.addChild(rulesLabel)
        
        let button = SKSpriteNode(color: .blue, size: CGSize(width: 100, height: 50))
        button.name = Constants.rulesWindowButtonNodeName
        button.position = CGPoint(x: 0, y: -115)
        window.addChild(button)
        
        let buttonLabel = SKLabelNode(text: Constants.rulesWindowButtonLabelText)
        buttonLabel.fontName = Constants.appFont
        buttonLabel.fontSize = 16
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.horizontalAlignmentMode = .center
        button.addChild(buttonLabel)
        
        menuContainer.addChild(window)
        showNode(duration: 0.3, node: menuContainer)
    }
    
    private func setupValidArea() {
        let areaSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 100)
        let shapeNode = SKShapeNode(rectOf: areaSize)
        shapeNode.strokeColor = .red
        shapeNode.lineWidth = 0.1
        let texture = SKView().texture(from: shapeNode)
        validArea = SKSpriteNode(texture: texture, size: areaSize)
        validArea.position = CGPoint(x: 0, y: -50)
        addChild(validArea)
    }
    
    private func setupRandomLocation() -> CGPoint {
        let minX = validArea.frame.minX + aimSize.width / 2
        let maxX = validArea.frame.maxX - aimSize.width / 2
        let minY = validArea.frame.minY + aimSize.height / 2
        let maxY = validArea.frame.maxY - aimSize.height / 2
        
        let randomX = CGFloat.random(in: minX...maxX)
        let randomY = CGFloat.random(in: minY...maxY)
        
        return CGPoint(x: randomX, y: randomY)
    }
    
    private func setupAim() {
        aimSize = CGSize(width: 64, height: 64)
        let aimShapeNode = SKShapeNode(rectOf: aimSize)
        aimShapeNode.fillColor = .red
        let texture = SKView().texture(from: aimShapeNode)
        aimNode = SKSpriteNode(texture: texture)
        aimNode.zPosition = 1
        aimNode.position = setupRandomLocation()
        aimNode.name = Constants.gameAimNodeName
        addChild(aimNode)
    }
    
    private func setupAimRandomLocation() {
        aimNode.position = setupRandomLocation()
    }
    
    private func setupTimer() {
        timerLabelNode = SKLabelNode(fontNamed: Constants.appFont)
        timerLabelNode.text = String(format: "Time: %.2f", remainingTime)
        timerLabelNode.fontSize = 24
        timerLabelNode.position = CGPoint(x: 0, y: validArea.frame.maxY + 20)
        addChild(timerLabelNode)
    }
    
    private func setupStartButton() {
        startButtonNode = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 50))
        startButtonNode.zPosition = 3
        startButtonNode.position = CGPoint(x: 0, y: 0)
        startButtonNode.name = Constants.startButtonNodeName
        addChild(startButtonNode)
        
        let startButtonLabel = SKLabelNode(fontNamed: Constants.appFont)
        startButtonLabel.text = Constants.startButtonLabelText
        startButtonLabel.fontSize = 24
        startButtonLabel.verticalAlignmentMode = .center
        startButtonLabel.horizontalAlignmentMode = .center
        startButtonNode.addChild(startButtonLabel)
        showNode(duration: 0, node: startButtonNode)
    }
    
    private func showRulesIfNedeed() {
        let hasShownRulesMenu = UserDefaults.standard.bool(forKey: Constants.rulesMenuKey)
        if !hasShownRulesMenu {
            setUpRulesPopUpWindow()
            UserDefaults.standard.set(true, forKey: Constants.rulesMenuKey)
        }
    }
    
    func didTapBackButton() {
        setupStartButton()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 0.01,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc
    private func updateTimer() {
        remainingTime -= 0.01
        
        let formattedTime = String(format: "Time: %.2f", remainingTime)
        timerLabelNode.text = formattedTime
        
        if remainingTime < 0.01 {
            stopTimer()
            cumulativeNumberOfTouches = 0
            aimNode.removeFromParent()
            gameResult = .failure
            navigateToWebView()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        remainingTime = Constants.gameTime
    }
    
    private func showNode(duration: TimeInterval = 0, node: SKNode) {
        let appearAction = SKAction.fadeIn(withDuration: duration)
        node.run(appearAction)
    }
    
    private func hideNode(duration: TimeInterval = 0, node: SKNode) {
        let disappearAction = SKAction.fadeOut(withDuration: duration)
        node.run(disappearAction)
        node.removeFromParent()
    }
    
    private func navigateToWebView() {
        guard let gameResult = gameResult else { return }
        gameNetworkManager.getFinishURL { result in
            if let result {
                let url: String
                switch gameResult {
                case .failure:
                    url = result.loser
                case .success:
                    url = result.winner
                }
                
                DispatchQueue.main.async {
                    self.showWebWindow(url: url)
                }
            }
        }
    }
    
    private func showWebWindow(url: String) {
        guard let url = URL(string: url) else { return }
        
        let webView = WKWebView(frame: UIScreen.main.bounds)
        let request = URLRequest(url: url)
        webView.load(request)
        
        let webViewController = WebViewController()
        webViewController.webSceneDelegate = self
        webViewController.webView = webView
        
        let navigationController = UINavigationController(rootViewController: webViewController)
        navigationController.navigationBar.barStyle = .default
        navigationController.modalPresentationStyle = .fullScreen
        
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                keyWindow.rootViewController?.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    
    
}
