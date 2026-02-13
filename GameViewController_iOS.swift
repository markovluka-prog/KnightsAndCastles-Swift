//
//  GameViewController_iOS.swift
//  Рыцари и Замки (iOS/iPad)
//

#if os(iOS)
import UIKit
import SpriteKit

class GameViewController_iOS: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Создаём SKView
        let skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(skView)
        
        // Создаём сцену игры
        let scene = GameScene(size: CGSize(width: GAME_WIDTH, height: GAME_HEIGHT))
        scene.scaleMode = .aspectFit
        
        // Настройки SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        // Запускаем сцену
        skView.presentScene(scene)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
}
#endif
