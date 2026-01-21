//
//  LogInView.swift
//  SampleGoogleSignin
//
//  Created by Swarn Singh Chauhan on 21/01/26.
//

import SwiftUI
import GoogleSignIn
import Auth
import Supabase

struct LogInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @State private var showSignUp: Bool = false
    @State private var showForgotPassword: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 80))
                            .foregroundColor(ThemeColors.primaryBrown)
                        
                        Text("BMI Tracker")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(ThemeColors.primaryBrown)
                        
                        Text("Track your health journey")
                            .font(.subheadline)
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    // Email/Password Section
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
                            
                            SecureInputView(title: "Enter your password", text: $password)
                        }
                        
                        // Forgot Password
                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                showForgotPassword = true
                            }
                            .font(.footnote)
                            .foregroundColor(ThemeColors.accentBrown)
                        }
                        
                        // Error Message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                        
                        // Sign In Button
                        Button {
                            Task {
                                await signInWithEmail()
                            }
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Sign In")
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
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        
                        Text("OR")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 30)
                    
                    // Google Sign In Button
                    Button {
                        Task {
                            await signInWithGoogle()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "g.circle.fill")
                                .font(.title3)
                            Text("Sign in with Google")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(ThemeColors.primaryBrown)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(ThemeColors.primaryBrown, lineWidth: 2)
                        )
                    }
                    .padding(.horizontal, 30)
                    
                    // Sign Up Link
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.gray)
                        Button("Sign Up") {
                            showSignUp = true
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
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
    
    // MARK: - Sign In with Email
    func signInWithEmail() async {
        errorMessage = nil
        
        // Validate email
        if let emailError = ValidationHelpers.emailValidationMessage(email) {
            errorMessage = emailError
            return
        }
        
        // Validate password
        if password.isEmpty {
            errorMessage = "Password is required"
            return
        }
        
        isLoading = true
        
        do {
            try await supabaseClient.auth.signIn(email: email, password: password)
        } catch {
            errorMessage = "Invalid email or password"
            print("Error signing in: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Sign In with Google
    func signInWithGoogle() async {
        guard let presentingVC = UIApplication.shared.connectedScenes
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .first?.rootViewController else {
                print("Error getting vc:")
                return
            }
        
        do {
            let result = try await GIDSignIn.sharedInstance
                .signIn(withPresenting: presentingVC)
            
            guard let idToken = result.user.idToken?.tokenString else {
                print("Error getting ID token")
                return
            }
            let accessToken = result.user.accessToken.tokenString
            
            try await supabaseClient.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .google,
                    idToken: idToken,
                    accessToken: accessToken
                )
            )
        } catch {
            errorMessage = "Google sign-in failed"
            print("Error signing in: \(error.localizedDescription)")
        }
    }
}



#Preview {
    LogInView()
}
