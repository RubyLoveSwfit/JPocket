//
//  UserProfileView.swift
//  JPocket
//
//  Created by Ruby on 14/12/2024.
//

import Foundation
import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var viewModel: AccountViewModel
    @StateObject private var ordersViewModel = UserProfileViewModel()
    @State private var showingLogoutAlert = false
    @State private var showingResetPassword = false
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section("Profile") {
                    if viewModel.isLoading {
                        loadingView
                    } else if let user = viewModel.user {
                        profileInfoView(user)
                    } else {
                        signInPromptView
                    }
                }
                
                // Orders Section
                if viewModel.user != nil {
                    Section("Orders") {
                        ordersView
                    }
                }
                
                // Account Actions
                Section {
                    accountActionsView
                }
            }
            .navigationTitle("Account")
            .refreshable {
                await viewModel.fetchUserProfile()
            }
            .alert(
                "Sign Out",
                isPresented: $showingLogoutAlert,
                actions: {
                    Button("Cancel", role: .cancel) { }
                    Button("Sign Out", role: .destructive) {
                        viewModel.signOut()
                    }
                },
                message: {
                    Text("Are you sure you want to sign out?")
                }
            )
            .sheet(isPresented: $showingResetPassword) {
                ResetPasswordView()
            }
        }
    }
    
    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .padding()
    }
    
    private func profileInfoView(_ user: UserProfileModel) -> some View {
        VStack(spacing: 12) {
            // Avatar
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            // User Info
            VStack(spacing: 4) {
                Text(user.fullName)
                    .font(.title2)
                    .bold()
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
//            // Member Since
//            if let formattedDate = user.formattedDate {
//                Text("Member since \(formattedDate)")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private var signInPromptView: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("Sign in to view your account")
                .font(.headline)
            
            NavigationLink("Sign In") {
                SignInView(mode: .navigation)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private var ordersView: some View {
        Group {
            if viewModel.isLoadingOrders {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if viewModel.orders.isEmpty {
                HStack {
                    Text("No orders yet")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                ForEach(viewModel.orders) { order in
                    NavigationLink {
                        OrderDetailView(order: order)
                    } label: {
                        OrderRowView(order: order)
                    }
                }
            }
        }
    }
    
    private var accountActionsView: some View {
        Group {
            if viewModel.user != nil {
                Button("Reset Password") {
                    showingResetPassword = true
                }
                
                Button("Sign Out", role: .destructive) {
                    showingLogoutAlert = true
                }
            }
        }
    }
}

// Add OrderRowView back
struct OrderRowView: View {
    let order: OrderModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Order #\(order.id)")
                .font(.headline)
            
//            HStack {
//                Text(order.formattedStatus)
//                    .font(.subheadline)
//                    .foregroundColor(order.statusColor)
//                
//                Spacer()
//                
//                Text(order.formattedDate)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//            
//            Text(order.formattedTotal)
//                .font(.subheadline)
//                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
            .environmentObject(AccountViewModel())
    }
}
