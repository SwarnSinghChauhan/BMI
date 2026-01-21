//
//  BMIDashboardView.swift
//  SampleGoogleSignin
//
//  Created by Swarn Singh Chauhan on 21/01/26.
//

import SwiftUI
import Charts
import Auth
import Supabase

struct BMIDashboardView: View {
    @State private var currentBMI: Double?
    @State private var bmiCategory: String = ""
    @State private var weightHistory: [WeightEntry] = []
    @State private var bmiHistory: [BMIRecord] = []
    @State private var userProfile: UserProfile?
    @State private var isLoading: Bool = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    if isLoading {
                        ProgressView()
                            .padding()
                    } else if let bmi = currentBMI {
                        // BMI Display Card
                        VStack(spacing: 15) {
                            Text("Your BMI")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(ThemeColors.primaryBrown)
                            
                            Text(String(format: "%.1f", bmi))
                                .font(.system(size: 72, weight: .bold))
                                .foregroundColor(ThemeColors.colorForBMI(category: bmiCategory))
                            
                            Text(bmiCategory)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(ThemeColors.colorForBMI(category: bmiCategory))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(
                                    ThemeColors.colorForBMI(category: bmiCategory).opacity(0.2)
                                )
                                .cornerRadius(20)
                            
                            Text(BMICalculator.getBMIDescription(bmi))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                        .background(ThemeColors.secondaryBackground)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        // BMI Formula Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "function")
                                    .foregroundColor(ThemeColors.primaryBrown)
                                Text("BMI Formula")
                                    .font(.headline)
                                    .foregroundColor(ThemeColors.primaryBrown)
                            }
                            
                            Text("BMI = weight (kg) / (height (m))²")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            
                            if let profile = userProfile {
                                let weightInKg = profile.weightUnit == "kg" ? profile.weight : BMICalculator.lbsToKg(profile.weight)
                                let heightInM = profile.heightUnit == "cm" ? BMICalculator.cmToMeters(profile.height) : BMICalculator.cmToMeters(BMICalculator.inchesToCm(profile.height))
                                
                                Text("For you: \(String(format: "%.1f", weightInKg)) kg / (\(String(format: "%.2f", heightInM)) m)² = \(String(format: "%.1f", bmi))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(ThemeColors.secondaryBackground)
                        .cornerRadius(15)
                        .padding(.horizontal)
                        
                        // Weight History Graph
                        if !weightHistory.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .foregroundColor(ThemeColors.primaryBrown)
                                    Text("Weight History (Past Week)")
                                        .font(.headline)
                                        .foregroundColor(ThemeColors.primaryBrown)
                                }
                                .padding(.horizontal)
                                
                                Chart {
                                    ForEach(weightHistory) { entry in
                                        LineMark(
                                            x: .value("Date", entry.recordedAt),
                                            y: .value("Weight", entry.weight)
                                        )
                                        .foregroundStyle(ThemeColors.primaryBrown)
                                        .interpolationMethod(.catmullRom)
                                        
                                        PointMark(
                                            x: .value("Date", entry.recordedAt),
                                            y: .value("Weight", entry.weight)
                                        )
                                        .foregroundStyle(ThemeColors.primaryBrown)
                                    }
                                }
                                .chartXAxis {
                                    AxisMarks(values: .automatic) { _ in
                                        AxisValueLabel(format: .dateTime.month().day())
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading)
                                }
                                .frame(height: 200)
                                .padding()
                            }
                            .background(ThemeColors.secondaryBackground)
                            .cornerRadius(15)
                            .padding(.horizontal)
                        }
                        
                        // BMI Trend Graph
                        if !bmiHistory.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                        .foregroundColor(ThemeColors.primaryBrown)
                                    Text("BMI Trend (Past Month)")
                                        .font(.headline)
                                        .foregroundColor(ThemeColors.primaryBrown)
                                }
                                .padding(.horizontal)
                                
                                Chart {
                                    ForEach(bmiHistory) { record in
                                        LineMark(
                                            x: .value("Date", record.calculatedAt),
                                            y: .value("BMI", record.bmi)
                                        )
                                        .foregroundStyle(ThemeColors.accentBrown)
                                        .interpolationMethod(.catmullRom)
                                        
                                        PointMark(
                                            x: .value("Date", record.calculatedAt),
                                            y: .value("BMI", record.bmi)
                                        )
                                        .foregroundStyle(ThemeColors.accentBrown)
                                    }
                                    
                                    // Reference lines for BMI categories
                                    RuleMark(y: .value("Normal Min", 18.5))
                                        .foregroundStyle(.green.opacity(0.3))
                                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                    
                                    RuleMark(y: .value("Overweight", 25))
                                        .foregroundStyle(.orange.opacity(0.3))
                                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                    
                                    RuleMark(y: .value("Obese", 30))
                                        .foregroundStyle(.red.opacity(0.3))
                                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                }
                                .chartXAxis {
                                    AxisMarks(values: .automatic) { _ in
                                        AxisValueLabel(format: .dateTime.month().day())
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading)
                                }
                                .frame(height: 200)
                                .padding()
                            }
                            .background(ThemeColors.secondaryBackground)
                            .cornerRadius(15)
                            .padding(.horizontal)
                        }
                        
                        // BMI Categories Reference
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(ThemeColors.primaryBrown)
                                Text("BMI Categories")
                                    .font(.headline)
                                    .foregroundColor(ThemeColors.primaryBrown)
                            }
                            
                            VStack(spacing: 8) {
                                BMICategoryRow(category: "Underweight", range: "< 18.5", color: ThemeColors.underweight)
                                BMICategoryRow(category: "Normal", range: "18.5 - 24.9", color: ThemeColors.normalWeight)
                                BMICategoryRow(category: "Overweight", range: "25 - 29.9", color: ThemeColors.overweight)
                                BMICategoryRow(category: "Obese", range: "≥ 30", color: ThemeColors.obese)
                            }
                        }
                        .padding()
                        .background(ThemeColors.secondaryBackground)
                        .cornerRadius(15)
                        .padding(.horizontal)
                        
                    } else {
                        // No data state
                        VStack(spacing: 20) {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No BMI Data")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                            
                            Text("Please enter your details in the Details tab to calculate your BMI")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 100)
                    }
                }
                .padding(.vertical)
            }
            .background(ThemeColors.background)
            .navigationTitle("BMI Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadData()
            }
            .task {
                await loadData()
            }
        }
    }
    
    // MARK: - Load Data
    func loadData() async {
        guard let userId = supabaseClient.auth.currentUser?.id else { return }
        
        isLoading = true
        
        do {
            // Load user profile
            userProfile = try await DatabaseService.shared.fetchUserProfile(userId: userId)
            
            // Load latest BMI
            if let latestBMI = try await DatabaseService.shared.fetchLatestBMI(userId: userId) {
                currentBMI = latestBMI.bmi
                bmiCategory = latestBMI.category
            }
            
            // Load weight history
            weightHistory = try await DatabaseService.shared.fetchWeightHistory(userId: userId, days: 7)
            
            // Load BMI history
            bmiHistory = try await DatabaseService.shared.fetchBMIHistory(userId: userId, days: 30)
            
        } catch {
            print("Error loading dashboard data: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}

// MARK: - BMI Category Row
struct BMICategoryRow: View {
    let category: String
    let range: String
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(category)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(range)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    BMIDashboardView()
}
