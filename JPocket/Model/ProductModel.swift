//
//  ProductModel.swift
//  JPocket
//
//  Created by Ruby on 12/12/2024.
//

import Foundation

struct ProductModel: Codable, Identifiable {
    let id: Int
    let name: String
    let price: String
    let regularPrice: String?
    let salePrice: String?
    let onSale: Bool?
    let description: String
//    let shortDescription: String
    let images: [ProductImage]
    let categories: [CategoryModel]
    let stockStatus: String
    let stockQuantity: Int?
      
    var isInStock: Bool {
      stockStatus == "instock"
    }
    var priceAsDouble: Double? {
        Double(price)
    }
    var isOnSale: Bool {
            onSale ?? false
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, price, description, stockStatus, stockQuantity
        case regularPrice = "regular_price"
        case salePrice = "sale_price"
        case onSale = "on_sale"
//        case shortDescription = "short_description"
        case images, categories
    }
}

struct ProductImage: Codable, Identifiable {
    let id: Int
    let src: String
    let name: String
}
