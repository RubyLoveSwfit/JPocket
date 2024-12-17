//
//  OrderModel.swift
//  JPocket
//
//  Created by Ruby on 14/12/2024.
//

import Foundation

struct OrderModel: Identifiable, Codable {
    let id: Int
    let status: String
    let dateCreated: Date
    let total: Double
    let lineItems: [OrderItem]
    
    enum CodingKeys: String, CodingKey {
        case id
        case status
        case dateCreated = "date_created"
        case total
        case lineItems = "line_items"
    }
}

struct OrderItem: Identifiable, Codable {
    let id: Int
    let name: String
    let quantity: Int
    let total: String
    let price: Double
}
