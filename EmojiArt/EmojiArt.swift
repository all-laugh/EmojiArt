//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Xiao Quan on 5/12/21.
//

import Foundation

struct EmojiArt: Codable {
    var backgroundURL: URL?
    var emojis = [Emoji]()
    var selectedEmojis = Set<Emoji>()

    struct Emoji: Identifiable, Codable, Hashable {
        let text: String
        var x: Int
        var y: Int
        var size: Int
        let id: Int
        
        // This ensures that emojis can only be created using this model. So we don't mess up the uniqueEmojiId.
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(json: Data?) {
        if json != nil, let loadedEmojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json!) {
            self = loadedEmojiArt
        } else {
            return nil
        }
    }
    
    init() { }
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiId += 1
        emojis.append( Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId))
    }
    
    mutating func selectEmoji(_ emoji: Emoji) {
        self.selectedEmojis.insert(emoji)
    }
    
    mutating func deselectEmoji(_ emoji: Emoji) {
        self.selectedEmojis.remove(emoji)
    }
    
}
