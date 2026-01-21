//
//  LogInView.swift
//  SampleGoogleSignin
//
//  Created by Swarn Singh Chauhan on 21/01/26.
//

import SwiftUI
import GoogleSignIn
import Auth
import Supabase

struct LogInView: View {
    var body: some View {
        NavigationStack{
            VStack{
                Button("Sign in With google"){
                    Task{
                        await sigInWithGoogle()
                    }
                    
                }
            }
            .padding(.horizontal,16)
            .buttonStyle(.bordered)
        }
    }
    
    func sigInWithGoogle() async {
         guard let presentingVC = UIApplication.shared.connectedScenes
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .first?.rootViewController else {
                print("Error getting vc:")
             return
            }
        
        do{
            let result = try await
            GIDSignIn.sharedInstance
                .signIn(withPresenting:presentingVC)
            
            guard let idToken = result.user.idToken?.tokenString else {
                print("Error getting ID token")
                return
            }
            let accessToken = result.user.accessToken.tokenString
            
            try await supabaseClient.auth.signInWithIdToken(credentials: OpenIDConnectCredentials(provider: .google, idToken: idToken,accessToken:accessToken))
            
        }
        catch{
            print("error signing in :\(error.localizedDescription)")
        }
    }
}

#Preview {
    LogInView()
}
