//
//  UserProfileViewModel.swift
//  JPocket
//
//  Created by Ruby on 14/12/2024.
//

import Foundation

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfileModel?
    @Published var orders: [OrderModel] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let wooCommerceService = WooCommerceService()
    
    func fetchUserProfile() async {
        do {
            userProfile = try await wooCommerceService.getCurrentUser()
        } catch {
            self.error = error
        }
    }
    
    func fetchOrders() async {
        isLoading = true
        do {
            orders = try await wooCommerceService.getOrders()
        } catch {
            self.error = error
        }
        isLoading = false
    }
}
