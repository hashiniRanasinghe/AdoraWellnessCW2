//
//  AvatarView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-24.
//

import SwiftUI

struct AvatarView: View {
    let imageURL: String?
    let initials: String
    let size: CGFloat
    
    init(imageURL: String? = nil, initials: String, size: CGFloat = 60) {
        self.imageURL = imageURL
        self.initials = initials
        self.size = size
    }
    
    var body: some View {
        AsyncImage(url: URL(string: imageURL ?? "")) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.6),
                            Color.purple.opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Text(initials)
                        .font(.system(size: size * 0.4, weight: .bold))
                        .foregroundColor(.white)
                )
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

// Usage examples - replace your current avatars with:

// Example 1: Replace this:
// Text(user.initials)
//     .font(.title)
//     .fontWeight(.semibold)
//     .foregroundColor(.white)
//     .frame(width: 62, height: 62)
//     .background(Color(.systemGray3))
//     .clipShape(Circle())

// With this:
// AvatarView(initials: user.initials, size: 62)

// Example 2: With image URL:
// AvatarView(imageURL: user.profileImageURL, initials: user.initials, size: 62)

// Example 3: Different sizes:
// AvatarView(initials: "AB", size: 40)  // Small
// AvatarView(initials: "CD", size: 80)  // Large
