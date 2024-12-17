//
//  AccountView.swift
//  JPocket
//
//  Created by Ruby on 17/4/2024.
//

import SwiftUI
import FirebaseAuth

struct AccountView: View {
    @StateObject private var viewModel = AccountViewModel()
    @State private var isShowingLogin = false
    @State private var isShowingSignUp = false
    @State private var isShowingResetPassword = false
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isAuthenticated {
                    AuthenticatedView(viewModel: viewModel)
                } else {
                    GuestView(
                        isShowingLogin: $isShowingLogin,
                        isShowingSignUp: $isShowingSignUp,
                        isShowingResetPassword: $isShowingResetPassword
                    )
                }
            }
            .navigationTitle("Account")
            .sheet(isPresented: $isShowingLogin) {
                SignInView()
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $isShowingSignUp) {
                RegisterView()
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $isShowingResetPassword) {
                ResetPasswordView(isPresented: $isShowingResetPassword)
                    .environmentObject(viewModel)
            }
            .alert(
                "Error",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                ),
                actions: {
                    Button("OK", role: .cancel) { }
                },
                message: {
                    Text(viewModel.errorMessage ?? "An error occurred")
                }
            )
        }
    }
}

// MARK: - Authenticated View
private struct AuthenticatedView: View {
    @ObservedObject var viewModel: AccountViewModel
    
    var body: some View {
        List {
            Section {
                UserProfileHeader(email: viewModel.user?.email)
            }
            
            Section("Orders") {
                NavigationLink("Order History") {
                    OrderDetailView()
                        .environmentObject(viewModel)
                }
            }
            
            Section("Account") {
                SignOutButton(action: viewModel.signOut)
            }
        }
    }
}

// MARK: - Guest View
private struct GuestView: View {
    @Binding var isShowingLogin: Bool
    @Binding var isShowingSignUp: Bool
    @Binding var isShowingResetPassword: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("Welcome to JPocket")
                .font(.title2)
                .bold()
            
            Text("Sign in to manage your account")
                .foregroundColor(.gray)
            
            AuthButtonsView(
                isShowingLogin: $isShowingLogin,
                isShowingSignUp: $isShowingSignUp,
                isShowingResetPassword: $isShowingResetPassword
            )
        }
        .padding()
    }
}

// MARK: - Supporting Views
private struct UserProfileHeader: View {
    let email: String?
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(alignment: .leading) {
                if let email = email {
                    Text(email)
                        .font(.headline)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

private struct SignOutButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text("Sign Out")
                    .foregroundColor(.red)
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(.red)
            }
        }
    }
}

private struct AuthButtonsView: View {
    @Binding var isShowingLogin: Bool
    @Binding var isShowingSignUp: Bool
    @Binding var isShowingResetPassword: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: { isShowingLogin = true }) {
                Text("Sign In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: { isShowingSignUp = true }) {
                Text("Create Account")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .foregroundColor(.accentColor)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: { isShowingResetPassword = true }) {
                Text("Forgot Password?")
                    .foregroundColor(.gray)
            }
        }
    }
}

