//
//  ContentView.swift
//  VideoCallingApp
//
//  Created by Jaxxi.ai on 4/8/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

struct ContentView: View {
    @Binding var userEmail: String?
    @Binding var emailVar: Bool
    @State private var channelId: String = "abc"
    @State private var token: String = "007eJxTYNDcfsT7TKDboj2POj8VtviwXhD4lqcel2GiuWayq3Nf5z4FhuSktDQzkxRDAwNzIxMzwyQL82RTkzQjI1NTQ6PUtOSk1fNF0xoCGRnCyzxZGBkgEMRnZkhMSmZgAAAdlR4m"

    @State private var isActive: Bool = false
    let firebaseAuth = Auth.auth()
    var body: some View {
        NavigationStack {
            VStack {
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
                TextField("Enter Channel ID", text: $channelId)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                TextField("Enter Token", text: $token)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                NavigationLink(destination: DeferView { VideoCalling(channelId: channelId, token: token) }) {
                    Text("Join Now")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }

            }
            .padding()
        }
    }
}
struct DeferView<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        content()          // << everything is created here
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
