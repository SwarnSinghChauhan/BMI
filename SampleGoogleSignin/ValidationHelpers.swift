//
//  ValidationHelpers.swift
//  SampleGoogleSignin
//
//  Created by Swarn Singh Chauhan on 21/01/26.
//

import Foundation

struct ValidationHelpers {
    
    // MARK: - Email Validation
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func emailValidationMessage(_ email: String) -> String? {
        if email.isEmpty {
            return "Email is required"
        }
        if !isValidEmail(email) {
            return "Please enter a valid email address"
        }
        return nil
    }
    
    // MARK: - Password Validation
    
    static func isValidPassword(_ password: String) -> Bool {
        // At least 8 characters, contains letters and numbers
        let hasMinLength = password.count >= 8
        let hasLetter = password.rangeOfCharacter(from: .letters) != nil
        let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        
        return hasMinLength && hasLetter && hasNumber
    }
    
    static func passwordValidationMessage(_ password: String) -> String? {
        if password.isEmpty {
            return "Password is required"
        }
        if password.count < 8 {
            return "Password must be at least 8 characters"
        }
        if password.rangeOfCharacter(from: .letters) == nil {
            return "Password must contain at least one letter"
        }
        if password.rangeOfCharacter(from: .decimalDigits) == nil {
            return "Password must contain at least one number"
        }
        return nil
    }
    
    static func passwordsMatch(_ password: String, _ confirmPassword: String) -> Bool {
        return password == confirmPassword && !password.isEmpty
    }
    
    // MARK: - Numeric Validation
    
    static func isValidNumeric(_ text: String) -> Bool {
        // Allow numbers and decimal point
        let numericRegex = "^[0-9]*\\.?[0-9]*$"
        let numericPredicate = NSPredicate(format:"SELF MATCHES %@", numericRegex)
        return numericPredicate.evaluate(with: text)
    }
    
    static func isValidWeight(_ weight: String, unit: String) -> (isValid: Bool, message: String?) {
        guard !weight.isEmpty else {
            return (false, "Weight is required")
        }
        
        guard isValidNumeric(weight) else {
            return (false, "Please enter a valid numeric value")
        }
        
        guard let weightValue = Double(weight) else {
            return (false, "Invalid weight value")
        }
        
        // Validate range based on unit
        if unit == "kg" {
            if weightValue < 1 || weightValue > 500 {
                return (false, "Weight must be between 1 and 500 kg")
            }
        } else { // lbs
            if weightValue < 2.2 || weightValue > 1100 {
                return (false, "Weight must be between 2.2 and 1100 lbs")
            }
        }
        
        return (true, nil)
    }
    
    static func isValidHeight(_ height: String, unit: String) -> (isValid: Bool, message: String?) {
        guard !height.isEmpty else {
            return (false, "Height is required")
        }
        
        guard isValidNumeric(height) else {
            return (false, "Please enter a valid numeric value")
        }
        
        guard let heightValue = Double(height) else {
            return (false, "Invalid height value")
        }
        
        // Validate range based on unit
        if unit == "cm" {
            if heightValue < 50 || heightValue > 250 {
                return (false, "Height must be between 50 and 250 cm")
            }
        } else { // inches
            if heightValue < 20 || heightValue > 100 {
                return (false, "Height must be between 20 and 100 inches")
            }
        }
        
        return (true, nil)
    }
    
    // MARK: - General Field Validation
    
    static func isNotEmpty(_ text: String, fieldName: String) -> (isValid: Bool, message: String?) {
        if text.trimmingCharacters(in: .whitespaces).isEmpty {
            return (false, "\(fieldName) is required")
        }
        return (true, nil)
    }
    
    // MARK: - Date Validation
    
    static func isValidDate(_ dateString: String, format: String = "yyyy-MM-dd") -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: dateString) != nil
    }
}
