#!/bin/bash
# Скрипт для компиляции и запуска Swift-версии игры без Xcode

echo "🏰 Компиляция Swift-версии игры 'Рыцари и Замки'..."

# Переходим в директорию скрипта
cd "$(dirname "$0")"

# Проверяем наличие Swift
if ! command -v swift &> /dev/null; then
    echo "❌ Swift не найден. Установите Xcode Command Line Tools:"
    echo "   xcode-select --install"
    exit 1
fi

echo "✅ Swift найден: $(swift --version | head -n 1)"

# Компилируем игру
echo "🔨 Компиляция..."
swiftc -framework SpriteKit -framework Cocoa \
    Platform.swift \
    AppDelegate.swift \
    KnightsAndCastles.swift \
    SidebarExtensions.swift \
    main.swift \
    -o KnightsAndCastlesGame

if [ $? -eq 0 ]; then
    echo "✅ Компиляция успешна!"
    echo "🎮 Запуск игры..."
    ./KnightsAndCastlesGame
else
    echo "❌ Ошибка компиляции"
    exit 1
fi
