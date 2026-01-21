//
//  MainTabView.swift
//  SampleGoogleSignin
//
//  Created by Swarn Singh Chauhan on 21/01/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            UserDetailsFormView()
                .tabItem {
                    Label("Details", systemImage: "person.text.rectangle")
                }
                .tag(0)
            
            BMIDashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(2)
        }
        .accentColor(ThemeColors.primaryBrown)
    }
}

#Preview {
    MainTabView()
}
