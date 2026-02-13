//
//  KnightsAndCastles.swift
//  Рыцари и Замки — тактическая пошаговая игра
//
//  Created by AI on iPad/Mac
//

import SpriteKit

// MARK: - Менеджер спрайтов
class SpriteManager {
    static let shared = SpriteManager()
    
    // Путь к ресурсам (убедитесь, что он верен для вашей системы)
    let assetsBase = "/Users/lukamarkov/Desktop/Рыцари и Замки/Tiny Swords/Tiny Swords (Free Pack)"
    
    private var textureCache: [String: SKTexture] = [:]
    
    func getTexture(path: String) -> SKTexture? {
        // Добавляем слеш между базовым путем и относительным
        let fullPath = assetsBase + "/" + path
        if let cached = textureCache[fullPath] {
            return cached
        }
        
        if FileManager.default.fileExists(atPath: fullPath) {
            let url = URL(fileURLWithPath: fullPath)
            #if os(macOS)
            if let image = NSImage(contentsOf: url) {
                let texture = SKTexture(image: image)
                textureCache[fullPath] = texture
                return texture
            }
            #else
            if let image = UIImage(contentsOfFile: fullPath) {
                let texture = SKTexture(image: image)
                textureCache[fullPath] = texture
                return texture
            }
            #endif
        }
        return nil
    }
    
    func getUnitFrame(player: Int, unitType: String) -> SKTexture? {
        let color = player == 1 ? "Blue" : "Red"
        var folder = ""
        var fileName = ""
        var frameWidth: CGFloat = 192
        var frameHeight: CGFloat = 192
        
        switch unitType {
        case "knight":
            folder = "Warrior"; fileName = "Warrior_Idle.png"
        case "archer":
            folder = "Archer"; fileName = "Archer_Idle.png"
        case "cavalry":
            folder = "Lancer"; fileName = "Lancer_Idle.png"
            frameWidth = 320; frameHeight = 320
        default: return nil
        }
        
        let path = "Units/\(color) Units/\(folder)/\(fileName)"
        guard let sheet = getTexture(path: path) else { return nil }
        
        let h = sheet.size().height
        let w = sheet.size().width
        // В SpriteKit Y=0 внизу. Верхний ряд кадра: (h - frameHeight) / h
        let sliceRect = CGRect(x: 0, y: (h - frameHeight) / h, width: frameWidth / w, height: frameHeight / h)
        return SKTexture(rect: sliceRect, in: sheet)
    }
    
    func getGroundTexture() -> SKTexture? {
        guard let sheet = getTexture(path: "Terrain/Tileset/Tilemap_color1.png") else { return nil }
        let h = sheet.size().height
        let w = sheet.size().width
        // Трава: x=64, y=0 (в терминах Pygame). В SpriteKit y = (h - 64) / h
        let sliceRect = CGRect(x: 64.0 / w, y: (h - 64.0) / h, width: 64.0 / w, height: 64.0 / h)
        return SKTexture(rect: sliceRect, in: sheet)
    }
    
    func getCastleTexture(player: Int) -> SKTexture? {
        let color = player == 1 ? "Blue" : "Red"
        return getTexture(path: "Buildings/\(color) Buildings/Castle.png")
    }
    
    func getTowerTexture() -> SKTexture? {
        return getTexture(path: "Buildings/Blue Buildings/Tower.png")
    }
    
    func getMonasteryTexture() -> SKTexture? {
        return getTexture(path: "Buildings/Blue Buildings/Monastery.png")
    }
}

// MARK: - Константы
let CELL_SIZE: CGFloat = 48
let COLS = 10
let ROWS = 20
let SIDEBAR_WIDTH: CGFloat = 280
let GAME_WIDTH = CGFloat(COLS) * CELL_SIZE + SIDEBAR_WIDTH
let GAME_HEIGHT = CGFloat(ROWS) * CELL_SIZE
let FPS: TimeInterval = 1.0/30
#if os(macOS)
let MAC_WINDOW_SCALE: CGFloat = 0.9
#endif

// Цвета
let C_BG = SKColor(red: 40/255, green: 30/255, blue: 20/255, alpha: 1)
let C_GRID = SKColor(red: 60/255, green: 50/255, blue: 40/255, alpha: 1)
let C_HIGHLIGHT_MOVE = SKColor(red: 0, green: 200/255, blue: 0, alpha: 0.4)
let C_HIGHLIGHT_ATTACK = SKColor(red: 200/255, green: 0, blue: 0, alpha: 0.4)
let C_HIGHLIGHT_SEL = SKColor(red: 1, green: 1, blue: 0, alpha: 0.47)
let C_SIDEBAR = SKColor(red: 30/255, green: 25/255, blue: 18/255, alpha: 1)
let C_TEXT = SKColor(red: 220/255, green: 210/255, blue: 190/255, alpha: 1)
let C_P1 = SKColor(red: 80/255, green: 140/255, blue: 220/255, alpha: 1)
let C_P2 = SKColor(red: 220/255, green: 60/255, blue: 60/255, alpha: 1)
let C_TOWER = SKColor(red: 100/255, green: 50/255, blue: 150/255, alpha: 1)
let C_RUINS = SKColor(red: 80/255, green: 80/255, blue: 60/255, alpha: 1)
let C_HP = SKColor(red: 0, green: 200/255, blue: 0, alpha: 1)
let C_ARMOR = SKColor(red: 100/255, green: 100/255, blue: 1, alpha: 1)
let C_WHITE = SKColor.white
let C_BLACK = SKColor.black
let C_GOLD = SKColor(red: 1, green: 215/255, blue: 0, alpha: 1)
let C_GRAY = SKColor(red: 120/255, green: 110/255, blue: 90/255, alpha: 1)
let C_LOCKED = SKColor(red: 100/255, green: 80/255, blue: 80/255, alpha: 1)

// MARK: - Артефакты и Рецепты
let ARTIFACT_NAMES = [
    "Трава серебряных",
    "Палочка заклинаний",
    "Трава С.",
    "Посох огня",
    "Волшебная палочка",
    "Солнечные часы",
    "Вода серебряных трав"
]

let ARTIFACT_COLORS: [String: SKColor] = [
    "Трава серебряных": SKColor(red: 180/255, green: 220/255, blue: 180/255, alpha: 1),
    "Палочка заклинаний": SKColor(red: 200/255, green: 180/255, blue: 1, alpha: 1),
    "Трава С.": SKColor(red: 100/255, green: 200/255, blue: 100/255, alpha: 1),
    "Посох огня": SKColor(red: 1, green: 120/255, blue: 50/255, alpha: 1),
    "Волшебная палочка": SKColor(red: 220/255, green: 160/255, blue: 1, alpha: 1),
    "Солнечные часы": SKColor(red: 1, green: 230/255, blue: 100/255, alpha: 1),
    "Вода серебряных трав": SKColor(red: 100/255, green: 180/255, blue: 1, alpha: 1)
]

