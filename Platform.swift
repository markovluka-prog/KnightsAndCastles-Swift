//
//  Platform.swift
//  Платформо-зависимые импорты и типы
//

#if os(macOS)
import Cocoa
public typealias PlatformColor = NSColor
public typealias PlatformImage = NSImage
#elseif os(iOS)
import UIKit
public typealias PlatformColor = UIColor
public typealias PlatformImage = UIImage
#endif

import SpriteKit

// SKColor уже является кроссплатформенным типом в SpriteKit,
// но если нужны дополнительные утилиты, они могут быть здесь

extension SKColor {
    static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> SKColor {
        return SKColor(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
}
