//
//  ChangePasswordView.swift
//  SampleGoogleSignin
//
//  Created by Swarn Singh Chauhan on 21/01/26.
//

import SwiftUI
import Supabase

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 70))
                            .foregroundColor(ThemeColors.primaryBrown)
                        
                        Text("Change Password")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(ThemeColors.primaryBrown)
                        
                        Text("Create a new secure password")
                            .font(.subheadline)
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    // Form Section
                    VStack(spacing: 20) {
                        // New Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("New Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(ThemeColors.textPrimary)
                            
                            SecureField("Enter new password", text: $newPassword)
                                .textFieldStyle(RoundedTextFieldStyle())
                                .textContentType(.newPassword)
                            
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
                            
                            SecureField("Confirm new password", text: $confirmPassword)
                                .textFieldStyle(RoundedTextFieldStyle())
                                .textContentType(.newPassword)
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
                        }
                        
                        // Change Password Button
                        Button {
                            Task {
                                await changePassword()
                            }
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Update Password")
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
    
    // MARK: - Change Password
    func changePassword() async {
        errorMessage = nil
        successMessage = nil
        
        // Validate new password
        if let passwordError = ValidationHelpers.passwordValidationMessage(newPassword) {
            errorMessage = passwordError
            return
        }
        
        // Check passwords match
        if !ValidationHelpers.passwordsMatch(newPassword, confirmPassword) {
            errorMessage = "Passwords do not match"
            return
        }
        
        isLoading = true
        
        do {
            try await supabaseClient.auth.update(user: UserAttributes(password: newPassword))
            successMessage = "Password updated successfully!"
            
            // Auto-dismiss after 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } catch {
            errorMessage = "Failed to update password. Please try again."
            print("Error updating password: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}

#Preview {
    ChangePasswordView()
}
