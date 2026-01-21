//
//  AppView.swift
//  SampleGoogleSignin
//
//  Created by Swarn Singh Chauhan on 21/01/26.
//

import SwiftUI
import Supabase

struct AppView: View {
    @State var isAuthenticated : Bool = false
    var body: some View {
        Group {
            if isAuthenticated{
                HomeView()
            }
            else{
                LogInView()
            }
        }
        .task{
            for await state in supabaseClient.auth.authStateChanges{
                if [.initialSession,.signedIn,.signedOut].contains(state.event){
                    isAuthenticated = state.session != nil
                }
            }
        } 
            
        
    }
}

#Preview {
    AppView()
}
