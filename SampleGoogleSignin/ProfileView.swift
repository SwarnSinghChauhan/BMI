//
//  ProfileView.swift
//  SampleGoogleSignin
//
//  Created by Swarn Singh Chauhan on 21/01/26.
//

import SwiftUI
import Supabase

struct ProfileView: View {
    @State private var userEmail: String?
    @State private var userProfile: UserProfile?
    @State private var isGoogleUser: Bool = false
    
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var selectedGender: Gender = .male
    @State private var isEditing: Bool = false
    
    @State private var showChangePassword: Bool = false
    @State private var showSignOutConfirmation: Bool = false
    
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isSaving: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // Profile Header
                    VStack(spacing: 15) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(ThemeColors.primaryBrown)
                        
                        if let email = userEmail {
                            Text(email)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        HStack(spacing: 5) {
                            Image(systemName: isGoogleUser ? "g.circle.fill" : "envelope.fill")
                                .font(.caption)
                            Text(isGoogleUser ? "Google Account" : "Email Account")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(20)
                    }
                    .padding(.top, 20)
                    
                    // Profile Information Card
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Profile Information")
                                .font(.headline)
                                .foregroundColor(ThemeColors.primaryBrown)
                            
                            Spacer()
                            
                            Button(isEditing ? "Cancel" : "Edit") {
                                if isEditing {
                                    // Cancel - reload original data
                                    Task {
                                        await loadProfileData()
                                    }
                                }
                                isEditing.toggle()
                                errorMessage = nil
                                successMessage = nil
                            }
                            .font(.subheadline)
                            .foregroundColor(ThemeColors.accentBrown)
                        }
                        
                        Divider()
                        
                        if let profile = userProfile {
                            // Weight
                            HStack {
                                Image(systemName: "scalemass")
                                    .foregroundColor(ThemeColors.primaryBrown)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Weight")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    if isEditing {
                                        TextField("Weight", text: $weight)
                                            .textFieldStyle(RoundedTextFieldStyle())
                                            .keyboardType(.decimalPad)
                                    } else {
                                        Text("\(String(format: "%.1f", profile.weight)) \(profile.weightUnit)")
                                            .font(.subheadline)
                                    }
                                }
                            }
                            
                            // Height
                            HStack {
                                Image(systemName: "ruler")
                                    .foregroundColor(ThemeColors.primaryBrown)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Height")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    if isEditing {
                                        TextField("Height", text: $height)
                                            .textFieldStyle(RoundedTextFieldStyle())
                                            .keyboardType(.decimalPad)
                                    } else {
                                        Text("\(String(format: "%.1f", profile.height)) \(profile.heightUnit)")
                                            .font(.subheadline)
                                    }
                                }
                            }
                            
                            // Gender
                            HStack {
                                Image(systemName: "person")
                                    .foregroundColor(ThemeColors.primaryBrown)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Gender")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    if isEditing {
                                        Picker("Gender", selection: $selectedGender) {
                                            ForEach(Gender.allCases, id: \.self) { gender in
                                                Text(gender.rawValue).tag(gender)
                                            }
                                        }
                                        .pickerStyle(.segmented)
                                    } else {
                                        Text(profile.gender)
                                            .font(.subheadline)
                                    }
                                }
                            }
                            
                            if isEditing {
                                // Error Message
                                if let errorMessage = errorMessage {
                                    Text(errorMessage)
                                        .font(.footnote)
                                        .foregroundColor(.red)
                                }
                                
                                // Success Message
                                if let successMessage = successMessage {
                                    Text(successMessage)
                                        .font(.footnote)
                                        .foregroundColor(.green)
                                }
                                
                                // Save Button
                                Button {
                                    Task {
                                        await saveChanges()
                                    }
                                } label: {
                                    HStack {
                                        if isSaving {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        } else {
                                            Text("Save Changes")
                                                .fontWeight(.semibold)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(ThemeColors.primaryBrown)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                .disabled(isSaving)
                            }
                        } else {
                            Text("No profile data available")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(ThemeColors.secondaryBackground)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Account Settings Card
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Account Settings")
                            .font(.headline)
                            .foregroundColor(ThemeColors.primaryBrown)
                        
                        Divider()
                        
                        // Change Password (only for email users)
                        if !isGoogleUser {
                            Button {
                                showChangePassword = true
                            } label: {
                                HStack {
                                    Image(systemName: "lock.rotation")
                                        .foregroundColor(ThemeColors.primaryBrown)
                                        .frame(width: 30)
                                    
                                    Text("Change Password")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                            }
                        }
                        
                        // Sign Out
                        Button {
                            showSignOutConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.red)
                                    .frame(width: 30)
                                
                                Text("Sign Out")
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(ThemeColors.secondaryBackground)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .background(ThemeColors.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordView()
            }
            .alert("Sign Out", isPresented: $showSignOutConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .task {
                await loadProfileData()
            }
        }
    }
    
    // MARK: - Load Profile Data
    func loadProfileData() async {
        guard let user = supabaseClient.auth.currentUser else { return }
        
        userEmail = user.email
        
        // Check if Google user
        isGoogleUser = user.appMetadata["provider"]?.value as? String == "google"
        
        do {
            userProfile = try await DatabaseService.shared.fetchUserProfile(userId: user.id)
            
            if let profile = userProfile {
                weight = String(profile.weight)
                height = String(profile.height)
                selectedGender = Gender(rawValue: profile.gender) ?? .male
            }
        } catch {
            print("Error loading profile: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Save Changes
    func saveChanges() async {
        errorMessage = nil
        successMessage = nil
        
        guard let profile = userProfile else { return }
        
        // Validate weight
        let weightValidation = ValidationHelpers.isValidWeight(weight, unit: profile.weightUnit)
        if !weightValidation.isValid {
            errorMessage = weightValidation.message
            return
        }
        
        // Validate height
        let heightValidation = ValidationHelpers.isValidHeight(height, unit: profile.heightUnit)
        if !heightValidation.isValid {
            errorMessage = heightValidation.message
            return
        }
        
        guard let weightValue = Double(weight), let heightValue = Double(height) else {
            errorMessage = "Invalid numeric values"
            return
        }
        
        isSaving = true
        
        do {
            try await DatabaseService.shared.updateProfile(
                userId: profile.userId,
                weight: weightValue,
                height: heightValue,
                gender: selectedGender.rawValue
            )
            
            // Recalculate BMI
            let bmi = BMICalculator.calculateBMI(
                weight: weightValue,
                weightUnit: profile.weightUnit,
                height: heightValue,
                heightUnit: profile.heightUnit
            )
            let category = BMICalculator.getBMICategory(bmi)
            
            let bmiRecord = BMIRecord(userId: profile.userId, bmi: bmi, category: category)
            try await DatabaseService.shared.saveBMIRecord(bmiRecord)
            
            // Add weight entry
            let weightEntry = WeightEntry(
                userId: profile.userId,
                weight: weightValue,
                unit: profile.weightUnit
            )
            try await DatabaseService.shared.addWeightEntry(weightEntry)
            
            successMessage = "Changes saved successfully!"
            isEditing = false
            
            // Reload profile
            await loadProfileData()
            
        } catch {
            errorMessage = "Failed to save changes"
            print("Error saving changes: \(error.localizedDescription)")
        }
        
        isSaving = false
    }
    
    // MARK: - Sign Out
    func signOut() {
        Task {
            do {
                try await supabaseClient.auth.signOut()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ProfileView()
}
