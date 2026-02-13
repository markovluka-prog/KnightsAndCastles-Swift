//
//  SidebarExtensions.swift
//  Дополнительные методы для отрисовки сайдбара
//

import SpriteKit

extension GameScene {
    // Отрисовка информации о юните в сайдбаре
    func drawUnitInfo(at yPos: inout CGFloat, pad: CGFloat, width: CGFloat) {
        guard let u = selectedUnit else { return }
        guard let inv = inventory[currentPlayer] else { return }
        
        let names = ["knight": "Рыцарь", "cavalry": "Конный", "archer": "Лучник"]
        let unitName = SKLabelNode(text: names[u.unitType] ?? "?")
        unitName.fontSize = 18
        unitName.fontName = "Arial-BoldMT"
        unitName.fontColor = C_WHITE
        unitName.horizontalAlignmentMode = .left
        unitName.verticalAlignmentMode = .top
        unitName.position = CGPoint(x: pad, y: yPos)
        sidebarLayer.addChild(unitName)
        yPos -= 20
        
        // HP и Armor
        let hpLabel = SKLabelNode(text: "HP:\(u.hp)/\(u.maxHp) ARM:\(u.armor)/\(u.maxArmor)")
        hpLabel.fontSize = 13
        hpLabel.fontColor = C_TEXT
        hpLabel.horizontalAlignmentMode = .left
        hpLabel.verticalAlignmentMode = .top
        hpLabel.position = CGPoint(x: pad, y: yPos)
        sidebarLayer.addChild(hpLabel)
        yPos -= 16
        
        // Урон и ходы
        let dmgLabel = SKLabelNode(text: "DMG:\(u.damage) Ходы:\(u.movesLeft)/\(u.maxMoves)")
        dmgLabel.fontSize = 13
        dmgLabel.fontColor = C_TEXT
        dmgLabel.horizontalAlignmentMode = .left
        dmgLabel.verticalAlignmentMode = .top
        dmgLabel.position = CGPoint(x: pad, y: yPos)
        sidebarLayer.addChild(dmgLabel)
        yPos -= 16
        yPos -= 5
        
        // Кнопка "Тянуть артефакт"
        if board.isInRuins(row: u.row, col: u.col) && u.movesLeft > 0 {
            let btnH: CGFloat = 30
            
            let drawBg = SKShapeNode(rectOf: CGSize(width: width, height: btnH), cornerRadius: 4)
            drawBg.fillColor = SKColor(red: 80/255, green: 60/255, blue: 30/255, alpha: 1)
            drawBg.strokeColor = C_GOLD
            drawBg.lineWidth = 2
            drawBg.position = CGPoint(x: pad + width/2, y: yPos - btnH/2)
            sidebarLayer.addChild(drawBg)
            
            let drawLabel = SKLabelNode(text: "Тянуть артефакт (1 ход)")
            drawLabel.fontSize = 13
            drawLabel.fontColor = C_GOLD
            drawLabel.verticalAlignmentMode = .center
            drawLabel.position = CGPoint(x: pad + width/2, y: yPos - btnH/2)
            sidebarLayer.addChild(drawLabel)
            
            sidebarButtons.append((CGRect(x: pad, y: yPos - btnH, width: width, height: btnH), { [weak self] in
                _ = self?.tryDrawCard()
            }))
            
            yPos -= btnH + 5
        }
        
        // Заклинания (башня мага)
        if let mt = board.isInMageTower(row: u.row, col: u.col), mt.occupant === u, u.movesLeft > 0 {
            let spellsTitle = SKLabelNode(text: "Заклинания:")
            spellsTitle.fontSize = 18
            spellsTitle.fontName = "Arial-BoldMT"
            spellsTitle.fontColor = SKColor(red: 200/255, green: 150/255, blue: 1, alpha: 1)
            spellsTitle.horizontalAlignmentMode = .left
            spellsTitle.verticalAlignmentMode = .top
            spellsTitle.position = CGPoint(x: pad, y: yPos)
            sidebarLayer.addChild(spellsTitle)
            yPos -= 20
            
            for i in 0..<SPELL_RECIPES.count {
                let sp = SPELL_RECIPES[i]
                let craftable = canCraft(inventory: inv, recipe: sp.recipe)
                let btnH: CGFloat = 42
                
                let bg = craftable ? SKColor(red: 50/255, green: 30/255, blue: 80/255, alpha: 1) 
                                   : SKColor(red: 40/255, green: 30/255, blue: 40/255, alpha: 1)
                let border = craftable ? SKColor(red: 150/255, green: 100/255, blue: 1, alpha: 1) : C_LOCKED
                
                let spellBg = SKShapeNode(rectOf: CGSize(width: width, height: btnH), cornerRadius: 4)
                spellBg.fillColor = bg
                spellBg.strokeColor = border
                spellBg.lineWidth = 2
                spellBg.position = CGPoint(x: pad + width/2, y: yPos - btnH/2)
                sidebarLayer.addChild(spellBg)
                
                let tc = craftable ? SKColor(red: 200/255, green: 150/255, blue: 1, alpha: 1) : C_LOCKED
                
                let spellName = SKLabelNode(text: sp.name)
                spellName.fontSize = 13
                spellName.fontColor = tc
                spellName.horizontalAlignmentMode = .left
                spellName.verticalAlignmentMode = .top
                spellName.position = CGPoint(x: pad + 6, y: yPos - 3)
                sidebarLayer.addChild(spellName)
                
                // Рецепт
                let recipeStr = sp.recipe.map { "\($0.value)x \($0.key)" }.joined(separator: ", ")
                let recipeLabel = SKLabelNode(text: recipeStr)
                recipeLabel.fontSize = 11
                recipeLabel.fontColor = craftable ? C_TEXT : C_GRAY
                recipeLabel.horizontalAlignmentMode = .left
                recipeLabel.verticalAlignmentMode = .top
                recipeLabel.position = CGPoint(x: pad + 6, y: yPos - 17)
                sidebarLayer.addChild(recipeLabel)
                
                // Описание
                let descLabel = SKLabelNode(text: sp.desc)
                descLabel.fontSize = 11
                descLabel.fontColor = craftable ? C_GOLD : C_GRAY
                descLabel.horizontalAlignmentMode = .left
                descLabel.verticalAlignmentMode = .top
                descLabel.position = CGPoint(x: pad + 6, y: yPos - 29)
                sidebarLayer.addChild(descLabel)
                
                if craftable {
                    let idx = i
                    sidebarButtons.append((CGRect(x: pad, y: yPos - btnH, width: width, height: btnH), { [weak self] in
                        _ = self?.tryCastSpell(spellIdx: idx)
                    }))
                }
                
                yPos -= btnH + 3
            }
        }
        
        // Крафт оружия
        let weaponTitle = SKLabelNode(text: "Крафт оружия:")
        weaponTitle.fontSize = 18
        weaponTitle.fontName = "Arial-BoldMT"
        weaponTitle.fontColor = SKColor(red: 1, green: 180/255, blue: 80/255, alpha: 1)
        weaponTitle.horizontalAlignmentMode = .left
        weaponTitle.verticalAlignmentMode = .top
        weaponTitle.position = CGPoint(x: pad, y: yPos)
        sidebarLayer.addChild(weaponTitle)
        yPos -= 20
        
        for i in 0..<WEAPON_RECIPES.count {
            let wp = WEAPON_RECIPES[i]
            let craftable = canCraft(inventory: inv, recipe: wp.recipe)
            let typeOk = wp.target == "any" || wp.target == u.unitType
            let usable = craftable && typeOk
            let btnH: CGFloat = 42
            
            let bg = usable ? SKColor(red: 60/255, green: 50/255, blue: 20/255, alpha: 1)
                            : SKColor(red: 40/255, green: 35/255, blue: 25/255, alpha: 1)
            let border = usable ? SKColor(red: 1, green: 180/255, blue: 80/255, alpha: 1) : C_LOCKED
            
            let wpBg = SKShapeNode(rectOf: CGSize(width: width, height: btnH), cornerRadius: 4)
            wpBg.fillColor = bg
            wpBg.strokeColor = border
            wpBg.lineWidth = 2
            wpBg.position = CGPoint(x: pad + width/2, y: yPos - btnH/2)
            sidebarLayer.addChild(wpBg)
            
            let tc = usable ? SKColor(red: 1, green: 200/255, blue: 100/255, alpha: 1) : C_LOCKED
            
            let wpName = SKLabelNode(text: wp.name)
            wpName.fontSize = 13
            wpName.fontColor = tc
            wpName.horizontalAlignmentMode = .left
            wpName.verticalAlignmentMode = .top
            wpName.position = CGPoint(x: pad + 6, y: yPos - 3)
            sidebarLayer.addChild(wpName)
            
            // Рецепт
            let recipeStr = wp.recipe.map { "\($0.value)x \($0.key)" }.joined(separator: ", ")
            let recipeLabel = SKLabelNode(text: recipeStr)
            recipeLabel.fontSize = 11
            recipeLabel.fontColor = usable ? C_TEXT : C_GRAY
            recipeLabel.horizontalAlignmentMode = .left
            recipeLabel.verticalAlignmentMode = .top
            recipeLabel.position = CGPoint(x: pad + 6, y: yPos - 17)
            sidebarLayer.addChild(recipeLabel)
            
            // Описание
            var descText = wp.desc
            if wp.target == "archer" {
                descText += " [лучник]"
            }
            let descLabel = SKLabelNode(text: descText)
            descLabel.fontSize = 11
            descLabel.fontColor = usable ? C_GOLD : C_GRAY
            descLabel.horizontalAlignmentMode = .left
            descLabel.verticalAlignmentMode = .top
            descLabel.position = CGPoint(x: pad + 6, y: yPos - 29)
            sidebarLayer.addChild(descLabel)
            
            if usable {
                let idx = i
                sidebarButtons.append((CGRect(x: pad, y: yPos - btnH, width: width, height: btnH), { [weak self] in
                    _ = self?.tryCraftWeapon(weaponIdx: idx)
                }))
            }
            
            yPos -= btnH + 3
        }
    }
}
