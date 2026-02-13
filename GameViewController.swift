//
//  GameViewController.swift
//  Рыцари и Замки
//

import Cocoa
import SpriteKit

class GameViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Создаём SKView
        let skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.width, .height]
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
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // Устанавливаем размер окна
        let scale = MAC_WINDOW_SCALE
        view.window?.setContentSize(CGSize(width: GAME_WIDTH * scale, height: GAME_HEIGHT * scale))
        view.window?.title = "Рыцари и Замки"
    }
}
