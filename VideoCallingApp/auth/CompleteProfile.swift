//
//  SignUp.swift
//  VideoCallingApp
//
//  Created by Jaxxi.ai on 4/17/24.
//

import SwiftUI

struct CompleteProfile: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var birthDate: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date())!
    
    func normalSignIn() {
        
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("Complete your profile")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    
                    TextField("First Name", text: $firstName)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.8)))
                        .foregroundColor(.black)
                    
                    TextField("Last Name", text: $lastName)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.8)))
                        .foregroundColor(.black)
                    
                    DatePicker("Birthdate", selection: $birthDate, displayedComponents: .date)
                        .datePickerStyle(DefaultDatePickerStyle())
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.8)))
                        .foregroundColor(.black)
                    
                    Button(action: normalSignIn) {
                        Text("Continue")
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(10)
                    }

                }
                .padding()
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
}

struct CompleteProfile_Previews: PreviewProvider {
    static var previews: some View {
        CompleteProfile()
    }
}
