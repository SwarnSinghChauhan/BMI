//
//  HomeView.swift
//  SampleGoogleSignin
//
//  Created by Swarn Singh Chauhan on 21/01/26.
//

import SwiftUI
import Supabase

struct HomeView: View {
    @State private var userEmail: String? = nil
    var body: some View {
        NavigationStack{
            VStack{
                if let email = userEmail{
                    Text("Welcome \(email)")
                        .font(.title)
                        .padding()
                }
                else{
                    Text("No user Signed In")
                        .foregroundStyle(.secondary)
                }
            }
            .onAppear {
                userEmail = supabaseClient.auth.currentUser?.email
            }
            .toolbar(content:{
                ToolbarItem(placement: .topBarLeading){
                    Button("SignOut",role:.destructive){
                        logOut()
                        
                    }
                }
            })
        }
        
    }
    func logOut(){
        Task{
            do {
                try  await supabaseClient.auth.signOut()
                
            }
            catch{
                print("Error Signing in Out \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    HomeView()
}
