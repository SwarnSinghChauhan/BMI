//
//  SupabaseClient.swift
//  SampleGoogleSignin
//
//  Created by Swarn Singh Chauhan on 21/01/26.
//

import Foundation
import Supabase

let supabaseURL = URL(string:"https://wgitvtolkhutekqgnxux.supabase.co" )!
let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndnaXR2dG9sa2h1dGVrcWdueHV4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg5ODY3OTUsImV4cCI6MjA4NDU2Mjc5NX0.lilHKacJyf3xdxHMdDg3j5-yW1HndJiT1xvvzg6iweY"

let supabaseClient = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)

