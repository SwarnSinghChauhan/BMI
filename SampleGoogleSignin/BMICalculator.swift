//
//  BMICalculator.swift
//  SampleGoogleSignin
//
//  Created by Swarn Singh Chauhan on 21/01/26.
//

import Foundation

struct BMICalculator {
    
    // MARK: - Unit Conversion
    
    /// Convert pounds to kilograms
    static func lbsToKg(_ lbs: Double) -> Double {
        return lbs * 0.453592
    }
    
    /// Convert kilograms to pounds
    static func kgToLbs(_ kg: Double) -> Double {
        return kg / 0.453592
    }
    
    /// Convert inches to centimeters
    static func inchesToCm(_ inches: Double) -> Double {
        return inches * 2.54
    }
    
    /// Convert centimeters to inches
    static func cmToInches(_ cm: Double) -> Double {
        return cm / 2.54
    }
    
    /// Convert centimeters to meters
    static func cmToMeters(_ cm: Double) -> Double {
        return cm / 100.0
    }
    
    // MARK: - BMI Calculation
    
    /// Calculate BMI from weight and height
    /// - Parameters:
    ///   - weight: Weight value
    ///   - weightUnit: "kg" or "lbs"
    ///   - height: Height value
    ///   - heightUnit: "cm" or "inches"
    /// - Returns: BMI value
    static func calculateBMI(weight: Double, weightUnit: String, height: Double, heightUnit: String) -> Double {
        // Convert to metric (kg and meters)
        var weightInKg = weight
        var heightInMeters = height
        
        if weightUnit == "lbs" {
            weightInKg = lbsToKg(weight)
        }
        
        if heightUnit == "inches" {
            let heightInCm = inchesToCm(height)
            heightInMeters = cmToMeters(heightInCm)
        } else {
            heightInMeters = cmToMeters(height)
        }
        
        // BMI = weight (kg) / (height (m))^2
        let bmi = weightInKg / (heightInMeters * heightInMeters)
        
        return bmi
    }
    
    // MARK: - BMI Category
    
    /// Determine BMI category
    /// - Parameter bmi: BMI value
    /// - Returns: Category string
    static func getBMICategory(_ bmi: Double) -> String {
        switch bmi {
        case ..<18.5:
            return "Underweight"
        case 18.5..<25:
            return "Normal"
        case 25..<30:
            return "Overweight"
        case 30...:
            return "Obese"
        default:
            return "Unknown"
        }
    }
    
    /// Get BMI category description
    /// - Parameter bmi: BMI value
    /// - Returns: Description string
    static func getBMIDescription(_ bmi: Double) -> String {
        let category = getBMICategory(bmi)
        
        switch category {
        case "Underweight":
            return "You may be underweight. Consider consulting a healthcare provider."
        case "Normal":
            return "You have a healthy weight. Keep up the good work!"
        case "Overweight":
            return "You may be overweight. Consider healthy lifestyle changes."
        case "Obese":
            return "You may be obese. Consult a healthcare provider for guidance."
        default:
            return "BMI category unknown."
        }
    }
    
    /// Get ideal weight range for a given height
    /// - Parameters:
    ///   - height: Height value
    ///   - heightUnit: "cm" or "inches"
    /// - Returns: Tuple with min and max weight in kg
    static func getIdealWeightRange(height: Double, heightUnit: String) -> (min: Double, max: Double) {
        var heightInMeters = height
        
        if heightUnit == "inches" {
            let heightInCm = inchesToCm(height)
            heightInMeters = cmToMeters(heightInCm)
        } else {
            heightInMeters = cmToMeters(height)
        }
        
        // Ideal BMI range: 18.5 - 24.9
        let minWeight = 18.5 * (heightInMeters * heightInMeters)
        let maxWeight = 24.9 * (heightInMeters * heightInMeters)
        
        return (min: minWeight, max: maxWeight)
    }
}
