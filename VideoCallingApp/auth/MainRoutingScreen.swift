//
//  MainRoutingScreen.swift
//  VideoCallingApp
//
//  Created by Jaxxi.ai on 4/18/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

struct MainRoutingScreen: View {
    let firebaseAuth = Auth.auth()
    @State private var userEmail: String? = Auth.auth().currentUser?.email;
    @State private var emailVar: Bool = Auth.auth().currentUser?.isEmailVerified ?? false;
    var body: some View {
        
        if (userEmail != nil && userEmail != "") && emailVar == false {
            NavigationStack {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        Text("Please check your email, click on the link to verify")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            do {
                                print(try firebaseAuth.signOut())
                                userEmail = firebaseAuth.currentUser?.email;
                                emailVar = firebaseAuth.currentUser?.isEmailVerified ?? false;
                                print("fjsdnfjsdf 3")
                                print("fjsdnfjsdf 4")
                            } catch let error as NSError{
                                print(error)
                            }
                        }) {
                            Text("Logout")
                                .foregroundColor(.white)
                                .padding(.vertical)
                                .frame(width: 120)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }
                }
            }
        } else if (userEmail != nil || userEmail != "") && emailVar == true {
            ContentView(userEmail: $userEmail, emailVar: $emailVar)
        } else {
            MainAuthScreen(userEmail: $userEmail, emailVar: $emailVar)
        }
    }
}

struct MainRoutingScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainRoutingScreen()
    }
}
