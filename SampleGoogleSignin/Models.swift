//
//  Models.swift
//  SampleGoogleSignin
//
//  Created by Swarn Singh Chauhan on 21/01/26.
//

import Foundation

// MARK: - User Profile
struct UserProfile: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    var weight: Double
    var height: Double
    var gender: String
    var weightUnit: String // "kg" or "lbs"
    var heightUnit: String // "cm" or "inches"
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case weight
        case height
        case gender
        case weightUnit = "weight_unit"
        case heightUnit = "height_unit"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(id: UUID = UUID(), userId: UUID, weight: Double, height: Double, gender: String, weightUnit: String = "kg", heightUnit: String = "cm", createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.weight = weight
        self.height = height
        self.gender = gender
        self.weightUnit = weightUnit
        self.heightUnit = heightUnit
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Weight Entry
struct WeightEntry: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let weight: Double
    let unit: String
    let recordedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case weight
        case unit
        case recordedAt = "recorded_at"
    }
    
    init(id: UUID = UUID(), userId: UUID, weight: Double, unit: String, recordedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.weight = weight
        self.unit = unit
        self.recordedAt = recordedAt
    }
}

// MARK: - BMI Record
struct BMIRecord: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let bmi: Double
    let category: String
    let calculatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case bmi
        case category
        case calculatedAt = "calculated_at"
    }
    
    init(id: UUID = UUID(), userId: UUID, bmi: Double, category: String, calculatedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.bmi = bmi
        self.category = category
        self.calculatedAt = calculatedAt
    }
}

// MARK: - Enums
enum WeightUnit: String, CaseIterable {
    case kg = "kg"
    case lbs = "lbs"
    
    var displayName: String {
        switch self {
        case .kg: return "Kilograms"
        case .lbs: return "Pounds"
        }
    }
}

enum HeightUnit: String, CaseIterable {
    case cm = "cm"
    case inches = "inches"
    
    var displayName: String {
        switch self {
        case .cm: return "Centimeters"
        case .inches: return "Inches"
        }
    }
}

enum Gender: String, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
}
