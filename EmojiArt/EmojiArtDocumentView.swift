//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Xiao Quan on 5/12/21.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(EmojiArtDocument.palette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji)
                            .font(Font.system(size: self.defaultEmojiSize))
                            .onDrag { NSItemProvider(object: emoji as NSString) }
                    }
                }
            }
            .padding(.horizontal)
            
            GeometryReader { geometry in
                ZStack {
                    Color.white.overlay(
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(self.zoomScale)
                    )
                    .gesture( self.doubleTap(in: geometry.size) )
    
                    ForEach (self.document.emojis) { emoji in
                        Text(emoji.text)
                            .font(self.font(for: emoji))
                            .position(self.position(for: emoji, in: geometry.size))
                    }
                }
                .clipped()
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    return self.drop(providers: providers, at: location)
                }
            }
        }
    }
    
    @State private var zoomScale: CGFloat = 1.0
    
    private func doubleTap(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                self.zoomToFit(self.document.backgroundImage, in: size)
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let vScale = size.width / image.size.width
            let hScale = size.height / image.size.height
            self.zoomScale = min(vScale, hScale)
        }
    }
    
    private func font (for emoji: EmojiArt.Emoji ) -> Font {
        return Font.system(size: emoji.fontSzie * self.zoomScale)
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = CGPoint(x: emoji.location.x * zoomScale, y: emoji.location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        return location
    }
    
    private func drop(providers:[NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
//            print("dropped url \(url)")
            self.document.setBackgroundURL(url)
        }
        
        if !found {
            found = providers.loadFirstObject(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: defaultEmojiSize)
            }
        }
        
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40
}


