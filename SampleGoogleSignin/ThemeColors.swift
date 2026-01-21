//
//  ThemeColors.swift
//  SampleGoogleSignin
//
//  Created by Swarn Singh Chauhan on 21/01/26.
//

import SwiftUI

struct ThemeColors {
    // Brown color palette
    static let primaryBrown = Color(red: 0.55, green: 0.27, blue: 0.07) // SaddleBrown
    static let lightBrown = Color(red: 0.82, green: 0.71, blue: 0.55) // Tan
    static let darkBrown = Color(red: 0.40, green: 0.20, blue: 0.00)
    static let accentBrown = Color(red: 0.72, green: 0.52, blue: 0.04) // DarkGoldenrod
    
    // BMI Category Colors
    static let underweight = Color.blue
    static let normalWeight = Color.green
    static let overweight = Color.orange
    static let obese = Color.red
    
    // UI Colors
    static let background = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    
    // Get BMI category color
    static func colorForBMI(category: String) -> Color {
        switch category.lowercased() {
        case "underweight":
            return underweight
        case "normal":
            return normalWeight
        case "overweight":
            return overweight
        case "obese":
            return obese
        default:
            return Color.gray
        }
    }
}
