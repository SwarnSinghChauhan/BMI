//
//  UserDetailsFormView.swift
//  SampleGoogleSignin
//
//  Created by Swarn Singh Chauhan on 21/01/26.
//

import SwiftUI
import Supabase

struct UserDetailsFormView: View {
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var selectedGender: Gender = .male
    @State private var selectedWeightUnit: WeightUnit = .kg
    @State private var selectedHeightUnit: HeightUnit = .cm
    
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isLoading: Bool = false
    @State private var isSaving: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "person.fill.questionmark")
                            .font(.system(size: 60))
                            .foregroundColor(ThemeColors.primaryBrown)
                        
                        Text("Your Details")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(ThemeColors.primaryBrown)
                        
                        Text("Enter your information to track your BMI")
                            .font(.subheadline)
                            .foregroundColor(ThemeColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 25) {
                        // Weight Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Weight")
                                .font(.headline)
                                .foregroundColor(ThemeColors.primaryBrown)
                            
                            HStack(spacing: 12) {
                                TextField("Enter weight", text: $weight)
                                    .textFieldStyle(RoundedTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                    .frame(maxWidth: .infinity)
                                
                                Picker("Weight Unit", selection: $selectedWeightUnit) {
                                    ForEach(WeightUnit.allCases, id: \.self) { unit in
                                        Text(unit.rawValue).tag(unit)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 120)
                            }
                            
                            Text(selectedWeightUnit == .kg ? "Range: 1-500 kg" : "Range: 2.2-1100 lbs")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        // Height Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Height")
                                .font(.headline)
                                .foregroundColor(ThemeColors.primaryBrown)
                            
                            HStack(spacing: 12) {
                                TextField("Enter height", text: $height)
                                    .textFieldStyle(RoundedTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                    .frame(maxWidth: .infinity)
                                
                                Picker("Height Unit", selection: $selectedHeightUnit) {
                                    ForEach(HeightUnit.allCases, id: \.self) { unit in
                                        Text(unit.rawValue).tag(unit)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 120)
                            }
                            
                            Text(selectedHeightUnit == .cm ? "Range: 50-250 cm" : "Range: 20-100 inches")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        // Gender Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Gender")
                                .font(.headline)
                                .foregroundColor(ThemeColors.primaryBrown)
                            
                            Picker("Gender", selection: $selectedGender) {
                                ForEach(Gender.allCases, id: \.self) { gender in
                                    Text(gender.rawValue).tag(gender)
                                }
                            }
                            .pickerStyle(.segmented)
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
                        
                        // Save Button
                        Button {
                            Task {
                                await saveProfile()
                            }
                        } label: {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Save Details")
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
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .background(ThemeColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadProfile()
            }
        }
    }
    
    // MARK: - Load Profile
    func loadProfile() async {
        guard let userId = supabaseClient.auth.currentUser?.id else { return }
        
        isLoading = true
        
        do {
            if let profile = try await DatabaseService.shared.fetchUserProfile(userId: userId) {
                weight = String(profile.weight)
                height = String(profile.height)
                selectedGender = Gender(rawValue: profile.gender) ?? .male
                selectedWeightUnit = WeightUnit(rawValue: profile.weightUnit) ?? .kg
                selectedHeightUnit = HeightUnit(rawValue: profile.heightUnit) ?? .cm
            }
        } catch {
            print("Error loading profile: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Save Profile
    func saveProfile() async {
        errorMessage = nil
        successMessage = nil
        
        // Validate weight
        let weightValidation = ValidationHelpers.isValidWeight(weight, unit: selectedWeightUnit.rawValue)
        if !weightValidation.isValid {
            errorMessage = weightValidation.message
            return
        }
        
        // Validate height
        let heightValidation = ValidationHelpers.isValidHeight(height, unit: selectedHeightUnit.rawValue)
        if !heightValidation.isValid {
            errorMessage = heightValidation.message
            return
        }
        
        guard let weightValue = Double(weight), let heightValue = Double(height) else {
            errorMessage = "Invalid numeric values"
            return
        }
        
        guard let userId = supabaseClient.auth.currentUser?.id else {
            errorMessage = "User not authenticated"
            return
        }
        
        isSaving = true
        
        do {
            // Check if profile already exists
            let existingProfile = try await DatabaseService.shared.fetchUserProfile(userId: userId)
            
            if existingProfile != nil {
                // Update existing profile
                try await DatabaseService.shared.updateProfile(
                    userId: userId,
                    weight: weightValue,
                    height: heightValue,
                    gender: selectedGender.rawValue
                )
            } else {
                // Create new profile
                let profile = UserProfile(
                    userId: userId,
                    weight: weightValue,
                    height: heightValue,
                    gender: selectedGender.rawValue,
                    weightUnit: selectedWeightUnit.rawValue,
                    heightUnit: selectedHeightUnit.rawValue
                )
                
                try await DatabaseService.shared.saveUserProfile(profile)
            }
            
            // Calculate and save BMI
            let bmi = BMICalculator.calculateBMI(
                weight: weightValue,
                weightUnit: selectedWeightUnit.rawValue,
                height: heightValue,
                heightUnit: selectedHeightUnit.rawValue
            )
            let category = BMICalculator.getBMICategory(bmi)
            
            let bmiRecord = BMIRecord(userId: userId, bmi: bmi, category: category)
            try await DatabaseService.shared.saveBMIRecord(bmiRecord)
            
            // Add weight entry
            let weightEntry = WeightEntry(
                userId: userId,
                weight: weightValue,
                unit: selectedWeightUnit.rawValue
            )
            try await DatabaseService.shared.addWeightEntry(weightEntry)
            
            successMessage = "Profile saved successfully!"
            
            // Clear success message after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                successMessage = nil
            }
        } catch {
            errorMessage = "Failed to save profile"
            print("Error saving profile: \(error.localizedDescription)")
        }
        
        isSaving = false
    }
}

#Preview {
    UserDetailsFormView()
}
