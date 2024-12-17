//
//  OrderViewModel.swift
//  JPocket
//
//  Created by Ruby on 17/12/2024.
//

import Foundation

class OrderViewModel: ObservableObject {
    @Published var orders: [OrderModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let wooCommerce = WooCommerceService.shared
    
    func createOrder(_ orderRequest: OrderRequest) async throws -> OrderModel {
        let order = try await wooCommerce.createOrder(orderRequest)
        return OrderModel(
            id: order.id,
            status: order.status,
            dateCreated: order.dateCreated,
            total: Double(order.total) ?? 0.0,
            lineItems: order.lineItems.map { OrderItem(id: $0.id, name: $0.name, quantity: $0.quantity, total: $0.total, price: $0.price) }
        )
    }
    
    func fetchOrders(email: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let fetchedOrders = try await wooCommerce.getOrders(email: email)
            await MainActor.run {
                self.orders = fetchedOrders.map { order in
                    OrderModel(
                        id: order.id,
                        status: order.status,
                        dateCreated: order.dateCreated,
                        total: Double(order.total) ?? 0.0,
                        lineItems: order.lineItems.map { 
                            OrderItem(id: $0.id, name: $0.name, quantity: $0.quantity, total: $0.total, price: $0.price)
                        }
                    )
                }
                self.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

struct OrderRequest: Encodable {
    let paymentMethod: String
    let paymentMethodTitle: String
    let setPaid: Bool
    let billing: BillingShipping
    let shipping: BillingShipping
    let lineItems: [LineItem]
    
    enum CodingKeys: String, CodingKey {
        case paymentMethod = "payment_method"
        case paymentMethodTitle = "payment_method_title"
        case setPaid = "set_paid"
        case billing
        case shipping
        case lineItems = "line_items"
    }
}

struct BillingShipping: Encodable {
    let firstName: String
    let lastName: String
    let address1: String
    let city: String
    let state: String
    let postcode: String
    let country: String
    let email: String
    let phone: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case address1 = "address_1"
        case city
        case state
        case postcode
        case country
        case email
        case phone
    }
}

struct LineItem: Encodable {
    let productId: Int
    let quantity: Int
    
    init(productId: Int, quantity: Int) {
        self.productId = productId
        self.quantity = quantity
    }
    
    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case quantity
    }
}
