//
//  DatabaseService.swift
//  SampleGoogleSignin
//
//  Created by Swarn Singh Chauhan on 21/01/26.
//

import Foundation
import Supabase

class DatabaseService {
    
    static let shared = DatabaseService()
    
    private init() {}
    
    // MARK: - User Profile Operations
    
    /// Fetch user profile for the current user
    func fetchUserProfile(userId: UUID) async throws -> UserProfile? {
        let response = try await supabaseClient
            .from("user_profiles")
            .select()
            .eq("user_id", value: userId.uuidString)
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let profile = try decoder.decode(UserProfile.self, from: response.data)
        return profile
    }
    
    /// Create or update user profile
    func saveUserProfile(_ profile: UserProfile) async throws {
        var profileData = profile
        profileData.updatedAt = Date()
        
        _ = try await supabaseClient
            .from("user_profiles")
            .upsert(profileData)
            .execute()
    }
    
    /// Update specific profile fields
    func updateProfile(userId: UUID, weight: Double? = nil, height: Double? = nil, gender: String? = nil) async throws {
        struct ProfileUpdate: Encodable {
            let weight: Double?
            let height: Double?
            let gender: String?
            let updated_at: String
        }
        
        let update = ProfileUpdate(
            weight: weight,
            height: height,
            gender: gender,
            updated_at: ISO8601DateFormatter().string(from: Date())
        )
        
        _ = try await supabaseClient
            .from("user_profiles")
            .update(update)
            .eq("user_id", value: userId.uuidString)
            .execute()
    }
    
    // MARK: - Weight History Operations
    
    /// Add a weight entry
    func addWeightEntry(_ entry: WeightEntry) async throws {
        _ = try await supabaseClient
            .from("weight_history")
            .insert(entry)
            .execute()
    }
    
    /// Fetch weight history for the past N days
    func fetchWeightHistory(userId: UUID, days: Int = 7) async throws -> [WeightEntry] {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) else {
            throw NSError(domain: "DateError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to calculate start date"])
        }
        
        let response = try await supabaseClient
            .from("weight_history")
            .select()
            .eq("user_id", value: userId.uuidString)
            .gte("recorded_at", value: ISO8601DateFormatter().string(from: startDate))
            .order("recorded_at", ascending: true)
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let entries = try decoder.decode([WeightEntry].self, from: response.data)
        return entries
    }
    
    // MARK: - BMI Records Operations
    
    /// Save a BMI record
    func saveBMIRecord(_ record: BMIRecord) async throws {
        _ = try await supabaseClient
            .from("bmi_records")
            .insert(record)
            .execute()
    }
    
    /// Fetch BMI history for the past N days
    func fetchBMIHistory(userId: UUID, days: Int = 30) async throws -> [BMIRecord] {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) else {
            throw NSError(domain: "DateError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to calculate start date"])
        }
        
        let response = try await supabaseClient
            .from("bmi_records")
            .select()
            .eq("user_id", value: userId.uuidString)
            .gte("calculated_at", value: ISO8601DateFormatter().string(from: startDate))
            .order("calculated_at", ascending: true)
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let records = try decoder.decode([BMIRecord].self, from: response.data)
        return records
    }
    
    /// Get latest BMI record
    func fetchLatestBMI(userId: UUID) async throws -> BMIRecord? {
        let response = try await supabaseClient
            .from("bmi_records")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("calculated_at", ascending: false)
            .limit(1)
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let records = try decoder.decode([BMIRecord].self, from: response.data)
        return records.first
    }
}
