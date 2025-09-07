//
//  InputView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-06.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField: Bool = false

    //track or control which text field is currently has the keyboard
    @FocusState private var isFocused: Bool

    @State private var isPasswordVisible: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Group {
                if isSecureField {
                    HStack {
                        if isPasswordVisible {
                            TextField(placeholder, text: $text)
                                .focused($isFocused)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .tint(Color(.systemGray2))
                        } else {
                            SecureField(placeholder, text: $text)
                                .focused($isFocused)
                                .tint(Color(.systemGray2))
                        }

                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(
                                systemName: isPasswordVisible
                                    ? "eye.slash.fill" : "eye.fill"
                            )
                            .foregroundColor(Color(.systemGray))
                            .font(.system(size: 16))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                } else {
                    TextField(placeholder, text: $text)
                        .focused($isFocused)
                        .keyboardType(
                            title.lowercased().contains("email")
                                ? .emailAddress : .default
                        )
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .tint(Color(.systemGray2))
                }
            }
            .font(.body)
            .foregroundColor(.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isFocused ? Color(.systemGray3) : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            InputView(
                text: .constant(""),
                title: "Email",
                placeholder: "Your email"
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
        .background(Color.white)
        .previewLayout(.sizeThatFits)
    }
}
