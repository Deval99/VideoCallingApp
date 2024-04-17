//
//  SignUp.swift
//  VideoCallingApp
//
//  Created by Jaxxi.ai on 4/17/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

struct SignUp: View {
    @Binding var userEmail: String?
    @Binding var emailVar: Bool
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confPassword: String = ""
    
    @State private var isEmailValid = false
    @State private var passwordValidationStates: PasswordValidationStates = PasswordValidationStates()
    
    @State private var confPassValid: Bool = false;
    
    @State private var showAlert: Bool = false;
    @State private var signUpErrorText: String = "";
    
    let firebaseAuth = Auth.auth()
    
    private let emailRegex = #"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"#
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validateConfPass() -> Void {
        confPassValid = password.trimmingCharacters(in: .whitespacesAndNewlines) == confPassword.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    
    func validatePassword(password: String) -> PasswordValidationStates {
        print(password.trimmingCharacters(in: .whitespacesAndNewlines))
        let symbolAndAtCharacterSet = CharacterSet(charactersIn: "!@#$%^&*()-=_+[]{};':\"\\|,.<>?/`~")
        
        var states = PasswordValidationStates() // Change 'let' to 'var'
        
        states.is8Char = password.count >= 8
        states.containsCapital = password.trimmingCharacters(in: .whitespacesAndNewlines).rangeOfCharacter(from: .uppercaseLetters, options: .caseInsensitive) != nil
        states.containsNumber = password.trimmingCharacters(in: .whitespacesAndNewlines).rangeOfCharacter(from: .decimalDigits) != nil
        states.containsSymbol = password.trimmingCharacters(in: .whitespacesAndNewlines).rangeOfCharacter(from: symbolAndAtCharacterSet) != nil
        states.isValid = states.is8Char && states.containsCapital && states.containsNumber && states.containsSymbol
        
        return states
    }
    
    func handleCreateUserError(error: Error?) -> String {
        guard let nsError = error as NSError? else {
            return "An unknown error occurred."
        }
        
        let errorCode = AuthErrorCode.Code(rawValue: nsError.code)
        
        switch errorCode {
        case .emailAlreadyInUse:
            return "The email address is already in use by another account."
        case .invalidEmail:
            return "The email address is not valid."
        case .weakPassword:
            return "The password must be at least 6 characters long."
        case .networkError:
            return "A network error occurred. Please check your internet connection."
        case .tooManyRequests:
            return "Too many requests were made in a short period of time. Please try again later."
        default:
            return "An unknown error occurred: \(nsError.localizedDescription)"
        }
    }
    
    func normalSignIn() {
        if(!passwordValidationStates.isValid || !confPassValid) {
            showAlert = true;
            return;
        }
        
        signUpErrorText = ""
        if(!isEmailValid || password.trimmingCharacters(in: .whitespacesAndNewlines) == "") {
            showAlert = true
            return;
        }
        
        firebaseAuth.createUser(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                signUpErrorText = handleCreateUserError(error: error)
                showAlert = true
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
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("Sign Up")
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
                        .onChange(of: password, perform: { newValue in
                            passwordValidationStates = validatePassword(password: password)
                        })
                    
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.8)))
                        .foregroundColor(.black)
                    
                    if password.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                        if !passwordValidationStates.containsNumber {
                            Text("must contain a number")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.white)
                        }
                        if !passwordValidationStates.containsSymbol {
                            Text("must contain a symbol")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.white)
                        }
                        if !passwordValidationStates.is8Char {
                            Text("must be 8 characters long")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.white)
                        }
                        if !passwordValidationStates.containsCapital {
                            Text("must contain a capital character")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.white)
                        }
                    }
                    
                    SecureField("Confirm Password", text: $confPassword)
                        .onChange(of: confPassword, perform: { newValue in
                            validateConfPass()
                        })
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.8)))
                        .foregroundColor(.black)
                    
                    if !confPassValid && confPassword.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                        Text("Password and Confirm password should match")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color.white)
                    }
                    
                    Button(action: normalSignIn) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: DeferView { CompleteProfile() }) {
                        Text("Complete Profile")
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Alert"), message: Text(signUpErrorText != "" ? signUpErrorText : "Please fill all necessary fields/ check if any of them are invalid"), dismissButton: .default(Text("OK")))
                }
            }
            .onTapGesture {
                showAlert = false
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
}

//struct SignUp_Previews: PreviewProvider {
//    static var previews: some View {
//        SignUp()
//    }
//}
