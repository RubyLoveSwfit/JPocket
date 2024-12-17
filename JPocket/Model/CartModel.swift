//
//  CartModel.swift
//  JPocket
//
//  Created by Ruby on 12/12/2024.
//

import Foundation

struct CartModel: Identifiable, Codable {
    let id: UUID
    let product: ProductModel
    var quantity: Int
    
    init(product: ProductModel, quantity: Int) {
        self.id = UUID()
        self.product = product
        self.quantity = quantity
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case product
        case quantity
    }
}
