//
//  main.swift
//  Точка входа для запуска игры без Xcode
//

import Cocoa
import SpriteKit

// Создаём приложение
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Создаём окно
let scale = MAC_WINDOW_SCALE
let windowSize = NSSize(width: GAME_WIDTH * scale, height: GAME_HEIGHT * scale)
let window = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height),
    styleMask: [.titled, .closable, .miniaturizable],
    backing: .buffered,
    defer: false
)
window.title = "Рыцари и Замки"
window.center()

// Создаём SKView
let skView = SKView(frame: NSRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height))
window.contentView = skView

// Создаём сцену
let scene = GameScene(size: CGSize(width: GAME_WIDTH, height: GAME_HEIGHT))
scene.scaleMode = .aspectFit

// Настройки SKView
skView.ignoresSiblingOrder = true
skView.showsFPS = false
skView.showsNodeCount = false

// Запускаем сцену
skView.presentScene(scene)

// Показываем окно
window.makeKeyAndOrderFront(nil)

// Запускаем приложение
app.run()
