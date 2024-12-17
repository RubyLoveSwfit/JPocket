//
//  FavoriteViewModel.swift
//  JPocket
//
//  Created by Ruby on 14/12/2024.
//

import Foundation

enum SortOption {
    case name
    case price
    case dateAdded
}

class FavoriteViewModel: ObservableObject {
    @Published var favorites: [ProductModel] = []
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "favorites"
    
    init() {
        loadFavorites()
    }
    
    func loadFavorites() {
        if let data = userDefaults.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([ProductModel].self, from: data) {
            favorites = decoded
        }
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            userDefaults.set(encoded, forKey: favoritesKey)
        }
    }
    
    func addToFavorites(_ product: ProductModel) {
        if !isFavorite(product) {
            favorites.append(product)
            saveFavorites()
        }
    }
    
    func removeFromFavorites(_ product: ProductModel) {
        favorites.removeAll { $0.id == product.id }
        saveFavorites()
    }
    
    func isFavorite(_ product: ProductModel) -> Bool {
        favorites.contains { $0.id == product.id }
    }
    
    func clearFavorites() {
        favorites.removeAll()
        saveFavorites()
    }
    
    func sortFavorites(by option: SortOption) {
        switch option {
        case .name:
            favorites.sort { $0.name < $1.name }
        case .price:
            favorites.sort { ($0.priceAsDouble ?? 0) < ($1.priceAsDouble ?? 0) }
        case .dateAdded:
            // Since we don't have a date added field, we'll keep the current order
            // You could add a dateAdded field to ProductModel if needed
            break
        }
    }
}
