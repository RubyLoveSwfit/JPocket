//
//  FavoriteView.swift
//  JPocket
//
//  Created by Ruby on 14/12/2024.
//

import Foundation
import SwiftUI

struct FavoriteView: View {
    @EnvironmentObject var favoriteViewModel: FavoriteViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var selectedProduct: ProductModel?
    @State private var showingQuantitySelector = false
    @State private var quantity = 1
    @State private var showingShareSheet = false
    @State private var searchText = ""
    @State private var showingClearAlert = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var filteredFavorites: [ProductModel] {
        if searchText.isEmpty {
            return favoriteViewModel.favorites
        }
        return favoriteViewModel.favorites.filter { product in
            product.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
              if favoriteViewModel.favorites.isEmpty {
                    EmptyFavoriteView()
                } else {
                    VStack(spacing: 0) {
                        // Search Bar
                        SearchBarView(
                            text: $searchText,
                            productCount: filteredFavorites.count,
                            placeholder: "Search favorites"
                        )
                        .padding()
                        
                        // Grid View
                        ScrollView {
                            if filteredFavorites.isEmpty {
                                emptySearchView
                            } else {
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(filteredFavorites) { favorite in
                                        NavigationLink(destination: ProductDetailView(product: favorite)) {
                                            CommonProductView(product: favorite) {
                                                selectedProduct = favorite
                                                showingQuantitySelector = true
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .contextMenu {
                                            favoriteContextMenu(for: favorite)
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                        .refreshable {
                            favoriteViewModel.loadFavorites()
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarItems(trailing: toolbarContent)
            .sheet(isPresented: $showingQuantitySelector) {
                if let product = selectedProduct {
                    QuantityInputView(
                        product: product,
                        mode: .sheet,
                        quantity: $quantity,
                        onQuantityChange: { newQuantity in
                            cartViewModel.addToCart(product: product, quantity: newQuantity)
                            showingQuantitySelector = false
                        }
                    )
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let product = selectedProduct {
                    ShareSheet(items: [product.name, product.description])
                }
            }
        }
    }
    
    @ViewBuilder
    private var toolbarContent: some View {
        if !favoriteViewModel.favorites.isEmpty {
            HStack(spacing: 16) {
                sortMenuButton
                clearButton
            }
        }
    }
    
    private var emptySearchView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No favorites found")
                .font(.title2)
                .bold()
            
            Text("No favorites match '\(searchText)'")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var sortMenuButton: some View {
        Menu {
            Button(action: { favoriteViewModel.sortFavorites(by: .name) }) {
                Label {
                    Text("Sort by Name")
                } icon: {
                    Image(systemName: "textformat")
                }
            }
            
            Button(action: { favoriteViewModel.sortFavorites(by: .price) }) {
                Label {
                    Text("Sort by Price")
                } icon: {
                    Image(systemName: "dollarsign")
                }
            }
            
            Button(action: { favoriteViewModel.sortFavorites(by: .dateAdded) }) {
                Label {
                    Text("Sort by Date Added")
                } icon: {
                    Image(systemName: "calendar")
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .imageScale(.medium)
                .frame(width: 30, height: 30)
        }
    }
    
    private var clearButton: some View {
        Button(action: showClearConfirmation) {
            Image(systemName: "trash")
                .imageScale(.medium)
                .frame(width: 30, height: 30)
        }
        .alert("Clear Favorites", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                withAnimation {
                    favoriteViewModel.clearFavorites()
                }
            }
        } message: {
            Text("Are you sure you want to remove all favorites?")
        }
    }
    
    private func showClearConfirmation() {
        showingClearAlert = true
    }
    
    private func favoriteContextMenu(for product: ProductModel) -> some View {
        Group {
            Button {
                selectedProduct = product
                showingShareSheet = true
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            
            Button {
                cartViewModel.addToCart(product: product, quantity: 1)
            } label: {
                Label("Add to Cart", systemImage: "cart.badge.plus")
            }
            
            Button(role: .destructive) {
                withAnimation {
                    favoriteViewModel.removeFromFavorites(product)
                }
            } label: {
                Label("Remove from Favorites", systemImage: "heart.slash")
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct EmptyFavoriteView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Favorites Yet")
                .font(.title2)
                .bold()
            
            Text("Items added to your favorites will appear here")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteView()
            .environmentObject(FavoriteViewModel())
            .environmentObject(CartViewModel())
    }
}
