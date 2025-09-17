//
//  Buttons.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-16.
//

import SwiftUI

extension View {
    func primaryButtonStyle(enabled: Bool = true) -> some View {
        self
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                enabled
                    ? Color(red: 0.4, green: 0.3, blue: 0.8)
                    : Color.gray
            )
            .cornerRadius(24)
            .opacity(enabled ? 1.0 : 0.6)
    }

    func secondaryButtonStyle(enabled: Bool = true) -> some View {
        self
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(
                enabled ? Color(red: 0.4, green: 0.3, blue: 0.8) : Color.gray
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                enabled
                    ? Color(red: 0.4, green: 0.3, blue: 0.8).opacity(0.1)
                    : Color.gray.opacity(0.1)
            )
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        enabled
                            ? Color(red: 0.4, green: 0.3, blue: 0.8)
                            : Color.gray,
                        lineWidth: 1
                    )
            )
            .opacity(enabled ? 1.0 : 0.6)
    }
}
