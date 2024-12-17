//
//  StripePaymentView.swift
//  JPocket
//
//  Created by Ruby on 15/12/2024.
//
import SwiftUI

struct StripePaymentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var cardHolderName = ""
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    let amount: Double
    
    var body: some View {
        NavigationView {
            Form {
                Section("Card Details") {
                    TextField("Card Number", text: $cardNumber)
                        .keyboardType(.numberPad)
                        .textContentType(.creditCardNumber)
                    
                    HStack {
                        TextField("MM/YY", text: $expiryDate)
                            .keyboardType(.numberPad)
                            .frame(maxWidth: .infinity)
                        
                        TextField("CVV", text: $cvv)
                            .keyboardType(.numberPad)
                            .frame(maxWidth: .infinity)
                    }
                    
                    TextField("Cardholder Name", text: $cardHolderName)
                        .textContentType(.name)
                }
                
                Section {
                    HStack {
                        Text("Amount to Pay")
                        Spacer()
                        Text(String(format: "$%.2f", amount))
                            .bold()
                    }
                }
                
                Section {
                    Button {
                        processPayment()
                    } label: {
                        HStack {
                            Text("Pay Now")
                                .bold()
                            if isLoading {
                                Spacer()
                                ProgressView()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(!isValidForm || isLoading)
                }
            }
            .navigationTitle("Credit Card Payment")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isValidForm: Bool {
        cardNumber.count >= 16 &&
        expiryDate.count == 5 &&
        cvv.count >= 3 &&
        !cardHolderName.isEmpty
    }
    
    private func processPayment() {
        isLoading = true
        
        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            // Add actual payment processing here
            showingError = true
            errorMessage = "Payment processing not implemented"
        }
    }
}
