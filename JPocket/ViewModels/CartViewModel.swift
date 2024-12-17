//
//  CartViewModel.swift
//  JPocket
//
//  Created by Ruby on 13/12/2024.
//

import Foundation

class CartViewModel: ObservableObject {
    @Published var items: [CartModel] = [] {
        didSet {
            calculateTotal()
            saveCart()
        }
    }
    @Published var total: Double = 0.0
    private let userDefaults = UserDefaults.standard
    private let cartKey = "savedCart"
    
    var totalItems: String? {
        let count = items.reduce(0) { $0 + $1.quantity }
        return count > 0 ? "\(count)" : nil
    }
    
    init() {
        loadCart()
        calculateTotal()
    }
    
    private func calculateTotal() {
        total = items.reduce(0) { sum, item in
            sum + (Double(item.product.price) ?? 0) * Double(item.quantity)
        }
    }
    
    private func loadCart() {
        if let data = userDefaults.data(forKey: cartKey),
           let decodedItems = try? JSONDecoder().decode([CartModel].self, from: data) {
            items = decodedItems
        }
    }
    
    private func saveCart() {
        if let encoded = try? JSONEncoder().encode(items) {
            userDefaults.set(encoded, forKey: cartKey)
        }
    }
    
    func addToCart(product: ProductModel, quantity: Int = 1) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += quantity
        } else {
            items.append(CartModel(product: product, quantity: quantity))
        }
        calculateTotal()
    }
    
    func removeFromCart(product: ProductModel) {
        items.removeAll { $0.product.id == product.id }
        calculateTotal()
    }
    
    func updateQuantity(for product: ProductModel, quantity: Int) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity = quantity
            calculateTotal()
        }
    }
    
    func clearCart() {
        items.removeAll()
        calculateTotal()
    }
}
