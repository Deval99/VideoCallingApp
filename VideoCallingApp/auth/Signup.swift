//
//  Signup.swift
//  VideoCallingApp
//
//  Created by Jaxxi.ai on 4/10/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

struct Signup: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var signInError: String?
    private let bridge = BridgeVCView()
    
    func normalSignIn() {
//        firebaseAuth.createUser(withEmail: email, password: password) { result, error in
        firebaseAuth.signIn(withEmail: email, password: password) { result, error in
            if result?.user.isEmailVerified == false {
                result?.user.sendEmailVerification {
                    (error) in
                    if let error = error {
                        print("Email verification error: \(error.localizedDescription)")
                        return
                    }
                    print("Email verification sent!")
                }
            } else {
                print("User signed in successfully ")
            }
            if let error = error {
                self.signInError = error.localizedDescription
                print(error)
            }
        }
    }
    //        let actionCodeSettings = ActionCodeSettings()
    //        actionCodeSettings.url = URL(string: "https://www.example.com")
    // The sign-in operation has to always be completed in the app.
    
    //        actionCodeSettings.handleCodeInApp = true
    //        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
    let firebaseAuth = Auth.auth()
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
            }
        }
    }
    
    func signOut() {
        do {
            try firebaseAuth.signOut()
            print("Signed Out")
        }catch let error as NSError{
            print(error)
        }
    }
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if let error = signInError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button(action: normalSignIn) {
                Text("Sign In")
            }
            .padding()
            
            Button(action: signIn) {
                Text("Google Sign In")
            }
            .addBridge(bridge)
            .padding()
            
            Button(action: signOut) {
                Text("Sign Out")
            }
            .padding()
        }
        .padding()
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


struct Signup_Previews: PreviewProvider {
    static var previews: some View {
        Signup()
    }
}
