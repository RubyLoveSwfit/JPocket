//
//  HomeViewModel.swift
//  JPocket
//
//  Created by Ruby on 14/12/2024.
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var products: [ProductModel] = []
    @Published var categories: [CategoryModel] = []
    @Published var selectedCategories: Set<CategoryModel> = [] {
        didSet {
            handleCategoryChange()
            saveSelectedCategories()
        }
    }
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var error: Error?
    
    private let userDefaults = UserDefaults.standard
    private let productsKey = "cachedProducts"
    private let categoriesKey = "cachedCategories"
    private let lastFetchKey = "lastProductsFetch"
    private let cacheExpirationInterval: TimeInterval = 60 * 15
    
    private(set) var allProducts: [ProductModel] = []
    private var backgroundTask: Task<Void, Never>?
    private var currentPage = 1
    @Published var hasMorePages = true
    
    private let bestSellingKey = "bestSellingProducts"
    private var bestSellingProducts: [ProductModel] = []
    
    @Published private(set) var isLoadingAllProducts = false
    private var _isCachingProducts = false
    
    private var loadAllProductsTask: Task<Void, Never>?
    
    private let selectedCategoryKey = "selectedCategory"
    
    private let pageSize = 20
    
    private let lastUpdateKey = "lastSQLiteUpdate"
    private let updateInterval: TimeInterval = 60 * 60 * 24 // 24 hours
    
    // Public getter for isCachingProducts
    var isCachingProducts: Bool {
        _isCachingProducts
    }
    
    // Add search text property
    @Published var searchText: String = "" {
        didSet {
            if searchText.isEmpty {
                // Reset to current category view when search is cleared
                handleCategoryChange()
            } else {
                // Search in all products
                performSearch()
            }
        }
    }
    
    init() {
        loadCachedDataSync()
        
        // Load best sellers if needed
        if bestSellingProducts.isEmpty {
            Task {
                await loadBestSelling()
            }
        }
        
        // Check if we need to update SQLite database
        if shouldUpdateDatabase() {
            startBackgroundUpdate()
        }
    }
    
    deinit {
        loadAllProductsTask?.cancel()
        backgroundTask?.cancel()
    }
    
    private func shouldUpdateDatabase() -> Bool {
        if let lastUpdate = userDefaults.object(forKey: lastUpdateKey) as? Date {
            return Date().timeIntervalSince(lastUpdate) > updateInterval
        }
        return true
    }
    
    private func startBackgroundUpdate() {
        Task {
            await updateDatabaseInBackground()
        }
    }
    
    private func updateDatabaseInBackground() async {
        do {
            isLoadingAllProducts = true
            // Fetch new data
            let allLoadedProducts = try await WooCommerceService.shared.getAllProducts()
            let fetchedCategories = try await WooCommerceService.shared.getCategories()
            
            // Update SQLite database
            DatabaseManager.shared.saveProducts(allLoadedProducts)
            
            // Update categories cache
            if let encoded = try? JSONEncoder().encode(fetchedCategories) {
                userDefaults.set(encoded, forKey: categoriesKey)
            }
            
            // Update last update time
            userDefaults.set(Date(), forKey: lastUpdateKey)
            
            // Update state if needed
            withAnimation {
                allProducts = allLoadedProducts
                categories = fetchedCategories
                handleCategoryChange()
            }
            isLoadingAllProducts = false
        } catch {
            print("Background update error: \(error.localizedDescription)")
            isLoadingAllProducts = false
        }
    }
    
    private func loadCachedDataSync() {
        // Load cached categories first
        if let data = userDefaults.data(forKey: categoriesKey),
           let cachedCategories = try? JSONDecoder().decode([CategoryModel].self, from: data) {
            categories = cachedCategories
        }
        
        // Load cached selected categories
        if let data = userDefaults.data(forKey: selectedCategoryKey),
           let cachedCategories = try? JSONDecoder().decode([CategoryModel].self, from: data) {
            selectedCategories = Set(cachedCategories)
        }
        
        // Load all products from SQLite
        allProducts = DatabaseManager.shared.loadProducts()
        
        // Load cached best sellers
        if let data = userDefaults.data(forKey: bestSellingKey),
           let cachedBestSelling = try? JSONDecoder().decode([ProductModel].self, from: data) {
            bestSellingProducts = cachedBestSelling
        }
        
        // Set initial products based on cached state
        if !selectedCategories.isEmpty {
            if selectedCategories.contains(where: { $0.id == APIConfig.HotTopSellerID }) {
                products = bestSellingProducts
            } else {
                let filtered = allProducts.filter { product in
                    product.categories.contains { category in
                        selectedCategories.contains { $0.id == category.id }
                    }
                }
                products = Array(filtered.prefix(pageSize))
            }
        } else if !allProducts.isEmpty {
            products = Array(allProducts.prefix(pageSize))
        } else {
            products = bestSellingProducts
        }
        
        // Only default to Best Selling if no cached selection exists AND no products loaded
        if selectedCategories.isEmpty && products.isEmpty,
           let bestSelling = categories.first(where: { $0.id == APIConfig.HotTopSellerID }) {
            selectedCategories.insert(bestSelling)
        }
    }
    
    private func saveSelectedCategories() {
        if let encoded = try? JSONEncoder().encode(Array(selectedCategories)) {
            userDefaults.set(encoded, forKey: selectedCategoryKey)
        }
    }
    
    func loadMoreIfNeeded(product: ProductModel) {
        guard let index = products.firstIndex(where: { $0.id == product.id }),
              index == products.count - 3,
              !isLoadingMore else {
            return
        }
        
        Task {
            await loadMoreProducts()
        }
    }
    
    private func loadNextPage() async {
        guard !isLoadingMore else { return }
        
        isLoadingMore = true
        let nextPage = (products.count / pageSize) + 1
        
        // If showing best sellers
        if selectedCategories.contains(where: { $0.id == APIConfig.HotTopSellerID }) {
            await loadMoreBestSellers(page: nextPage)
        }
        // If categories are selected
        else if !selectedCategories.isEmpty {
            await loadMoreFilteredProducts()
        }
        // Show all products
        else {
            await loadMoreAllProducts()
        }
        
        isLoadingMore = false
    }
    
    func refreshData() async {
        // Keep current selection
        let currentSelection = selectedCategories
        
        // Reset states
        isLoading = true
        currentPage = 1
        hasMorePages = true
        searchText = ""
        
        do {
            // Load best sellers (always fresh)
            let bestSelling = try await WooCommerceService.shared.getBestSellingProducts(page: 1, perPage: pageSize)
            
            withAnimation {
                bestSellingProducts = bestSelling
            }
            
            // Cache best sellers
            if let encoded = try? JSONEncoder().encode(bestSelling) {
                userDefaults.set(encoded, forKey: bestSellingKey)
            }
            
            // Start background update
            startBackgroundUpdate()
            
            // Restore selection
            selectedCategories = currentSelection
            
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    var filteredProducts: [ProductModel] {
        // If searching, return current products (search results)
        if !searchText.isEmpty {
            return products
        }
        
        // Otherwise return category filtered products
        return products
    }
    
    func searchProducts(with query: String) {
        guard !query.isEmpty else {
            products = allProducts
            return
        }
        
        products = allProducts.filter { product in
            product.name.localizedCaseInsensitiveContains(query)
        }
    }
    
    @MainActor
    func fetchCategories() async {
        do {
            let fetchedCategories = try await WooCommerceService.shared.getCategories()
            
            withAnimation {
                categories = fetchedCategories
                // Only select Best Selling if no selection exists
                if selectedCategories.isEmpty,
                   let bestSelling = fetchedCategories.first(where: { $0.id == APIConfig.HotTopSellerID }) {
                    selectedCategories.insert(bestSelling)
                }
            }
            
            // Cache categories
            if let encoded = try? JSONEncoder().encode(fetchedCategories) {
                userDefaults.set(encoded, forKey: categoriesKey)
            }
        } catch {
            self.error = error
        }
    }
    
    var categoriesHierarchy: [CategoryModel: [CategoryModel]] {
        var hierarchy: [CategoryModel: [CategoryModel]] = [:]
        
        // Get parent categories
        let parents = categories.filter { $0.parent == 0 || $0.parent == nil }
        
        // For each parent, get its children
        for parent in parents {
            let children = categories.filter { $0.parent == parent.id }
            hierarchy[parent] = children
        }
        
        return hierarchy
    }
    
    func loadMoreProducts() async {
        guard !isLoadingMore else { return }
        
        isLoadingMore = true
        let nextPage = (products.count / pageSize) + 1
        
        // If showing best sellers (ID 15)
        if selectedCategories.contains(where: { $0.id == APIConfig.HotTopSellerID }) {
            await loadMoreBestSellers(page: nextPage)
        }
        // If categories are selected
        else if !selectedCategories.isEmpty {
            await loadMoreFilteredProducts()
        }
        // Show all products
        else {
            await loadMoreAllProducts()
        }
        
        isLoadingMore = false
    }
    
    private func loadMoreBestSellers(page: Int) async {
        do {
            let newProducts = try await WooCommerceService.shared.getBestSellingProducts(page: page, perPage: pageSize)
            if newProducts.isEmpty {
                hasMorePages = false
            } else {
                withAnimation {
                    bestSellingProducts.append(contentsOf: newProducts)
                    if selectedCategories.contains(where: { $0.id == APIConfig.HotTopSellerID }) {
                        products.append(contentsOf: newProducts)
                    }
                }
                hasMorePages = newProducts.count == pageSize
            }
        } catch {
            self.error = error
            hasMorePages = false
        }
    }
    
    private func loadMoreFilteredProducts() async {
        // Filter products for selected categories
        let filteredProducts = allProducts.filter { product in
            product.categories.contains { category in
                selectedCategories.contains { $0.id == category.id }
            }
        }
        
        let startIndex = products.count
        let endIndex = min(startIndex + pageSize, filteredProducts.count)
        
        if startIndex < filteredProducts.count {
            let nextBatch = Array(filteredProducts[startIndex..<endIndex])
            withAnimation {
                products.append(contentsOf: nextBatch)
            }
            hasMorePages = endIndex < filteredProducts.count
        } else {
            hasMorePages = false
        }
        
        // If we don't have any products, trigger a background update
        if allProducts.isEmpty {
            await startBackgroundUpdate()
        }
    }
    
    private func loadMoreAllProducts() async {
        let startIndex = products.count
        let endIndex = min(startIndex + pageSize, allProducts.count)
        
        if startIndex < allProducts.count {
            let nextBatch = Array(allProducts[startIndex..<endIndex])
            withAnimation {
                products.append(contentsOf: nextBatch)
            }
            hasMorePages = endIndex < allProducts.count
        } else {
            hasMorePages = false
        }
    }
    
    private func handleCategoryChange() {
        guard searchText.isEmpty else { return }
        
        // Reset pagination state
        currentPage = 1
        hasMorePages = true
        products.removeAll()
        
        // If Best Selling is selected
        if selectedCategories.contains(where: { $0.id == APIConfig.HotTopSellerID }) {
            if bestSellingProducts.isEmpty {
                Task {
                    await loadBestSelling()
                }
            } else {
                products = bestSellingProducts
                hasMorePages = true
            }
        }
        // If other categories are selected
        else if !selectedCategories.isEmpty {
            let filteredProducts = allProducts.filter { product in
                !product.categories.isEmpty && product.categories.contains { category in
                    selectedCategories.contains { $0.id == category.id }
                }
            }
            
            if filteredProducts.isEmpty && !allProducts.isEmpty {
                // If we have products but no matches, trigger a background update
                Task {
                    await startBackgroundUpdate()
                }
            }
            
            products = Array(filteredProducts.prefix(pageSize))
            hasMorePages = filteredProducts.count > pageSize
        }
        // If no category is selected, show all products
        else if !allProducts.isEmpty {
            products = Array(allProducts.prefix(pageSize))
            hasMorePages = allProducts.count > pageSize
        }
        // If no products loaded yet, show best sellers
        else {
            products = bestSellingProducts
            hasMorePages = bestSellingProducts.count > pageSize
            
            // Trigger background update if we have no products
            Task {
                await startBackgroundUpdate()
            }
        }
    }
    
    private func performSearch() {
        let searchQuery = searchText.lowercased()
        let searchResults: [ProductModel]
        
        // Search in all products
        searchResults = allProducts.filter { product in
            product.name.lowercased().contains(searchQuery)
        }
        
        // Update products with search results
        withAnimation {
            products = searchResults
            hasMorePages = false // Disable pagination during search
        }
    }
    
    private func loadBestSelling() async {
        guard bestSellingProducts.isEmpty else { return }
        
        isLoading = true
        do {
            let bestSelling = try await WooCommerceService.shared.getBestSellingProducts(page: 1, perPage: pageSize)
            
            withAnimation {
                bestSellingProducts = bestSelling
                if selectedCategories.contains(where: { $0.id == APIConfig.HotTopSellerID }) {
                    products = bestSelling
                }
                hasMorePages = bestSelling.count == pageSize
            }
            
            // Cache best sellers
            if let encoded = try? JSONEncoder().encode(bestSelling) {
                userDefaults.set(encoded, forKey: bestSellingKey)
            }
        } catch {
            self.error = error
        }
        isLoading = false
    }
}
