//
//  RegisterView.swift
//  JPocket
//
//  Created by Ruby on 14/12/2024.
//

import Foundation
import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = AccountViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var showingAlert = false
    @State private var errorMessage = ""
    @State private var isRegistering = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                        .textContentType(.givenName)
                    
                    TextField("Last Name", text: $lastName)
                        .textContentType(.familyName)
                    
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Security")) {
                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                }
                
                Section {
                    Button {
                        register()
                    } label: {
                        if isRegistering {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Register")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isRegistering || !isValidForm)
                }
                
                Section {
                    Button("Already have an account? Sign In") {
                        dismiss()
                    }
                    .foregroundColor(.accentColor)
                }
            }
            .navigationTitle("Register")
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .disabled(isRegistering)
        }
    }
    
    private var isValidForm: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    private func register() {
        isRegistering = true
        
        Task {
            do {
                try await viewModel.register(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName
                )
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showingAlert = true
            }
            isRegistering = false
        }
    }
}

//struct RegisterView_Previews: PreviewProvider {
//    static var previews: some View {
//        RegisterView()
//    }
//} 
