//
//  MainAuthScreen.swift
//  VideoCallingApp
//
//  Created by Jaxxi.ai on 4/14/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

struct MainAuthScreen: View {
    @Binding var userEmail: String?
    @Binding var emailVar: Bool
    
    let firebaseAuth = Auth.auth()
    private let bridge = BridgeVCView()
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color or image
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Logo or app icon
                    Image("mainLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .padding(.bottom, 100)
                    
                    // Login button
                    NavigationLink(destination: DeferView { LoginPage(userEmail: $userEmail, emailVar: $emailVar) }) {
                        Image("continueWithEmail")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 240, height: 60)
                    }
                    .padding(.horizontal, 0)
                    .padding(.top, 70)
                    // Google sign-in button
                    Button(action: {
                        // Handle Google sign-in action
                        signIn()
                    }) {
                        Image("googleSignIn")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 240, height: 60)
                    }
                    .padding(.horizontal, 40)
                    .addBridge(bridge)
                    .padding(.top, 0)
                }
            }
            }
    }
    func signIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: bridge.vc) {
            result, error in
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            firebaseAuth.signIn(with: credential) { result, error in
                print(result)
                userEmail = firebaseAuth.currentUser?.email;
                emailVar = firebaseAuth.currentUser?.isEmailVerified ?? false;
            }
        }
    }
}

struct BridgeVCView: UIViewControllerRepresentable {
    let vc = UIViewController()
    typealias UIViewControllerType = UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        //
    }
}

extension View {
    func addBridge(_ bridge: BridgeVCView) -> some View {
        self.background(bridge.frame(width: 0, height: 0))
    }
}


//struct MainAuthScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        MainAuthScreen()
//    }
//}
