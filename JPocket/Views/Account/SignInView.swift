//
//  SignInView.swift
//  JPocket
//
//  Created by Ruby on 5/12/2024.
//

import Foundation
import SwiftUI

enum SignInMode {
    case sheet
    case navigation
}

struct SignInView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AccountViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var showingRegistration = false
    @State private var showingForgotPassword = false
    let mode: SignInMode
    
    init(mode: SignInMode = .navigation) {
        self.mode = mode
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                }
                
                Section {
                    Button {
                        Task {
                            await signIn()
                        }
                    } label: {
                        HStack {
                            Text("Sign In")
                            if viewModel.isLoading {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(viewModel.isLoading || !isValidInput)
                }
                
                Section {
                    Button("Forgot Password?") {
                        showingForgotPassword = true
                    }
                    
                    Button("Create Account") {
                        showingRegistration = true
                    }
                }
            }
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: mode == .sheet ? cancelButton : nil)
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "An error occurred")
            }
            .sheet(isPresented: $showingRegistration) {
                RegisterView()
            }
            .sheet(isPresented: $showingForgotPassword) {
                ResetPasswordView()
            }
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
    
    private var isValidInput: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    private func signIn() async {
        await viewModel.signIn(email: email, password: password)
        if viewModel.isAuthenticated {
            dismiss()
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SignInView(mode: .navigation)
                .previewDisplayName("Navigation")
            
            SignInView(mode: .sheet)
                .previewDisplayName("Sheet")
        }
    }
}
