//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Xiao Quan on 5/12/21.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    static let palette = "🦼💺🪝🪞🏮🇭🇰🇳🇨🙈"
    
    @Published private var emojiArt: EmojiArt {
        didSet {
            UserDefaults.standard.set(emojiArt.json, forKey: savedJSONkey)
        }
    }
    
    @Published private(set) var backgroundImage: UIImage?
    
    private var savedJSONkey = "EmojiArtDocument.Untitled"
    
    init() {
        self.emojiArt = EmojiArt( json: UserDefaults.standard.data(forKey: savedJSONkey)) ?? EmojiArt()
        fetchBackgroundImageData()
    }
    
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis }
    @Published var selectedEmojis = Set<EmojiArt.Emoji>()

    // MARK: - Intents
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func removeEmoji(_ emoji: EmojiArt.Emoji) {
        emojiArt.removeEmoji(emoji)
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    func moveEmojiSelection(by offset: CGSize) {
        for emoji in self.selectedEmojis {
            moveEmoji(emoji, by: offset)
        }
    }
    
    func scaleEmojiForSelection(by scale: CGFloat) {
        for emoji in self.selectedEmojis {
            scaleEmoji(emoji, by: scale)
        }
    }
    
    func selectEmoji(_ emoji: EmojiArt.Emoji) {
        self.selectedEmojis.insert(emoji)
    }
    
    func deselectEmoji(_ emoji: EmojiArt.Emoji) {
        self.selectedEmojis.remove(emoji)
    }
    
    func clearSelection() {
        self.selectedEmojis.removeAll()
    }
    
    func setBackgroundURL(_ url: URL?) {
        emojiArt.backgroundURL = url?.imageURL
        fetchBackgroundImageData()
    }
    
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        if url == self.emojiArt.backgroundURL {
                            self.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y))}
}

