//
//  stripe_payment.swift
//  VideoCallingApp
//
//  Created by Only Mac on 09/05/24.
//

import SwiftUI
import Stripe

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
                    }
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}

struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentView()
    }
}

