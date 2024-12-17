//
//  HomeView.swift
//  JPocket
//
//  Created by Ruby on 10/12/24.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingSidebar = false
    @State private var selectedProduct: ProductModel?
    @State private var searchText = ""
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var quantity = 1
    @EnvironmentObject var favoriteViewModel: FavoriteViewModel
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            mainContent
        }
        .sheet(item: $selectedProduct) { product in
            QuantityInputView(
                product: product,
                mode: .sheet,
                quantity: $quantity
            ) { newQuantity in
                cartViewModel.addToCart(product: product, quantity: newQuantity)
                selectedProduct = nil
                quantity = 1
            }
        }
    }
    
    private var mainContent: some View {
        ZStack {
            VStack(spacing: 0) {
                searchBar
                categoryChips
                productGrid
            }
            
            SidebarView(
                isShowing: $showingSidebar,
                selectedCategories: $viewModel.selectedCategories,
                viewModel: viewModel,
                onCategorySelected: handleCategorySelection
            )
        }
        .navigationTitle(navigationTitle)
        .navigationBarItems(
            leading: sidebarButton,
            trailing: refreshButton
        )
        .alert("Error", isPresented: errorBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.error?.localizedDescription ?? "")
        }
    }
    
    private var searchBar: some View {
        SearchBarView(
            text: $viewModel.searchText,
            productCount: viewModel.filteredProducts.count
        )
        .padding()
    }
    
    private var categoryChips: some View {
        Group {
            if !viewModel.selectedCategories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(viewModel.selectedCategories)) { category in
                            CategoryChip(
                                category: category,
                                onRemove: { viewModel.selectedCategories.remove(category) }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .animation(.easeInOut, value: viewModel.selectedCategories)
            }
        }
    }
    
    private var productGrid: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.products.isEmpty {
                loadingView
            } else if filteredProducts.isEmpty {
                EmptySearchView(searchText: viewModel.searchText)
            } else {
                productsGridContent
            }
        }
    }
    
    private var productsGridContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                if viewModel.selectedCategories.isEmpty {
                    Text(viewModel.isCachingProducts ? "Best Selling" : "All Products")
                        .font(.title2)
                        .bold()
                    
                    if viewModel.isLoadingAllProducts {
                        ProgressView()
                            .scaleEffect(0.7)
                            .padding(.leading, 4)
                    }
                }
            }
            .padding(.horizontal)
            .animation(.easeInOut, value: viewModel.isCachingProducts)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(filteredProducts) { product in
                    NavigationLink(destination: ProductDetailView(product: product)) {
                        CommonProductView(product: product) {
                            quantity = 1
                            selectedProduct = product
                        }
                        .environmentObject(favoriteViewModel)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            
            if viewModel.hasMorePages {
                Button {
                    Task {
                        await viewModel.loadMoreProducts()
                    }
                } label: {
                    if viewModel.isLoadingMore {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Load More")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(viewModel.isLoadingMore)
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var sidebarButton: some View {
        Button {
            showingSidebar.toggle()
        } label: {
            Image(systemName: "line.3.horizontal")
        }
    }
    
    private var refreshButton: some View {
        Button {
            Task {
                await viewModel.refreshData()
            }
        } label: {
            Image(systemName: "arrow.clockwise")
        }
        .disabled(viewModel.isLoading)
    }
    
    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )
    }
    
    private func handleCategorySelection(_ category: CategoryModel) {
        viewModel.selectedCategories.insert(category)
        showingSidebar = false
    }
    
    var filteredProducts: [ProductModel] {
        viewModel.filteredProducts
    }
    
    private var navigationTitle: String {
        if viewModel.selectedCategories.isEmpty {
            return !viewModel.allProducts.isEmpty ? "All Products" : "Best Selling"
        } else if viewModel.selectedCategories.count == 1 {
            return viewModel.selectedCategories.first?.displayName ?? ""
        } else {
            return "\(viewModel.selectedCategories.count) Categories"
        }
    }
}

struct EmptySearchView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No results found")
                .font(.title2)
                .bold()
            
            Text("No products match '\(searchText)'")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(CartViewModel())
    }
}

struct CategoryChip: View {
    let category: CategoryModel
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(category.displayName)
                .font(.subheadline)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.accentColor.opacity(0.1))
        .foregroundColor(.accentColor)
        .clipShape(Capsule())
        .transition(.scale.combined(with: .opacity))
    }
}