struct SpellRecipe {
    let name: String
    let desc: String
    let recipe: [String: Int]
}

let SPELL_RECIPES = [
    SpellRecipe(
        name: "Дождь защиты",
        desc: "+2 HP всем своим",
        recipe: ["Трава серебряных": 2, "Палочка заклинаний": 1, "Трава С.": 1]
    ),
    SpellRecipe(
        name: "Сталь свободы",
        desc: "+2 Armor всем своим",
        recipe: ["Посох огня": 1, "Трава серебряных": 1, "Волшебная палочка": 1]
    ),
    SpellRecipe(
        name: "Небо огня",
        desc: "Щит на 1 ход противника",
        recipe: ["Трава С.": 3, "Палочка заклинаний": 1, "Солнечные часы": 1]
    )
]

struct WeaponRecipe {
    let name: String
    let desc: String
    let recipe: [String: Int]
    let stat: String
    let value: Int
    let target: String
}

let WEAPON_RECIPES = [
    WeaponRecipe(
        name: "Солнечный меч",
        desc: "Урон +3 (любому юниту)",
        recipe: ["Посох огня": 1, "Палочка заклинаний": 1, "Солнечные часы": 1],
        stat: "damage",
        value: 3,
        target: "any"
    ),
    WeaponRecipe(
        name: "Синий лук",
        desc: "Урон лучника +2",
        recipe: ["Вода серебряных трав": 1, "Трава С.": 2, "Посох огня": 1, "Палочка заклинаний": 1],
        stat: "damage",
        value: 2,
        target: "archer"
    )
]

func canCraft(inventory: [String: Int], recipe: [String: Int]) -> Bool {
    for (item, count) in recipe {
        if inventory[item, default: 0] < count {
            return false
        }
    }
    return true
}

func spendRecipe(inventory: inout [String: Int], recipe: [String: Int]) {
    for (item, count) in recipe {
        inventory[item, default: 0] -= count
    }
}

// MARK: - Юниты
class Unit {
    let player: Int
    var row: Int
    var col: Int
    var hp: Int
    var maxHp: Int
    var damage: Int
    var armor: Int
    var maxArmor: Int
    let maxMoves: Int
    var movesLeft: Int
    let unitType: String
    var active: Bool
    var done: Bool
    
    init(player: Int, row: Int, col: Int, hp: Int, damage: Int, armor: Int, maxMoves: Int, unitType: String) {
        self.player = player
        self.row = row
        self.col = col
        self.hp = hp
        self.maxHp = hp
        self.damage = damage
        self.armor = armor
        self.maxArmor = armor
        self.maxMoves = maxMoves
        self.movesLeft = 0
        self.unitType = unitType
        self.active = false
        self.done = false
    }
    
    func takeDamage(_ dmg: Int) -> Bool {
        var remainingDmg = dmg
        if armor > 0 {
            let absorbed = min(armor, remainingDmg)
            armor -= absorbed
            remainingDmg -= absorbed
        }
        hp -= remainingDmg
        return hp <= 0
    }
    
    func isAlive() -> Bool {
        return hp > 0
    }
    
    func resetMoves() {
        movesLeft = maxMoves
        done = false
        active = false
    }
}

class Knight: Unit {
    init(player: Int, row: Int, col: Int) {
        super.init(player: player, row: row, col: col, hp: 3, damage: 5, armor: 4, maxMoves: 2, unitType: "knight")
    }
}

class Cavalry: Unit {
    init(player: Int, row: Int, col: Int) {
        super.init(player: player, row: row, col: col, hp: 5, damage: 6, armor: 3, maxMoves: 3, unitType: "cavalry")
    }
}

class Archer: Unit {
    init(player: Int, row: Int, col: Int) {
        super.init(player: player, row: row, col: col, hp: 3, damage: 2, armor: 1, maxMoves: 3, unitType: "archer")
    }
}

// MARK: - Замок
class Castle {
    let player: Int
    let topRow: Int
    let leftCol: Int
    var cells: Set<String>
    
    init(player: Int, topRow: Int, leftCol: Int) {
        self.player = player
        self.topRow = topRow
        self.leftCol = leftCol
        self.cells = Set<String>()
        
        for r in topRow..<topRow+4 {
            for c in leftCol..<leftCol+4 {
                cells.insert("\(r),\(c)")
            }
        }
    }
    
    func contains(row: Int, col: Int) -> Bool {
        return cells.contains("\(row),\(col)")
    }
}

// MARK: - Башня Мага
class MageTower {
    let row: Int
    let col: Int
    var occupant: Unit?
    
    init(row: Int, col: Int) {
        self.row = row
        self.col = col
        self.occupant = nil
    }
    
    func contains(row: Int, col: Int) -> Bool {
        return self.row == row && self.col == col
    }
    
    func castSpell(spellIdx: Int, allUnits: [Unit], inventory: inout [String: Int]) -> String? {
        guard let occupant = occupant else { return nil }
        
        let recipeInfo = SPELL_RECIPES[spellIdx]
        if !canCraft(inventory: inventory, recipe: recipeInfo.recipe) {
            return nil
        }
        
        spendRecipe(inventory: &inventory, recipe: recipeInfo.recipe)
        
        let player = occupant.player
        let name = recipeInfo.name
        
        if spellIdx == 0 { // Дождь защиты
            for u in allUnits {
                if u.player == player && u.isAlive() {
                    u.hp = min(u.hp + 2, u.maxHp + 2)
                }
            }
            return "\(name): +2 HP"
        } else if spellIdx == 1 { // Сталь свободы
            for u in allUnits {
                if u.player == player && u.isAlive() {
                    u.armor = min(u.armor + 2, u.maxArmor + 4)
                }
            }
            return "\(name): +2 Armor"
        } else if spellIdx == 2 { // Небо огня
            return "\(name): Щит активирован"
        }
        
        return nil
    }
}

// MARK: - Руины
class Ruins {
    let topRow: Int
    let leftCol: Int
    var cells: Set<String>
    
    init(topRow: Int, leftCol: Int) {
        self.topRow = topRow
        self.leftCol = leftCol
        self.cells = Set<String>()
        
        for r in topRow..<topRow+2 {
            for c in leftCol..<leftCol+2 {
                cells.insert("\(r),\(c)")
            }
        }
    }
    
    func contains(row: Int, col: Int) -> Bool {
        return cells.contains("\(row),\(col)")
    }
    
    func drawCard() -> String {
        return ARTIFACT_NAMES.randomElement()!
    }
}

