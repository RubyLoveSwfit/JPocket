//
//  AccountViewModel.swift
//  JPocket
//
//  Created by Ruby on 13/12/2024.
//

import Foundation

enum AccountError: LocalizedError {
    case networkError
    case authenticationError
    case userNotFound
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Unable to connect to server"
        case .authenticationError:
            return "Authentication failed"
        case .userNotFound:
            return "User not found"
        case .serverError:
            return "Server error occurred"
        }
    }
}

@MainActor
class AccountViewModel: ObservableObject {
    @Published var user: UserProfileModel?
    @Published var orders: [OrderModel] = []
    @Published var isLoading = false
    @Published var isLoadingOrders = false
    @Published var error: AccountError?
    @Published var showError = false
    
    private let wooCommerceService = WooCommerceService.shared
    private let userDefaults = UserDefaults.standard
    private let authTokenKey = "authToken"
    
    var isAuthenticated: Bool {
        user != nil && userDefaults.string(forKey: authTokenKey) != nil
    }
    
    init() {
        if let token = userDefaults.string(forKey: authTokenKey) {
            // Auto-fetch profile if we have a token
            Task {
                await fetchUserProfile()
            }
        }
    }
    
    func fetchUserProfile() async {
        isLoading = true
        error = nil
        
        do {
            user = try await wooCommerceService.getCurrentUser()
            if user != nil {
                await fetchOrders()
            }
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func fetchOrders() async {
        guard isAuthenticated else { return }
        
        isLoadingOrders = true
        
        do {
            orders = try await wooCommerceService.getOrders()
            orders.sort { $0.dateCreated > $1.dateCreated }
        } catch {
            handleError(error)
        }
        
        isLoadingOrders = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        error = nil
        
        do {
            // Implement sign in logic
            let token = try await wooCommerceService.signIn(email: email, password: password)
            userDefaults.set(token, forKey: authTokenKey)
            await fetchUserProfile()
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func signOut() {
        userDefaults.removeObject(forKey: authTokenKey)
        user = nil
        orders.removeAll()
    }
    
    func resetPassword(email: String) async {
        isLoading = true
        error = nil
        
        do {
            // Implement password reset logic
            try await wooCommerceService.resetPassword(email: email)
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func updateProfile(firstName: String, lastName: String) async {
        guard isAuthenticated else { return }
        
        isLoading = true
        error = nil
        
        do {
            // Implement profile update logic
            user = try await wooCommerceService.updateProfile(firstName: firstName, lastName: lastName)
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func register(email: String, password: String, firstName: String, lastName: String) async {
        isLoading = true
        error = nil
        
        do {
            let token = try await wooCommerceService.register(
                email: email,
                password: password,
                firstName: firstName,
                lastName: lastName
            )
            
            userDefaults.set(token, forKey: authTokenKey)
            await fetchUserProfile()
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .authenticationError:
                self.error = .authenticationError
            case .networkError:
                self.error = .networkError
            default:
                self.error = .serverError
            }
        } else {
            self.error = .serverError
        }
        showError = true
    }
}

extension UserProfileModel {
    var fullName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }
    
//    var formattedDate: String? {
//        dateCreated?.formatted(date: .abbreviated, time: .omitted)
//    }
}
