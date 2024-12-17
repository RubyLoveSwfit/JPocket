//
//  QuantityInputView.swift
//  JPocket
//
//  Created by Ruby on 14/12/2024.
//

import Foundation
import SwiftUI

enum QuantityInputMode {
    case sheet
    case inline
}

struct QuantityInputView: View {
    let product: ProductModel
    let mode: QuantityInputMode
    @Binding var quantity: Int
    let onQuantityChange: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var quantityString: String
    @FocusState private var isQuantityFocused: Bool
    
    init(product: ProductModel, mode: QuantityInputMode = .sheet, quantity: Binding<Int>, onQuantityChange: @escaping (Int) -> Void) {
        self.product = product
        self.mode = mode
        self._quantity = quantity
        self.onQuantityChange = onQuantityChange
        
        let validQuantity = max(1, min(product.stockQuantity ?? 99, quantity.wrappedValue))
        self._quantityString = State(initialValue: "\(validQuantity)")
        
        if validQuantity != quantity.wrappedValue {
            quantity.wrappedValue = validQuantity
        }
    }
    
    private var maxQuantity: Int {
        product.stockQuantity ?? 99
    }
    
    var body: some View {
        switch mode {
        case .sheet:
            NavigationView {
                Form {
                    Section {
                        productInfoView
                        HStack {
                            Text("Quantity:")
                                .font(.headline)
                            Spacer()
                            quantityControl
                        }
                        
                        totalView
                    }
                    
                    Section {
                        addToCartButton
                    }
                }
                .navigationTitle("Add to Cart")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .keyboard) {
                        Button("Done") {
                            isQuantityFocused = false
                        }
                    }
                }
            }
        case .inline:
            quantityControl
        }
    }
    
    private var quantityControl: some View {
        HStack(spacing: 8) {
            Button {
                if quantity > 1 {
                    quantity -= 1
                    quantityString = "\(quantity)"
                    if mode == .inline {
                        onQuantityChange(quantity)
                    }
                }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.accentColor)
                    .imageScale(.large)
            }
            .buttonStyle(BorderlessButtonStyle())
            .disabled(!product.isInStock || quantity <= 1)
            
            TextField("Qty", text: $quantityString)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(width: 40)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isQuantityFocused)
                .disabled(!product.isInStock)
                .onChange(of: quantityString) { newValue in
                    if let newQuantity = Int(newValue) {
                        let validQuantity = max(1, min(maxQuantity, newQuantity))
                        quantity = validQuantity
                        quantityString = "\(validQuantity)"
                        if mode == .inline {
                            onQuantityChange(validQuantity)
                        }
                    }
                }
            
            Button {
                if quantity < maxQuantity {
                    quantity += 1
                    quantityString = "\(quantity)"
                    if mode == .inline {
                        onQuantityChange(quantity)
                    }
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.accentColor)
                    .imageScale(.large)
            }
            .buttonStyle(BorderlessButtonStyle())
            .disabled(!product.isInStock || quantity >= maxQuantity)
        }
        .contentShape(Rectangle())
        .frame(width: mode == .inline ? 120 : nil)
        .opacity(product.isInStock ? 1 : 0.5)
    }
    
    private var productInfoView: some View {
        HStack(spacing: 12) {
            CachedAsyncImage(url: URL(string: product.images.first?.src ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(2)
                if let price = product.priceAsDouble {
                    Text(String(format: "$%.2f", price))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var totalView: some View {
        Group {
            if let price = product.priceAsDouble {
                HStack {
                    Text("Total:")
                        .font(.headline)
                    Spacer()
                    Text(String(format: "$%.2f", price * Double(quantity)))
                        .font(.title3)
                        .bold()
                }
            }
        }
    }
    
    private var addToCartButton: some View {
        Button {
            onQuantityChange(quantity)
            dismiss()
        } label: {
            Text("Add to Cart")
                .frame(maxWidth: .infinity)
                .font(.headline)
        }
        .buttonStyle(.borderedProminent)
        .disabled(!product.isInStock)
        .opacity(product.isInStock ? 1 : 0.5)
    }
}