// MARK: - Доска
class Board {
    var units: [Unit]
    let castle1: Castle
    let castle2: Castle
    let mageTowers: [MageTower]
    let ruins: Ruins
    
    init() {
        units = []
        castle1 = Castle(player: 1, topRow: 0, leftCol: 3)
        castle2 = Castle(player: 2, topRow: 16, leftCol: 3)
        mageTowers = [
            MageTower(row: 5, col: 3),
            MageTower(row: 5, col: 6),
            MageTower(row: 14, col: 3),
            MageTower(row: 14, col: 6)
        ]
        ruins = Ruins(topRow: 9, leftCol: 4)
        
        // Юниты игрока 1 (верх)
        units.append(Cavalry(player: 1, row: 3, col: 4))
        units.append(Cavalry(player: 1, row: 3, col: 5))
        units.append(Knight(player: 1, row: 1, col: 3))
        units.append(Knight(player: 1, row: 1, col: 6))
        units.append(Knight(player: 1, row: 2, col: 3))
        units.append(Knight(player: 1, row: 2, col: 6))
        units.append(Knight(player: 1, row: 0, col: 3))
        units.append(Archer(player: 1, row: 0, col: 4))
        units.append(Archer(player: 1, row: 0, col: 5))
        units.append(Knight(player: 1, row: 0, col: 6))
        
        // Юниты игрока 2 (низ)
        units.append(Cavalry(player: 2, row: 16, col: 4))
        units.append(Cavalry(player: 2, row: 16, col: 5))
        units.append(Knight(player: 2, row: 17, col: 3))
        units.append(Knight(player: 2, row: 17, col: 6))
        units.append(Knight(player: 2, row: 18, col: 3))
        units.append(Knight(player: 2, row: 18, col: 6))
        units.append(Knight(player: 2, row: 19, col: 3))
        units.append(Archer(player: 2, row: 19, col: 4))
        units.append(Archer(player: 2, row: 19, col: 5))
        units.append(Knight(player: 2, row: 19, col: 6))
    }
    
    func unitAt(row: Int, col: Int) -> Unit? {
        for u in units {
            if u.isAlive() && u.row == row && u.col == col {
                return u
            }
        }
        return nil
    }
    
    func isFree(row: Int, col: Int) -> Bool {
        if row < 0 || row >= ROWS || col < 0 || col >= COLS {
            return false
        }
        return unitAt(row: row, col: col) == nil
    }
    
    func removeDead() {
        units = units.filter { $0.isAlive() }
    }
    
    func playerUnits(_ player: Int) -> [Unit] {
        return units.filter { $0.player == player && $0.isAlive() }
    }
    
    func isInMageTower(row: Int, col: Int) -> MageTower? {
        for mt in mageTowers {
            if mt.contains(row: row, col: col) {
                return mt
            }
        }
        return nil
    }
    
    func isInRuins(row: Int, col: Int) -> Bool {
        return ruins.contains(row: row, col: col)
    }
}

// MARK: - Главная сцена игры
class GameScene: SKScene {
    var board: Board!
    var inventory: [Int: [String: Int]] = [:]
    var currentPlayer = 1
    var unitsActed = 0
    let maxUnitsPerTurn = 3
    var selectedUnit: Unit?
    var moveHighlights: [(Int, Int)] = []
    var attackHighlights: [(Int, Int)] = []
    var jumpTargets: [String: Unit] = [:]
    var moveCosts: [String: Int] = [:]
    var jumpCosts: [String: Int] = [:]
    var gameState = "select"
    var message = "Ход Игрока 1: выберите юнит"
    var popupText: String?
    var popupTimer = 0
    var fireShield: [Int: Bool] = [1: false, 2: false]
    var winner: Int?
    
    // Графические элементы
    var groundLayer: SKNode!
    var structuresLayer: SKNode!
    var highlightsLayer: SKNode!
    var unitsLayer: SKNode!
    var gridLayer: SKNode!
    var sidebarLayer: SKNode!
    var popupLayer: SKNode!
    var sidebarButtons: [(CGRect, () -> Void)] = []
    
    override func didMove(to view: SKView) {
        backgroundColor = C_BG
        setupLayers()
        initializeGame()
        startTurn()
        render()
    }
    
    func setupLayers() {
        groundLayer = SKNode()
        groundLayer.zPosition = -10
        addChild(groundLayer)
        
        highlightsLayer = SKNode()
        highlightsLayer.zPosition = 0
        addChild(highlightsLayer)
        
        structuresLayer = SKNode()
        structuresLayer.zPosition = 10
        addChild(structuresLayer)
        
        unitsLayer = SKNode()
        unitsLayer.zPosition = 20
        addChild(unitsLayer)
        
        gridLayer = SKNode()
        gridLayer.zPosition = 30
        addChild(gridLayer)
        
        sidebarLayer = SKNode()
        sidebarLayer.zPosition = 100
        addChild(sidebarLayer)
        
        popupLayer = SKNode()
        popupLayer.zPosition = 200
        addChild(popupLayer)
    }
    
    func initializeGame() {
        board = Board()
        inventory = [
            1: ARTIFACT_NAMES.reduce(into: [:]) { $0[$1] = 0 },
            2: ARTIFACT_NAMES.reduce(into: [:]) { $0[$1] = 0 }
        ]
        currentPlayer = 1
        unitsActed = 0
        selectedUnit = nil
        gameState = "select"
        winner = nil
    }
    
    // MARK: - Ходы
    func startTurn() {
        unitsActed = 0
        selectedUnit = nil
        gameState = "select"
        for u in board.playerUnits(currentPlayer) {
            u.resetMoves()
        }
        updateMessage()
    }
    
    func endTurn() {
        let enemy = currentPlayer == 1 ? 2 : 1
        if fireShield[currentPlayer] ?? false {
            fireShield[currentPlayer] = false
        }
        currentPlayer = enemy
        startTurn()
        checkWin()
    }
    
    func nextUnit() {
        if let unit = selectedUnit {
            unit.done = true
            unit.active = false
        }
        unitsActed += 1
        selectedUnit = nil
        moveHighlights = []
        attackHighlights = []
        jumpTargets = [:]
        moveCosts = [:]
        jumpCosts = [:]
        
        let alive = board.playerUnits(currentPlayer)
        let maxCan = min(maxUnitsPerTurn, alive.count)
        if unitsActed >= maxCan {
            endTurn()
        } else {
            gameState = "select"
            updateMessage()
        }
    }
    
    func updateMessage() {
        let p = currentPlayer
        let left = min(maxUnitsPerTurn, board.playerUnits(p).count) - unitsActed
        message = "Игрок \(p): выберите юнит (\(left) ост.)"
    }
    
