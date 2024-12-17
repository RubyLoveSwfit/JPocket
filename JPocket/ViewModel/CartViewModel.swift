//
//  CartViewModel.swift
//  JPocket
//
//  Created by Ruby on 13/12/2024.
//

import Foundation

class CartViewModel: ObservableObject {
    @Published var cartItems: [CartModel] = []
    private let userDefaults = UserDefaults.standard
    private let cartKey = "savedCart"
    
    var total: Double {
        cartItems.reduce(0) { sum, item in
            sum + (item.product.priceAsDouble ?? 0) * Double(item.quantity)
        }
    }
    
    var totalItems: String? {
        let count = cartItems.reduce(0) { $0 + $1.quantity }
        return count > 0 ? "\(count)" : nil
    }
    
    init() {
        loadCart()
    }
    
    private func loadCart() {
        if let data = userDefaults.data(forKey: cartKey),
           let decodedItems = try? JSONDecoder().decode([CartModel].self, from: data) {
            cartItems = decodedItems
        }
    }
    
    private func saveCart() {
        if let encoded = try? JSONEncoder().encode(cartItems) {
            userDefaults.set(encoded, forKey: cartKey)
        }
    }
    
    func addToCart(product: ProductModel, quantity: Int = 1) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index].quantity += quantity
        } else {
            cartItems.append(CartModel(product: product, quantity: quantity))
        }
        saveCart()
    }
    
    func removeFromCart(product: ProductModel) {
        cartItems.removeAll { $0.product.id == product.id }
        saveCart()
    }
    
    func updateQuantity(for product: ProductModel, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index].quantity = quantity
            saveCart()
        }
    }
    
    func clearCart() {
        cartItems.removeAll()
        saveCart()
    }
}
