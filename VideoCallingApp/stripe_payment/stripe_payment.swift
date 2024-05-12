//
//  stripe_payment.swift
//  VideoCallingApp
//
//  Created by Only Mac on 09/05/24.
//

import SwiftUI
import Stripe
import StripePaymentSheet

class PaymentAuthenticationContext: NSObject, STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("No key window found.")
        }
        return keyWindow.rootViewController!
    }
}

struct PaymentView: View {
    @State private var paymentMethodParams: STPPaymentMethodParams?;
    @State private var amount: String = "10";
    @State private var currency: String = "usd";
    //    let customerContext = STPCustomerContext()
    // Create a CustomerContext instance
    // Create a CustomerContext instance
    // Create a key provider using the publishable key
    // Configure Stripe with your publishable key
    
    var body: some View {
        VStack {
            STPPaymentCardTextField.Representable(paymentMethodParams: $paymentMethodParams)
                .padding()
            
            TextField("Amount", text: $amount)
                .keyboardType(.decimalPad)
            TextField("Currency", text: $currency)
            Button("Pay") {
                if(amount.isEmpty || currency.isEmpty) {
                    print("Enter correct amount and currency")
                    return;
                }
                //                callPaymentIntentAPI { result in
                //                    switch result {
                //                    case .success(let data):
                //                        // Do something with the data
                //                        print("SUCCESS======")
                //                        if let responseData = String(data: data, encoding: .utf8) {
                //                            let decoder = JSONDecoder()
                //                            let response = try decoder.decode(PaymentIntentResponse.self, from: data)
                //                            // Access client_secret
                //                            let clientSecret = response.clientSecret
                //                            print("Client Secret: \(clientSecret)")
                //                        } else {
                //                            print("Unable to convert data to string.")
                //
                //                        }
                //                    case .failure(let error):
                //                        // Handle error
                //                        print(error)
                //                    }
                //                }
                // Ensure payment method params are not nil
                guard let params = paymentMethodParams else {
                    print("Payment method is nil")
                    return
                }
                
                //                 Process payment using Stripe SDK
                STPAPIClient.shared.createPaymentMethod(with: params) { paymentMethod, error in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    } else if let paymentMethod = paymentMethod {
                        // Payment method created, now you can process the payment
                        print("Payment method created: \(paymentMethod)")
                        
                        callPaymentIntentAPI { result in
                            switch result {
                            case .success(let data):
                                do {
                                    let decoder = JSONDecoder()
                                    let response = try decoder.decode(PaymentIntentResponse.self, from: data)
                                    // Access client_secret
                                    let clientSecret = response.client_secret
                                    print("Client Secret: \(clientSecret)")
                                    
                                    let paymentIntentParams = STPPaymentIntentParams(clientSecret: response.client_secret)
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
                                } catch {
                                    print("Error decoding JSON: \(error)")
                                }
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
    
    enum APIError: Error {
        case requestFailed
        case invalidResponse
        case invalidData
    }
    
    struct PaymentIntentResponse: Codable {
        let id: String
        let object: String
        let amount: Int
        // Add other properties as needed
        let client_secret: String // Add this property to store client_secret
        let payment_method_configuration_details: PaymentMethodConfigurationDetails
        
        struct PaymentMethodConfigurationDetails: Codable {
            let id: String
            // Other properties if needed
        }
    }
    
    
    func callPaymentIntentAPI(completion: @escaping (Result<Data, Error>) -> Void) {
        let headers = [
            "Accept": "*/*",
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization": "Basic MY_TOKEN"
        ]
        
        var components = URLComponents(string: "https://api.stripe.com/v1/payment_intents")!
        components.queryItems = [
            URLQueryItem(name: "amount", value: "10"),
            URLQueryItem(name: "currency", value: "usd")
        ]
        guard let url = components.url else {
            completion(.failure(APIError.invalidData))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.requestFailed))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.invalidData))
                return
            }
            
            completion(.success(data))
        }
        task.resume()
    }
    
    //    private func callPaymentIntentAPI() {
    //        let headers = [
    //            "Accept": "*/*",
    //            "Content-Type": "application/x-www-form-urlencoded",
    //            "Authorization": "Basic MY_TOKEN"
    //        ]
    //
    //        let postData = NSMutableData(data: "amount=2000".data(using: String.Encoding.utf8)!)
    //        postData.append("&currency=usd".data(using: String.Encoding.utf8)!)
    //
    //        let request = NSMutableURLRequest(url: NSURL(string: "https://api.stripe.com/v1/payment_intents")! as URL,
    //                                          cachePolicy: .useProtocolCachePolicy,
    //                                          timeoutInterval: 10.0)
    //        request.httpMethod = "POST"
    //        request.allHTTPHeaderFields = headers
    //        request.httpBody = postData as Data
    //
    //        let session = URLSession.shared
    //        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
    //            if (error != nil) {
    //                print(error)
    //            } else {
    //                let httpResponse = response as? HTTPURLResponse
    //                print(httpResponse)
    //            }
    //        })
    //
    //        dataTask.resume()
    //    }
}

struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentView()
    }
}