    func showPopup(_ text: String) {
        popupText = text
        popupTimer = 60 // 2 секунды при 30 FPS
    }
    
    // MARK: - Вычисление ходов
    func calcMoves(_ unit: Unit) {
        moveHighlights = []
        attackHighlights = []
        jumpTargets = [:]
        moveCosts = [:]
        jumpCosts = [:]
        
        if unit.movesLeft <= 0 {
            return
        }
        
        if unit.unitType == "archer" {
            calcArcherMoves(unit)
        } else {
            calcMeleeMoves(unit)
        }
    }
    
    func calcMeleeMoves(_ unit: Unit) {
        let r = unit.row
        let c = unit.col
        let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        
        for (dr, dc) in directions {
            let nr = r + dr
            let nc = c + dc
            
            if nr >= 0 && nr < ROWS && nc >= 0 && nc < COLS {
                if let target = board.unitAt(row: nr, col: nc) {
                    if target.player != unit.player {
                        let landR = nr + dr
                        let landC = nc + dc
                        if unit.movesLeft >= 2 && board.isFree(row: landR, col: landC) {
                            attackHighlights.append((landR, landC))
                            jumpTargets["\(landR),\(landC)"] = target
                            jumpCosts["\(landR),\(landC)"] = 2
                        }
                    }
                } else {
                    moveHighlights.append((nr, nc))
                    moveCosts["\(nr),\(nc)"] = 1
                }
            }
        }
    }
    
    func calcArcherMoves(_ unit: Unit) {
        let r = unit.row
        let c = unit.col
        let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        
        // Движение
        for (dr, dc) in directions {
            for dist in 1..<3 {
                if unit.movesLeft < dist {
                    break
                }
                let nr = r + dr * dist
                let nc = c + dc * dist
                
                if !board.isFree(row: nr, col: nc) {
                    break
                }
                
                moveHighlights.append((nr, nc))
                moveCosts["\(nr),\(nc)"] = dist
            }
        }
        
        // Атака
        for (dr, dc) in directions {
            let nr = r + dr
            let nc = c + dc
            
            if nr >= 0 && nr < ROWS && nc >= 0 && nc < COLS {
                if let target = board.unitAt(row: nr, col: nc) {
                    if target.player != unit.player {
                        attackHighlights.append((nr, nc))
                    }
                }
            }
        }
    }
    
    // MARK: - Действия
    func selectUnit(row: Int, col: Int) -> Bool {
        guard let unit = board.unitAt(row: row, col: col) else { return false }
        guard unit.player == currentPlayer && !unit.done else { return false }
        
        selectedUnit = unit
        unit.active = true
        unit.movesLeft = unit.maxMoves
        gameState = "move"
        calcMoves(unit)
        
        if let mt = board.isInMageTower(row: row, col: col) {
            mt.occupant = unit
        }
        
        return true
    }
    
    func moveUnit(row: Int, col: Int) -> Bool {
        guard let unit = selectedUnit else { return false }
        guard moveHighlights.contains(where: { $0.0 == row && $0.1 == col }) else { return false }
        
        let cost = moveCosts["\(row),\(col)"] ?? 1
        guard unit.movesLeft >= cost else { return false }
        
        unit.row = row
        unit.col = col
        unit.movesLeft -= cost
        
        if let mt = board.isInMageTower(row: row, col: col) {
            mt.occupant = unit
        }
        
        if unit.movesLeft <= 0 {
            nextUnit()
        } else {
            calcMoves(unit)
        }
        
        return true
    }
    
    func doJumpAttack(row: Int, col: Int) -> Bool {
        guard let unit = selectedUnit else { return false }
        guard attackHighlights.contains(where: { $0.0 == row && $0.1 == col }) else { return false }
        
        let target = jumpTargets["\(row),\(col)"]
        if target == nil {
            return doArcherShoot(row: row, col: col)
        }
        
        let cost = jumpCosts["\(row),\(col)"] ?? 1
        guard unit.movesLeft >= cost else { return false }
        
        unit.row = row
        unit.col = col
        unit.movesLeft -= cost
        
        if let target = target {
            var dmg = unit.damage
            if fireShield[target.player] ?? false {
                dmg = max(0, dmg - 2)
            }
            _ = target.takeDamage(dmg)
        }
        
        board.removeDead()
        checkWin()
        
        if unit.movesLeft <= 0 {
            nextUnit()
        } else {
            calcMoves(unit)
        }
        
        return true
    }
    
    func doArcherShoot(row: Int, col: Int) -> Bool {
        guard let unit = selectedUnit else { return false }
        guard let target = board.unitAt(row: row, col: col) else { return false }
        guard target.player != unit.player else { return false }
        
        unit.movesLeft -= 1
        
        var dmg = unit.damage
        if fireShield[target.player] ?? false {
            dmg = max(0, dmg - 2)
        }
        _ = target.takeDamage(dmg)
        
        board.removeDead()
        checkWin()
        
        if unit.movesLeft <= 0 {
            nextUnit()
        } else {
            calcMoves(unit)
        }
        
        return true
    }
    
    func tryDrawCard() -> Bool {
        guard let unit = selectedUnit else { return false }
        guard board.isInRuins(row: unit.row, col: unit.col) && unit.movesLeft > 0 else { return false }
        
        let artifact = board.ruins.drawCard()
        inventory[unit.player]![artifact, default: 0] += 1
        unit.movesLeft -= 1
        showPopup("Найден: \(artifact)")
        
        if unit.movesLeft <= 0 {
            nextUnit()
        } else {
            calcMoves(unit)
        }
        
        return true
    }
    
    func tryCastSpell(spellIdx: Int) -> Bool {
        guard let unit = selectedUnit, unit.movesLeft > 0 else { return false }
        guard let mt = board.isInMageTower(row: unit.row, col: unit.col), mt.occupant === unit else { return false }
        
        guard var inv = inventory[unit.player] else { return false }
        let recipeInfo = SPELL_RECIPES[spellIdx]
        
        if !canCraft(inventory: inv, recipe: recipeInfo.recipe) {
            showPopup("Не хватает артефактов!")
            return false
        }
        
        if let result = mt.castSpell(spellIdx: spellIdx, allUnits: board.units, inventory: &inv) {
            inventory[unit.player] = inv
            
            if spellIdx == 2 {
                fireShield[unit.player] = true
            }
            
            unit.movesLeft -= 1
            showPopup(result)
            
            if unit.movesLeft <= 0 {
                nextUnit()
            } else {
                calcMoves(unit)
            }
        }
        
        return true
    }
    
