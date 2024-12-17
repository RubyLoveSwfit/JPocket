//
//  CartView.swift
//  JPocket
//
//  Created by Ruby on 5/4/2024.
//

import SwiftUI
import Foundation

struct CartView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var accountViewModel: AccountViewModel
    @State private var showingCheckout = false
//    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Group {
//                if isLoading {
//                    ProgressView()
//                } else
                if cartViewModel.items.isEmpty {
                    EmptyCartView()
                } else {
                    cartContent
                }
            }
            .navigationTitle("Cart")
            .sheet(isPresented: $showingCheckout) {
                CheckoutView()
                    .environmentObject(cartViewModel)
                    .environmentObject(accountViewModel)
            }
        }
        .onAppear {
//            // Simulate loading time
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                isLoading = false
//            }
        }
    }
    
    private var cartContent: some View {
        VStack(spacing: 0) {
            List {
                ForEach(cartViewModel.items) { item in
                    CartItemRow(item: item)
                }
                .onDelete(perform: removeItems)
            }
            .listStyle(PlainListStyle())
            
            // Cart Summary
            VStack(spacing: 16) {
                HStack {
                    Text("Total")
                        .font(.headline)
                    Spacer()
                    Text(String(format: "$%.2f", cartViewModel.total))
                        .font(.title2)
                        .bold()
                }
                .padding(.horizontal)
                
                Button {
                    showingCheckout = true
                } label: {
                    Text("Checkout")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(Color(.systemBackground))
            .shadow(radius: 2, y: -2)
        }
    }
    
    private func removeItems(at offsets: IndexSet) {
        offsets.forEach { index in
            let item = cartViewModel.items[index]
            cartViewModel.removeFromCart(product: item.product)
        }
    }
}

struct CartItemRow: View {
    let item: CartModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var quantity: Int
    
    init(item: CartModel) {
        self.item = item
        _quantity = State(initialValue: max(item.quantity, 1))
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            CachedAsyncImage(url: URL(string: item.product.images.first?.src ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Product Details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.headline)
                    .lineLimit(2)
                
                if let price = item.product.priceAsDouble {
                    Text(String(format: "$%.2f", price * Double(item.quantity)))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Quantity Input with correct parameters
            QuantityInputView(
                product: item.product,
                mode: .inline,
                quantity: $quantity,
                onQuantityChange: { newQuantity in
                    cartViewModel.updateQuantity(for: item.product, quantity: max(newQuantity, 1))
                }
            )
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                cartViewModel.removeFromCart(product: item.product)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct EmptyCartView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Your Cart is Empty")
                .font(.title2)
                .bold()
            
            Text("Add some products to your cart")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
            .environmentObject(CartViewModel())
    }
}
