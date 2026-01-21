//
//  UIComponents.swift
//  SampleGoogleSignin
//
//  Created by Swarn Singh Chauhan on 21/01/26.
//

import SwiftUI

// MARK: - Custom Text Field Style
struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(ThemeColors.secondaryBackground)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(ThemeColors.lightBrown, lineWidth: 1)
            )
    }
}

// MARK: - Secure Input View with Eye Toggle
struct SecureInputView: View {
    var title: String
    @Binding var text: String
    var contentType: UITextContentType = .password
    
    @State private var isSecured: Bool = true
    
    var body: some View {
        HStack {
            Group {
                if isSecured {
                    SecureField(title, text: $text)
                        .textContentType(contentType)
                } else {
                    TextField(title, text: $text)
                        .textContentType(contentType)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
            }
            
            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: isSecured ? "eye.fill" : "eye.slash.fill")
                    .foregroundColor(ThemeColors.primaryBrown)
            }
        }
        .padding()
        .background(ThemeColors.secondaryBackground)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(ThemeColors.lightBrown, lineWidth: 1)
        )
    }
}
