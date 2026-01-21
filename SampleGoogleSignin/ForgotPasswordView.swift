//
//  ForgotPasswordView.swift
//  SampleGoogleSignin
//
//  Created by Swarn Singh Chauhan on 21/01/26.
//

import SwiftUI
import Supabase

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var email: String = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 70))
                        .foregroundColor(ThemeColors.primaryBrown)
                    
                    Text("Reset Password")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(ThemeColors.primaryBrown)
                    
                    Text("Enter your email to receive a password reset link")
                        .font(.subheadline)
                        .foregroundColor(ThemeColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
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
                    
                    // Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    // Success Message
                    if let successMessage = successMessage {
                        Text(successMessage)
                            .font(.footnote)
                            .foregroundColor(.green)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Send Reset Link Button
                    Button {
                        Task {
                            await sendResetLink()
                        }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Send Reset Link")
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
                
                Spacer()
            }
            .background(ThemeColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(ThemeColors.primaryBrown)
                }
            }
        }
    }
    
    // MARK: - Send Reset Link
    func sendResetLink() async {
        errorMessage = nil
        successMessage = nil
        
        // Validate email
        if let emailError = ValidationHelpers.emailValidationMessage(email) {
            errorMessage = emailError
            return
        }
        
        isLoading = true
        
        do {
            try await supabaseClient.auth.resetPasswordForEmail(email)
            successMessage = "Password reset link sent! Please check your email."
            
            // Auto-dismiss after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                dismiss()
            }
        } catch {
            errorMessage = "Failed to send reset link. Please try again."
            print("Error sending reset link: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}

#Preview {
    ForgotPasswordView()
}
