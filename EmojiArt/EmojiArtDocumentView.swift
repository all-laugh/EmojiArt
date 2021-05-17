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
                            .scaleEffect(self.selectionActive() ? self.steadyStateZoomScale : self.zoomScale)
                            .offset(self.panOffset)
                    )
                    .gesture(
                        self.doubleTapToZoom(in: geometry.size)
                            .exclusively(before: self.singleTapToClearSelection())
                    )
//                    .gesture(self.doubleTapToZoom(in: geometry.size))

                    
                    ForEach (self.document.emojis) { emoji in
                        Text(emoji.text)
                            .font(animatableWithSize: emoji.fontSize * (self.selectionActive()
                                    ? self.selectionZoomScale(for: emoji)
                                    : self.zoomScale ))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(lineWidth: 2)
                                    .opacity( self.document.selectedEmojis.contains(matching: emoji) ? 1 : 0)
                            )

                            .position(self.position(for: emoji, in: geometry.size))
                            .onTapGesture {
                                self.document.selectedEmojis.toggleMatching(emoji)
                            }
                    }
                }
                .clipped()
                .gesture(self.panGesture())
                .gesture(self.zoomGesture())
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
                    location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                    return self.drop(providers: providers, at: location)
                }
            }
        }
    }
    
    @State private var steadyStateZoomScale: CGFloat = 1.0

    @GestureState private var gestureZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScaleOnSelection: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private var selectionZoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScaleOnSelection
    }
    
    private func selectionZoomScale(for emoji: EmojiArt.Emoji) -> CGFloat {
        self.isSelected(emoji) ? selectionZoomScale : zoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        if self.selectionActive() {
            return MagnificationGesture()
                .updating($gestureZoomScaleOnSelection) { latestGestureZoomScale, gestureZoomScaleOnSelection, transaction in
                    gestureZoomScaleOnSelection = latestGestureZoomScale
                }
                .onEnded { finalGestureScale in
                    self.document.scaleEmojiForSelection(by: finalGestureScale)
                }
        } else {
            return MagnificationGesture()
                .updating($gestureZoomScale) { latestGestureZoomScale, gestureZoomScale, transaction in
                    gestureZoomScale = latestGestureZoomScale
                }
                .onEnded { finalGestureScale in
                    self.steadyStateZoomScale *= finalGestureScale
                }
        }

    }
    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestGestureDragValue, gesturePanOffset, transaction in
                gesturePanOffset = latestGestureDragValue.translation / self.zoomScale
            }
            .onEnded { finalPanOffset in
                self.steadyStatePanOffset = self.steadyStatePanOffset + (finalPanOffset.translation / self.zoomScale)
            }
    }
    
    private func singleTapToClearSelection() -> some Gesture {
        TapGesture(count: 1)
            .onEnded { _ in
                self.document.clearSelection()
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded { _ in
                withAnimation {
                    self.zoomToFit(self.document.backgroundImage, in: size)
                }
            }
            
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let vScale = size.width / image.size.width
            let hScale = size.height / image.size.height
            self.steadyStateZoomScale = min(vScale, hScale)
            self.steadyStatePanOffset = .zero
        }
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = CGPoint(x: emoji.location.x * zoomScale, y: emoji.location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + self.panOffset.width, y: location.y + self.panOffset.height)
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
    
    private func selectionActive() -> Bool {
        !self.document.selectedEmojis.isEmpty
    }
    
    private func isSelected(_ emoji: EmojiArt.Emoji) -> Bool {
        self.document.selectedEmojis.contains(matching: emoji)
    }
    
    private let defaultEmojiSize: CGFloat = 40
}


