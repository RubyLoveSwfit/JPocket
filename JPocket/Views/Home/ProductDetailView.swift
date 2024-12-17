//
//  ProductDetailView.swift
//  JPocket
//
//  Created by Ruby on 27/3/24.
//

import Foundation
import SwiftUI

struct ProductDetailView: View {
    let product: ProductModel
    @State private var showingQuantitySelector = false
    @State private var quantity = 1
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var favoriteViewModel: FavoriteViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Product Image
                ZStack {
                    CachedAsyncImage(url: URL(string: product.images.first?.src ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    
                    // Out of stock overlay
                    if !product.isInStock {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("Out of Stock")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.red)
                                    .cornerRadius(8)
                                Spacer()
                            }
                            .background(Color.black.opacity(0.6))
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    // Title and Price
                    HStack {
                        Text(product.name)
                            .font(.title2)
                            .bold()
                        Spacer()
                        favoriteButton
                    }
                    
                    // Price Section
                    VStack(alignment: .leading, spacing: 4) {
                        if product.isOnSale {
                            HStack(alignment: .center, spacing: 8) {
                                Text(String(format: "$%.2f", Double(product.salePrice ?? "0") ?? 0))
                                    .font(.title)
                                    .foregroundColor(.accentColor)
                                    .bold()
                                
                                Text(String(format: "$%.2f", Double(product.regularPrice ?? "0") ?? 0))
                                    .font(.title3)
                                    .strikethrough()
                                    .foregroundColor(.gray)
                            }
                        } else if let price = product.priceAsDouble {
                            Text(String(format: "$%.2f", price))
                                .font(.title)
                                .foregroundColor(.accentColor)
                                .bold()
                        }
                    }
                    
                    // Stock Status with Debug Info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: product.isInStock ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(product.isInStock ? .green : .red)
                            Text(product.isInStock ? "In Stock" : "Out of Stock")
                                .foregroundColor(product.isInStock ? .green : .red)
                            if let quantity = product.stockQuantity {
                                Text("(\(quantity) available)")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Debug info
                        #if DEBUG
                        Text("Stock Status: \(product.stockStatus)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        #endif
                    }
                    
                    Divider()
                    
                    // Always show quantity input for debugging
                    VStack(spacing: 12) {
                        HStack {
                            Text("Quantity:")
                                .font(.headline)
                            Spacer()
                            QuantityInputView(
                                product: product,
                                mode: .inline,
                                quantity: $quantity,
                                onQuantityChange: { newQuantity in
                                    quantity = newQuantity
                                }
                            )
                        }
                        
                        Button {
                            cartViewModel.addToCart(product: product, quantity: quantity)
                            quantity = 1
                        } label: {
                            HStack {
                                Image(systemName: "cart.badge.plus")
                                Text("Add to Cart")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(!product.isInStock)
                        .opacity(product.isInStock ? 1 : 0.5)
                    }
                    .padding(.vertical)
                    
                    Divider()
                    
                    // Description
                    Text("Description")
                        .font(.headline)
                    Text(product.description.htmlStripped)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                favoriteButton
            }
        }
    }
    
    private var favoriteButton: some View {
        Button {
            withAnimation {
                if favoriteViewModel.isFavorite(product) {
                    favoriteViewModel.removeFromFavorites(product)
                } else {
                    favoriteViewModel.addToFavorites(product)
                }
            }
        } label: {
            Image(systemName: favoriteViewModel.isFavorite(product) ? "heart.fill" : "heart")
                .foregroundColor(favoriteViewModel.isFavorite(product) ? .red : .gray)
                .imageScale(.large)
        }
    }
}

// Extension to strip HTML tags from description
extension String {
    var htmlStripped: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}

//struct ProductDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ProductDetailView(product: ProductModel(
//                id: 1,
//                name: "Sample Product",
//                price: "29.99",
//                regularPrice: "29.99",
//                salePrice: "24.99",
//                onSale: true,
//                description: "This is a sample product description with <b>HTML</b> tags.",
//                shortDescription: "Short description",
//                images: [
//                    ProductImage(id: 1, src: "https://example.com/image1.jpg", name: "Image 1"),
//                    ProductImage(id: 2, src: "https://example.com/image2.jpg", name: "Image 2")
//                ],
//                categories: [
//                    Category(id: 1, name: "Sample Category", slug: "sample-category")
//                ]
//            ))
//            .environmentObject(CartManager())
//            .environmentObject(FavoriteViewModel())
//        }
//    }
//}
