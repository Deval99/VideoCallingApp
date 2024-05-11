//
//  stripe_payment.swift
//  VideoCallingApp
//
//  Created by Only Mac on 09/05/24.
//

import SwiftUI
import Stripe

class PaymentAuthenticationContext: NSObject, STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("No key window found.")
        }
        return keyWindow.rootViewController!
    }
}

struct PaymentView: View {
    @State private var paymentMethodParams: STPPaymentMethodParams?
    
    var body: some View {
        VStack {
            STPPaymentCardTextField.Representable(paymentMethodParams: $paymentMethodParams)
                .padding()
                
            Button("Pay") {
                // Ensure payment method params are not nil
                guard let params = paymentMethodParams else {
                    print("Payment method is nil")
                    return
                }
                
                // Process payment using Stripe SDK
                STPAPIClient.shared.createPaymentMethod(with: params) { paymentMethod, error in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    } else if let paymentMethod = paymentMethod {
                        // Payment method created, now you can process the payment
                        print("Payment method created: \(paymentMethod)")
                        // Handle payment processing here
                        handlePaymentMethod(paymentMethod)

                    }
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
    private func handlePaymentMethod(_ paymentMethod: STPPaymentMethod) {
            // Handle payment processing here
            // This could involve confirming a PaymentIntent on your backend or directly with Stripe
            // Depending on your setup, you may need to call an API endpoint to process the payment
        
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: "pk_test_51PEFIZSGysvXgBPGnZXT1cL1FcEmCqDP7ERHadRyPq7x7IketzrVJMW0rndz5ExFEeDX448o05kERR5FCFWRzxgb00urtJBCZe")
            paymentIntentParams.paymentMethodId = paymentMethod.stripeId

            // Confirm the PaymentIntent using the client-side API
            STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: PaymentAuthenticationContext()) { status, paymentIntent, error in
                switch status {
                case .succeeded:
                    // Payment completed successfully
                    print("Payment succeeded")
                case .failed:
                    // Payment failed
                    print("Payment failed: \(error?.localizedDescription ?? "Unknown error")")
                case .canceled:
                    // Payment was canceled by the user
                    print("Payment canceled")
                @unknown default:
                    fatalError("Unhandled case")
                }
            }
    }
}

struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentView()
    }
}

