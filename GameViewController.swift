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

        // Автоматический размер окна под экран
        if let screen = view.window?.screen ?? NSScreen.main {
            let maxH = screen.visibleFrame.height - 40
            let maxW = screen.visibleFrame.width - 40
            let scaleH = maxH / GAME_HEIGHT
            let scaleW = maxW / GAME_WIDTH
            let scale = min(scaleH, scaleW, 1.0)
            view.window?.setContentSize(CGSize(width: GAME_WIDTH * scale, height: GAME_HEIGHT * scale))
        }
        view.window?.title = "Рыцари и Замки"
    }
}
