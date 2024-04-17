//
//  LoginPage.swift
//  VideoCallingApp
//
//  Created by Jaxxi.ai on 4/10/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

struct PasswordValidationStates {
    var is8Char: Bool = false
    var containsCapital: Bool = false
    var containsNumber: Bool = false
    var containsSymbol: Bool = false
    var isValid: Bool = false
}


struct LoginPage: View {
    @Binding var userEmail: String?
    @Binding var emailVar: Bool
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isEmailValid = false
    @State private var passwordValidationStates: PasswordValidationStates = PasswordValidationStates()
    @State private var showAlert: Bool = false;
    
    @State private var signInError: String?
    
    @State private var loginErrorText: String = "";
    
    private let emailRegex = #"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"#
    
    
    func normalSignIn() {
        loginErrorText = ""
        if(!isEmailValid || password.trimmingCharacters(in: .whitespacesAndNewlines) == "") {
            showAlert = true
            return;
        }
        
        //        firebaseAuth.createUser(withEmail: email, password: password) { result, error in
        firebaseAuth.signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                self.signInError = error.localizedDescription
                loginErrorText = getAuthErrorMessage(forError: error)
                showAlert = true
//                loginErrAlert = true
                print(error)
            }else if result?.user.isEmailVerified == false {
                result?.user.sendEmailVerification {
                    (error) in
                    if let error = error {
                        print("Email verification error: \(error.localizedDescription)")
                        return
                    }
                    print("Email verification sent!")
                    userEmail = firebaseAuth.currentUser?.email
                    emailVar = firebaseAuth.currentUser?.isEmailVerified ?? false
                }
            } else {
                print("User signed in successfully ")
                userEmail = firebaseAuth.currentUser?.email
                emailVar = firebaseAuth.currentUser?.isEmailVerified ?? false
            }
            
        }
    }
    //        let actionCodeSettings = ActionCodeSettings()
    //        actionCodeSettings.url = URL(string: "https://www.example.com")
    // The sign-in operation has to always be completed in the app.
    
    //        actionCodeSettings.handleCodeInApp = true
    //        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
    let firebaseAuth = Auth.auth()
    
    func getAuthErrorMessage(forError error: Error) -> String {
        guard let nsError = error as NSError? else {
            return error.localizedDescription
        }
        
        if let errorCode = AuthErrorCode.Code(rawValue: nsError.code) {
            switch errorCode {
            case .invalidEmail:
                return "The email address is badly formatted."
            case .wrongPassword:
                return "The password is invalid or the user does not have a password."
            case .userDisabled:
                return "The user account has been disabled by an administrator."
            case .userNotFound:
                return "There is no user record corresponding to this identifier. The user may have been deleted."
            case .invalidCredential:
                return "The supplied auth credential is malformed or has expired."
            case .operationNotAllowed:
                return "The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section."
            case .emailAlreadyInUse:
                return "The email address is already in use by another account."
            case .credentialAlreadyInUse:
                return "This credential is already associated with a different user account."
            case .tooManyRequests:
                return "We have blocked all requests from this device due to unusual activity. Try resetting password"
            default:
                break
            }
        }
        
        if let errorMessage = nsError.userInfo["NSLocalizedDescription"] as? String {
            return "Invalid Credentials"
        } else {
            return "An unknown error occurred."
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
    
    //    var body: some View {
    //        VStack {
    //            TextField("Email", text: $email)
    //                .textFieldStyle(RoundedBorderTextFieldStyle())
    //                .padding()
    //
    //            SecureField("Password", text: $password)
    //                .textFieldStyle(RoundedBorderTextFieldStyle())
    //                .padding()
    //
    //            if let error = signInError {
    //                Text(error)
    //                    .foregroundColor(.red)
    //                    .padding()
    //            }
    //
    //            Button(action: normalSignIn) {
    //                Text("Sign In")
    //            }
    //            .padding()
    //
    ////            Button(action: signIn) {
    ////                Text("Google Sign In")
    ////            }
    ////
    ////            .padding()
    //
    //            Button(action: signOut) {
    //                Text("Sign Out")
    //            }
    //            .padding()
    //        }
    //        .padding()
    //    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
//    private func isValidPassword(_ password: String) -> Bool {
//        // Add your password validation logic here
//        return password.count >= 8 // Example: Password must be at least 8 characters long
//    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("Login")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    
                    TextField("Email", text: $email)
                        .onChange(of: email) {
                            print($0)
                            isEmailValid = isValidEmail(email)
                        }
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.8)))
                        .foregroundColor(.black)
                    if !isEmailValid && email.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                        Text("Invalid Email")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color.white)
                    }
                    
                    SecureField("Password", text: $password)
//                        .onChange(of: password, perform: { newValue in
//                            passwordValidationStates = validatePassword(password: password)
//                        })
                    
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.8)))
                        .foregroundColor(.black)                    
                    
                    
                    Button(action: normalSignIn) {
                        Text("Sign In ")
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: DeferView { SignUp(userEmail: $userEmail, emailVar: $emailVar) }) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Alert"), message: Text(loginErrorText != "" ? loginErrorText : "Please fill all necessary fields/ check if any of them are invalid"), dismissButton: .default(Text("OK")))
                }
            }
            .onTapGesture {
                showAlert = false;
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
}

//struct LoginPage_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginPage()
//    }
//}