    func tryCraftWeapon(weaponIdx: Int) -> Bool {
        guard let unit = selectedUnit else { return false }
        guard var inv = inventory[unit.player] else { return false }
        
        let w = WEAPON_RECIPES[weaponIdx]
        
        if !canCraft(inventory: inv, recipe: w.recipe) {
            showPopup("Не хватает артефактов!")
            return false
        }
        
        if w.target == "archer" && unit.unitType != "archer" {
            showPopup("Только для лучника!")
            return false
        }
        
        spendRecipe(inventory: &inv, recipe: w.recipe)
        inventory[unit.player] = inv
        
        if w.stat == "damage" {
            unit.damage += w.value
        }
        
        showPopup("\(w.name): +\(w.value) урон")
        return true
    }
    
    func checkWin() {
        if board.playerUnits(1).isEmpty {
            winner = 2
            gameState = "game_over"
            message = "ПОБЕДА ИГРОКА 2!"
        } else if board.playerUnits(2).isEmpty {
            winner = 1
            gameState = "game_over"
            message = "ПОБЕДА ИГРОКА 1!"
        }
    }
    
    func skipUnit() {
        if selectedUnit != nil {
            nextUnit()
        }
    }
    
    // MARK: - Обработка кликов
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        handleClick(at: location)
    }
    
    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        handleClick(at: location)
    }
    #endif
    
    func handleClick(at location: CGPoint) {
        if gameState == "game_over" {
            return
        }
        
        let mx = location.x
        let my = GAME_HEIGHT - location.y
        
        if mx >= CGFloat(COLS) * CELL_SIZE {
            handleSidebarClick(x: mx, y: my)
            return
        }
        
        let col = Int(mx / CELL_SIZE)
        let row = Int(my / CELL_SIZE)
        
        if gameState == "select" {
            _ = selectUnit(row: row, col: col)
        } else if gameState == "move" {
            if attackHighlights.contains(where: { $0.0 == row && $0.1 == col }) {
                if selectedUnit?.unitType == "archer" {
                    if let target = board.unitAt(row: row, col: col), target.player != selectedUnit?.player {
                        _ = doArcherShoot(row: row, col: col)
                    } else {
                        _ = doJumpAttack(row: row, col: col)
                    }
                } else {
                    _ = doJumpAttack(row: row, col: col)
                }
            } else if moveHighlights.contains(where: { $0.0 == row && $0.1 == col }) {
                _ = moveUnit(row: row, col: col)
            } else if let unit = board.unitAt(row: row, col: col),
                      unit.player == currentPlayer,
                      !unit.done {
                if let selected = selectedUnit, selected.movesLeft == selected.maxMoves {
                    selected.active = false
                    _ = selectUnit(row: row, col: col)
                }
            } else if let selected = selectedUnit, selected.movesLeft == selected.maxMoves {
                selected.active = false
                selectedUnit = nil
                moveHighlights = []
                attackHighlights = []
                jumpTargets = [:]
                moveCosts = [:]
                jumpCosts = [:]
                gameState = "select"
            }
        }
        
        render()
    }
    
    func handleSidebarClick(x: CGFloat, y: CGFloat) {
        for (rect, action) in sidebarButtons {
            if rect.contains(CGPoint(x: x, y: y)) {
                action()
                render()
                return
            }
        }
    }
    
    // MARK: - Рендеринг
    func render() {
        drawGround()
        drawStructures()
        drawHighlights()
        drawUnits()
        drawGrid()
        drawSidebar()
        drawPopup()
        
        if gameState == "game_over" {
            drawGameOver()
        }
    }
    
    func drawGround() {
        groundLayer.removeAllChildren()
        
        let groundTexture = SpriteManager.shared.getGroundTexture()
        
        for r in 0..<ROWS {
            for c in 0..<COLS {
                let tile: SKSpriteNode
                if let tex = groundTexture {
                    tile = SKSpriteNode(texture: tex, size: CGSize(width: CELL_SIZE, height: CELL_SIZE))
                } else {
                    let shape = SKShapeNode(rectOf: CGSize(width: CELL_SIZE, height: CELL_SIZE))
                    shape.fillColor = SKColor(red: 60/255, green: 100/255, blue: 40/255, alpha: 1)
                    shape.strokeColor = .clear
                    // Мы не можем просто привести SKShapeNode к SKSpriteNode, 
                    // поэтому создадим SKSpriteNode из "текстуры" этого шейпа или просто используем ноду.
                    // Для простоты, если нет текстуры, используем SKShapeNode.
                    let node = SKNode()
                    shape.position = .zero
                    node.addChild(shape)
                    node.position = CGPoint(
                        x: CGFloat(c) * CELL_SIZE + CELL_SIZE/2,
                        y: GAME_HEIGHT - CGFloat(r) * CELL_SIZE - CELL_SIZE/2
                    )
                    groundLayer.addChild(node)
                    continue
                }
                
                tile.position = CGPoint(
                    x: CGFloat(c) * CELL_SIZE + CELL_SIZE/2,
                    y: GAME_HEIGHT - CGFloat(r) * CELL_SIZE - CELL_SIZE/2
                )
                groundLayer.addChild(tile)
            }
        }
    }
    
    func drawStructures() {
        structuresLayer.removeAllChildren()
        
        // Замок 1
        let c1 = board.castle1
        if let tex = SpriteManager.shared.getCastleTexture(player: 1) {
            let castle = SKSpriteNode(texture: tex, size: CGSize(width: CELL_SIZE * 4, height: CELL_SIZE * 4))
            castle.position = CGPoint(
                x: CGFloat(c1.leftCol) * CELL_SIZE + CELL_SIZE * 2,
                y: GAME_HEIGHT - CGFloat(c1.topRow) * CELL_SIZE - CELL_SIZE * 2
            )
            structuresLayer.addChild(castle)
        } else {
            let castle1Rect = SKShapeNode(rectOf: CGSize(width: CELL_SIZE * 4, height: CELL_SIZE * 4))
            castle1Rect.fillColor = .clear
            castle1Rect.strokeColor = C_P1
            castle1Rect.lineWidth = 3
            castle1Rect.position = CGPoint(
                x: CGFloat(c1.leftCol) * CELL_SIZE + CELL_SIZE * 2,
                y: GAME_HEIGHT - CGFloat(c1.topRow) * CELL_SIZE - CELL_SIZE * 2
            )
            structuresLayer.addChild(castle1Rect)
        }
        
        // Замок 2
        let c2 = board.castle2
        if let tex = SpriteManager.shared.getCastleTexture(player: 2) {
            let castle = SKSpriteNode(texture: tex, size: CGSize(width: CELL_SIZE * 4, height: CELL_SIZE * 4))
            castle.position = CGPoint(
                x: CGFloat(c2.leftCol) * CELL_SIZE + CELL_SIZE * 2,
                y: GAME_HEIGHT - CGFloat(c2.topRow) * CELL_SIZE - CELL_SIZE * 2
            )
            structuresLayer.addChild(castle)
        } else {
            let castle2Rect = SKShapeNode(rectOf: CGSize(width: CELL_SIZE * 4, height: CELL_SIZE * 4))
            castle2Rect.fillColor = .clear
            castle2Rect.strokeColor = C_P2
            castle2Rect.lineWidth = 3
            castle2Rect.position = CGPoint(
                x: CGFloat(c2.leftCol) * CELL_SIZE + CELL_SIZE * 2,
                y: GAME_HEIGHT - CGFloat(c2.topRow) * CELL_SIZE - CELL_SIZE * 2
            )
            structuresLayer.addChild(castle2Rect)
        }
        
        // Башни магов
        let towerTex = SpriteManager.shared.getTowerTexture()
        for mt in board.mageTowers {
            if let tex = towerTex {
                let tower = SKSpriteNode(texture: tex, size: CGSize(width: CELL_SIZE, height: CELL_SIZE))
                tower.position = CGPoint(
                    x: CGFloat(mt.col) * CELL_SIZE + CELL_SIZE/2,
                    y: GAME_HEIGHT - CGFloat(mt.row) * CELL_SIZE - CELL_SIZE/2
                )
                structuresLayer.addChild(tower)
            } else {
                let tower = SKShapeNode(rectOf: CGSize(width: CELL_SIZE, height: CELL_SIZE))
                tower.fillColor = C_TOWER
                tower.strokeColor = .clear
                tower.position = CGPoint(
                    x: CGFloat(mt.col) * CELL_SIZE + CELL_SIZE/2,
                    y: GAME_HEIGHT - CGFloat(mt.row) * CELL_SIZE - CELL_SIZE/2
                )
                structuresLayer.addChild(tower)
                
                let label = SKLabelNode(text: "M")
                label.fontSize = 14
                label.fontColor = C_WHITE
                label.verticalAlignmentMode = .center
                label.position = tower.position
                structuresLayer.addChild(label)
            }
        }
        
        // Руины (Монастырь)
        let ruins = board.ruins
        if let tex = SpriteManager.shared.getMonasteryTexture() {
            let monastery = SKSpriteNode(texture: tex, size: CGSize(width: CELL_SIZE * 2, height: CELL_SIZE * 2))
            monastery.position = CGPoint(
                x: CGFloat(ruins.leftCol) * CELL_SIZE + CELL_SIZE,
                y: GAME_HEIGHT - CGFloat(ruins.topRow) * CELL_SIZE - CELL_SIZE
            )
            structuresLayer.addChild(monastery)
        } else {
            let ruinsRect = SKShapeNode(rectOf: CGSize(width: CELL_SIZE * 2, height: CELL_SIZE * 2))
            ruinsRect.fillColor = C_RUINS
            ruinsRect.strokeColor = .clear
            ruinsRect.position = CGPoint(
                x: CGFloat(ruins.leftCol) * CELL_SIZE + CELL_SIZE,
                y: GAME_HEIGHT - CGFloat(ruins.topRow) * CELL_SIZE - CELL_SIZE
            )
            structuresLayer.addChild(ruinsRect)
        }
    }
    
    func drawHighlights() {
        highlightsLayer.removeAllChildren()
        
        if gameState != "move" {
            return
        }
        
        // Выделение выбранного юнита
        if let unit = selectedUnit {
            let highlight = SKShapeNode(rectOf: CGSize(width: CELL_SIZE, height: CELL_SIZE))
            highlight.fillColor = C_HIGHLIGHT_SEL
            highlight.strokeColor = .clear
            highlight.position = CGPoint(
                x: CGFloat(unit.col) * CELL_SIZE + CELL_SIZE/2,
                y: GAME_HEIGHT - CGFloat(unit.row) * CELL_SIZE - CELL_SIZE/2
            )
            highlightsLayer.addChild(highlight)
        }
        
        // Подсветка возможных ходов
        for (r, c) in moveHighlights {
            let highlight = SKShapeNode(rectOf: CGSize(width: CELL_SIZE, height: CELL_SIZE))
            highlight.fillColor = C_HIGHLIGHT_MOVE
            highlight.strokeColor = .clear
            highlight.position = CGPoint(
                x: CGFloat(c) * CELL_SIZE + CELL_SIZE/2,
                y: GAME_HEIGHT - CGFloat(r) * CELL_SIZE - CELL_SIZE/2
            )
            highlightsLayer.addChild(highlight)
        }
        
        // Подсветка возможных атак
        for (r, c) in attackHighlights {
            let highlight = SKShapeNode(rectOf: CGSize(width: CELL_SIZE, height: CELL_SIZE))
            highlight.fillColor = C_HIGHLIGHT_ATTACK
            highlight.strokeColor = .clear
            highlight.position = CGPoint(
                x: CGFloat(c) * CELL_SIZE + CELL_SIZE/2,
                y: GAME_HEIGHT - CGFloat(r) * CELL_SIZE - CELL_SIZE/2
            )
            highlightsLayer.addChild(highlight)
        }
    }
    
    func drawUnits() {
        unitsLayer.removeAllChildren()
        
        for u in board.units {
            if !u.isAlive() {
                continue
            }
            
            let x = CGFloat(u.col) * CELL_SIZE
            let y = GAME_HEIGHT - CGFloat(u.row) * CELL_SIZE - CELL_SIZE
            
            // Рисуем юнит
            if let tex = SpriteManager.shared.getUnitFrame(player: u.player, unitType: u.unitType) {
                let sprite = SKSpriteNode(texture: tex, size: CGSize(width: CELL_SIZE, height: CELL_SIZE))
                sprite.position = CGPoint(x: x + CELL_SIZE/2, y: y + CELL_SIZE/2)
                unitsLayer.addChild(sprite)
            } else {
                let color = u.player == 1 ? C_P1 : C_P2
                let unitRect = SKShapeNode(rectOf: CGSize(width: CELL_SIZE - 8, height: CELL_SIZE - 8))
                unitRect.fillColor = color
                unitRect.strokeColor = .clear
                unitRect.position = CGPoint(x: x + CELL_SIZE/2, y: y + CELL_SIZE/2)
                unitsLayer.addChild(unitRect)
                
                let typeLabel = SKLabelNode(text: String(u.unitType.prefix(1).uppercased()))
                typeLabel.fontSize = 18
                typeLabel.fontColor = C_WHITE
                typeLabel.verticalAlignmentMode = .center
                typeLabel.position = CGPoint(x: x + CELL_SIZE/2, y: y + CELL_SIZE/2)
                unitsLayer.addChild(typeLabel)
            }
            
            // HP/Armor полоски
            let bw = CELL_SIZE - 4
            let bx = x + 2
            let byHp = y + CELL_SIZE - 10
            
            let mhp = max(CGFloat(u.maxHp), CGFloat(u.hp), 1)
            let hpBar = SKShapeNode(rectOf: CGSize(width: bw, height: 4))
            hpBar.fillColor = C_BLACK
            hpBar.strokeColor = .clear
            hpBar.position = CGPoint(x: bx + bw/2, y: byHp + 2)
            unitsLayer.addChild(hpBar)
            
            let hpFill = SKShapeNode(rectOf: CGSize(width: max(0, bw * CGFloat(u.hp) / mhp), height: 4))
            hpFill.fillColor = C_HP
            hpFill.strokeColor = .clear
            hpFill.position = CGPoint(x: bx + max(0, bw * CGFloat(u.hp) / mhp)/2, y: byHp + 2)
            unitsLayer.addChild(hpFill)
            
            let byAr = byHp - 5
            let mar = max(CGFloat(u.maxArmor), CGFloat(u.armor), 1)
            let arBar = SKShapeNode(rectOf: CGSize(width: bw, height: 4))
            arBar.fillColor = C_BLACK
            arBar.strokeColor = .clear
            arBar.position = CGPoint(x: bx + bw/2, y: byAr + 2)
            unitsLayer.addChild(arBar)
            
            let arFill = SKShapeNode(rectOf: CGSize(width: max(0, bw * CGFloat(u.armor) / mar), height: 4))
            arFill.fillColor = C_ARMOR
            arFill.strokeColor = .clear
            arFill.position = CGPoint(x: bx + max(0, bw * CGFloat(u.armor) / mar)/2, y: byAr + 2)
            unitsLayer.addChild(arFill)
            
            // Активность
            if u.active {
                let border = SKShapeNode(rectOf: CGSize(width: CELL_SIZE, height: CELL_SIZE))
                border.fillColor = .clear
                border.strokeColor = C_GOLD
                border.lineWidth = 2
                border.position = CGPoint(x: x + CELL_SIZE/2, y: y + CELL_SIZE/2)
                unitsLayer.addChild(border)
            }
            
            // Готовность
            if u.done {
                let overlay = SKShapeNode(rectOf: CGSize(width: CELL_SIZE, height: CELL_SIZE))
                overlay.fillColor = SKColor(white: 0, alpha: 0.24)
                overlay.strokeColor = .clear
                overlay.position = CGPoint(x: x + CELL_SIZE/2, y: y + CELL_SIZE/2)
                unitsLayer.addChild(overlay)
            }
        }
    }
    
    func drawGrid() {
        gridLayer.removeAllChildren()
        
        // Горизонтальные линии
        for r in 0...ROWS {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: GAME_HEIGHT - CGFloat(r) * CELL_SIZE))
            path.addLine(to: CGPoint(x: CGFloat(COLS) * CELL_SIZE, y: GAME_HEIGHT - CGFloat(r) * CELL_SIZE))
            
            let line = SKShapeNode(path: path)
            line.strokeColor = C_GRID
            line.lineWidth = 1
            gridLayer.addChild(line)
        }
        
        // Вертикальные линии
        for c in 0...COLS {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: CGFloat(c) * CELL_SIZE, y: 0))
            path.addLine(to: CGPoint(x: CGFloat(c) * CELL_SIZE, y: GAME_HEIGHT))
            
            let line = SKShapeNode(path: path)
            line.strokeColor = C_GRID
            line.lineWidth = 1
            gridLayer.addChild(line)
        }
    }
    
    func drawSidebar() {
        sidebarLayer.removeAllChildren()
        sidebarButtons = []
        
        let sx = CGFloat(COLS) * CELL_SIZE
        let background = SKShapeNode(rectOf: CGSize(width: SIDEBAR_WIDTH, height: GAME_HEIGHT))
        background.fillColor = C_SIDEBAR
        background.strokeColor = .clear
        background.position = CGPoint(x: sx + SIDEBAR_WIDTH/2, y: GAME_HEIGHT/2)
        sidebarLayer.addChild(background)
        
        var y: CGFloat = GAME_HEIGHT - 8
        let pad = sx + 8
        let w = SIDEBAR_WIDTH - 16
        
        // Заголовок
        let color = currentPlayer == 1 ? C_P1 : C_P2
        let title = SKLabelNode(text: "Игрок \(currentPlayer)")
        title.fontSize = 24
        title.fontName = "Arial-BoldMT"
        title.fontColor = color
        title.horizontalAlignmentMode = .left
        title.verticalAlignmentMode = .top
        title.position = CGPoint(x: pad, y: y)
        sidebarLayer.addChild(title)
        y -= 28
        
        // Сообщение
        let messageLabel = SKLabelNode(text: message)
        messageLabel.fontSize = 13
        messageLabel.fontColor = C_TEXT
        messageLabel.horizontalAlignmentMode = .left
        messageLabel.verticalAlignmentMode = .top
        messageLabel.position = CGPoint(x: pad, y: y)
        sidebarLayer.addChild(messageLabel)
        y -= 18
        
        // Счёт
        let p1c = board.playerUnits(1).count
        let p2c = board.playerUnits(2).count
        let scoreLabel = SKLabelNode(text: "P1: \(p1c) | P2: \(p2c)")
        scoreLabel.fontSize = 13
        scoreLabel.fontColor = C_TEXT
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.position = CGPoint(x: pad, y: y)
        sidebarLayer.addChild(scoreLabel)
        y -= 18
        
        // Щиты
        for p in [1, 2] {
            if fireShield[p] ?? false {
                let shieldLabel = SKLabelNode(text: "Щит P\(p) активен")
                shieldLabel.fontSize = 13
                shieldLabel.fontColor = C_GOLD
                shieldLabel.horizontalAlignmentMode = .left
                shieldLabel.verticalAlignmentMode = .top
                shieldLabel.position = CGPoint(x: pad, y: y)
                sidebarLayer.addChild(shieldLabel)
                y -= 16
            }
        }
        
        y -= 5
        
        // Разделитель
        let divider1 = SKShapeNode(rectOf: CGSize(width: w, height: 1))
        divider1.fillColor = C_GRID
        divider1.strokeColor = .clear
        divider1.position = CGPoint(x: pad + w/2, y: y)
        sidebarLayer.addChild(divider1)
        y -= 5
        
        // Артефакты
        guard let inv = inventory[currentPlayer] else { return }
        
        let artifactsTitle = SKLabelNode(text: "Артефакты:")
        artifactsTitle.fontSize = 18
        artifactsTitle.fontName = "Arial-BoldMT"
        artifactsTitle.fontColor = C_GOLD
        artifactsTitle.horizontalAlignmentMode = .left
        artifactsTitle.verticalAlignmentMode = .top
        artifactsTitle.position = CGPoint(x: pad, y: y)
        sidebarLayer.addChild(artifactsTitle)
        y -= 20
        
        for name in ARTIFACT_NAMES {
            let count = inv[name] ?? 0
            let col = count > 0 ? (ARTIFACT_COLORS[name] ?? C_TEXT) : C_GRAY
            
            let artLabel = SKLabelNode(text: "\(name): \(count)")
            artLabel.fontSize = 11
            artLabel.fontColor = col
            artLabel.horizontalAlignmentMode = .left
            artLabel.verticalAlignmentMode = .top
            artLabel.position = CGPoint(x: pad + 4, y: y)
            sidebarLayer.addChild(artLabel)
            y -= 14
        }
        
        y -= 10
        
        // Разделитель
        let divider2 = SKShapeNode(rectOf: CGSize(width: w, height: 1))
        divider2.fillColor = C_GRID
        divider2.strokeColor = .clear
        divider2.position = CGPoint(x: pad + w/2, y: y)
        sidebarLayer.addChild(divider2)
        y -= 5
        
        // Информация о выбранном юните (если есть)
        if selectedUnit != nil {
            drawUnitInfo(at: &y, pad: pad, width: w)
        }
        
        // Кнопка пропуска (внизу)
        let btnY: CGFloat = 90
        let bh: CGFloat = 30
        
        let skipBg = SKShapeNode(rectOf: CGSize(width: w, height: bh), cornerRadius: 4)
        skipBg.fillColor = SKColor(red: 60/255, green: 60/255, blue: 40/255, alpha: 1)
        skipBg.strokeColor = C_TEXT
        skipBg.lineWidth = 1
        skipBg.position = CGPoint(x: pad + w/2, y: btnY + bh/2)
        sidebarLayer.addChild(skipBg)
        
        let skipLabel = SKLabelNode(text: "Пропустить (ПКМ/Space)")
        skipLabel.fontSize = 13
        skipLabel.fontColor = C_TEXT
        skipLabel.verticalAlignmentMode = .center
        skipLabel.position = CGPoint(x: pad + w/2, y: btnY + bh/2)
        sidebarLayer.addChild(skipLabel)
        
        sidebarButtons.append((CGRect(x: pad, y: btnY, width: w, height: bh), { [weak self] in
            self?.skipUnit()
        }))
        
        // Кнопка сдаться
        let btnY2: CGFloat = 50
        
        let surrenderBg = SKShapeNode(rectOf: CGSize(width: w, height: bh), cornerRadius: 4)
        surrenderBg.fillColor = SKColor(red: 80/255, green: 20/255, blue: 20/255, alpha: 1)
        surrenderBg.strokeColor = SKColor(red: 200/255, green: 50/255, blue: 50/255, alpha: 1)
        surrenderBg.lineWidth = 1
        surrenderBg.position = CGPoint(x: pad + w/2, y: btnY2 + bh/2)
        sidebarLayer.addChild(surrenderBg)
        
        let surrenderLabel = SKLabelNode(text: "Сдаться")
        surrenderLabel.fontSize = 13
        surrenderLabel.fontColor = SKColor(red: 200/255, green: 50/255, blue: 50/255, alpha: 1)
        surrenderLabel.verticalAlignmentMode = .center
        surrenderLabel.position = CGPoint(x: pad + w/2, y: btnY2 + bh/2)
        sidebarLayer.addChild(surrenderLabel)
        
        sidebarButtons.append((CGRect(x: pad, y: btnY2, width: w, height: bh), { [weak self] in
            guard let self = self else { return }
            self.winner = self.currentPlayer == 1 ? 2 : 1
            self.gameState = "game_over"
            self.message = "Игрок \(self.currentPlayer) сдался!"
        }))
    }
    
    func drawPopup() {
        popupLayer.removeAllChildren()
        
        if let text = popupText, popupTimer > 0 {
            popupTimer -= 1
            
            let pw: CGFloat = 320
            let ph: CGFloat = 50
            let px = (CGFloat(COLS) * CELL_SIZE - pw) / 2
            let py = (GAME_HEIGHT - ph) / 2
            
            let bg = SKShapeNode(rectOf: CGSize(width: pw, height: ph), cornerRadius: 6)
            bg.fillColor = SKColor(white: 0, alpha: 0.75)
            bg.strokeColor = C_GOLD
            bg.lineWidth = 2
            bg.position = CGPoint(x: px + pw/2, y: py + ph/2)
            popupLayer.addChild(bg)
            
            let label = SKLabelNode(text: text)
            label.fontSize = 18
            label.fontName = "Arial-BoldMT"
            label.fontColor = C_GOLD
            label.verticalAlignmentMode = .center
            label.position = CGPoint(x: px + pw/2, y: py + ph/2)
            popupLayer.addChild(label)
            
            if popupTimer <= 0 {
                popupText = nil
            }
        }
    }
    
    func drawGameOver() {
        let overlay = SKShapeNode(rectOf: CGSize(width: GAME_WIDTH, height: GAME_HEIGHT))
        overlay.fillColor = SKColor(white: 0, alpha: 0.6)
        overlay.strokeColor = .clear
        overlay.position = CGPoint(x: GAME_WIDTH/2, y: GAME_HEIGHT/2)
        overlay.zPosition = 1000
        sidebarLayer.addChild(overlay)
        
        let color = winner == 1 ? C_P1 : C_P2
        let winLabel = SKLabelNode(text: message)
        winLabel.fontSize = 24
        winLabel.fontName = "Arial-BoldMT"
        winLabel.fontColor = color
        winLabel.verticalAlignmentMode = .center
        winLabel.position = CGPoint(x: GAME_WIDTH/2, y: GAME_HEIGHT/2 + 30)
        winLabel.zPosition = 1001
        sidebarLayer.addChild(winLabel)
        
        let restartLabel = SKLabelNode(text: "R = рестарт | ESC = выход")
        restartLabel.fontSize = 13
        restartLabel.fontColor = C_TEXT
        restartLabel.verticalAlignmentMode = .center
        restartLabel.position = CGPoint(x: GAME_WIDTH/2, y: GAME_HEIGHT/2 - 20)
        restartLabel.zPosition = 1001
        sidebarLayer.addChild(restartLabel)
    }
    
    // MARK: - Клавиатура
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // ESC
            NSApplication.shared.terminate(nil)
        } else if event.keyCode == 15 && gameState == "game_over" { // R
            initializeGame()
            startTurn()
            render()
        } else if event.keyCode == 49 { // Space
            skipUnit()
            render()
        }
    }
    
    // MARK: - Update
    override func update(_ currentTime: TimeInterval) {
        if popupTimer > 0 {
            render()
        }
    }
}
