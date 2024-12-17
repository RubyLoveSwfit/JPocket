//
//  ResetPasswordView.swift
//  JPocket
//
//  Created by Ruby on 14/12/2024.
//

import Foundation
import SwiftUI

struct ResetPasswordView: View {
    @StateObject private var viewModel = AccountViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var isResetting = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section {
                    Button {
                        resetPassword()
                    } label: {
                        if isResetting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Reset Password")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isResetting || email.isEmpty)
                }
            }
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert(isSuccess ? "Success" : "Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {
                    if isSuccess {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .disabled(isResetting)
        }
    }
    
    private func resetPassword() {
        isResetting = true
        
        Task {
            do {
                try await viewModel.resetPassword(email: email)
                isSuccess = true
                alertMessage = "Password reset instructions have been sent to your email."
            } catch {
                isSuccess = false
                alertMessage = error.localizedDescription
            }
            showingAlert = true
            isResetting = false
        }
    }
}

//struct ResetPasswordView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResetPasswordView()
//    }
//} 
