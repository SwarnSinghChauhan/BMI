//
//  SignUpView.swift
//  SampleGoogleSignin
//
//  Created by Swarn Singh Chauhan on 21/01/26.
//

import SwiftUI
import Supabase

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 70))
                        .foregroundColor(ThemeColors.primaryBrown)
                    
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(ThemeColors.primaryBrown)
                    
                    Text("Join us to track your health journey")
                        .font(.subheadline)
                        .foregroundColor(ThemeColors.textSecondary)
                }
                .padding(.top, 40)
                .padding(.bottom, 20)
                
                // Form Section
                VStack(spacing: 20) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(ThemeColors.textPrimary)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(RoundedTextFieldStyle())
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(ThemeColors.textPrimary)
                        
                        SecureInputView(title: "Enter your password", text: $password, contentType: .newPassword)
                        
                        Text("At least 8 characters with letters and numbers")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Confirm Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(ThemeColors.textPrimary)
                        
                        SecureInputView(title: "Confirm your password", text: $confirmPassword, contentType: .newPassword)
                    }
                    
                    // Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    // Sign Up Button
                    Button {
                        Task {
                            await signUp()
                        }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign Up")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ThemeColors.primaryBrown)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isLoading)
                }
                .padding(.horizontal, 30)
                
                // Sign In Link
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                    Button("Sign In") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.primaryBrown)
                }
                .font(.subheadline)
                .padding(.top, 10)
                
                Spacer()
            }
        }
        .background(ThemeColors.background)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Sign Up Function
    func signUp() async {
        errorMessage = nil
        
        // Validate email
        if let emailError = ValidationHelpers.emailValidationMessage(email) {
            errorMessage = emailError
            return
        }
        
        // Validate password
        if let passwordError = ValidationHelpers.passwordValidationMessage(password) {
            errorMessage = passwordError
            return
        }
        
        // Check passwords match
        if !ValidationHelpers.passwordsMatch(password, confirmPassword) {
            errorMessage = "Passwords do not match"
            return
        }
        
        isLoading = true
        
        do {
            try await supabaseClient.auth.signUp(email: email, password: password)
            // On success, dismiss and user will be logged in
            dismiss()
        } catch {
            errorMessage = "Failed to create account. Email may already be in use."
            print("Error signing up: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
}
