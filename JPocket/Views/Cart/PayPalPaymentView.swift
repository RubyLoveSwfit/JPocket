//
//  StripePaymentView.swift
//  JPocket
//
//  Created by Ruby on 15/12/2024.
//
import SwiftUI

struct PayPalPaymentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    let amount: Double
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Image("paypal-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                }
                .listRowBackground(Color.clear)
                
                Section("PayPal Account") {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
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
                            Text("Pay with PayPal")
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
                
                Section {
                    Link("Don't have a PayPal account?", destination: URL(string: "https://www.paypal.com/signup")!)
                        .font(.footnote)
                        .foregroundColor(.accentColor)
                }
            }
            .navigationTitle("PayPal Payment")
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
        !email.isEmpty && !password.isEmpty && email.contains("@")
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
