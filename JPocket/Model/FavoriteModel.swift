//
//  FavoriteModel.swift
//  JPocket
//
//  Created by Ruby on 14/12/2024.
//

import Foundation

struct FavoriteModel: Codable, Identifiable {
    let id: UUID
    let product: ProductModel
    let dateAdded: Date
    
    init(product: ProductModel) {
        self.id = UUID()
        self.product = product
        self.dateAdded = Date()
    }
}
