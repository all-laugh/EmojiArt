//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by Xiao Quan on 5/14/21.
//

import SwiftUI

// This enables us to display an optional image as a view in SwiftUI, in a simple to read manner. 
struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
