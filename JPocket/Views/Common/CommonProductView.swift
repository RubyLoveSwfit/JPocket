import SwiftUI

struct CommonProductView: View {
    let product: ProductModel
    let onAddToCart: () -> Void
    @EnvironmentObject var favoriteViewModel: FavoriteViewModel
    @State private var showingAddedToFavorites = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product Image with out of stock overlay
            ZStack {
                CachedAsyncImage(url: URL(string: product.images.first?.src ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(favoriteButton, alignment: .topTrailing)
                
                // Out of stock overlay
                if !product.isInStock {
                    ZStack {
                        Color.black.opacity(0.6)
                        Text("Out of Stock")
                            .font(.callout)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(4)
                    }
                }
            }
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(2)
                
                if let price = product.priceAsDouble {
                    Text(String(format: "$%.2f", price))
                        .foregroundColor(.secondary)
                }
                
                Button(action: onAddToCart) {
                    Label("Add to Cart", systemImage: "cart.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(!product.isInStock)
                .opacity(product.isInStock ? 1 : 0.5)
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .overlay(
            showingAddedToFavorites ? addedToFavoritesOverlay : nil
        )
    }
    
    private var favoriteButton: some View {
        Button {
            withAnimation {
                toggleFavorite()
            }
        } label: {
            Image(systemName: favoriteViewModel.isFavorite(product) ? "heart.fill" : "heart")
                .foregroundColor(favoriteViewModel.isFavorite(product) ? .red : .gray)
                .padding(8)
                .background(Circle().fill(Color.white))
                .shadow(radius: 2)
        }
        .padding(8)
    }
    
    private var addedToFavoritesOverlay: some View {
        Text(favoriteViewModel.isFavorite(product) ? "Added to Favorites" : "Removed from Favorites")
            .foregroundColor(.white)
            .padding(8)
            .background(Color.black.opacity(0.7))
            .cornerRadius(8)
            .transition(.scale.combined(with: .opacity))
    }
    
    private func toggleFavorite() {
        if favoriteViewModel.isFavorite(product) {
            favoriteViewModel.removeFromFavorites(product)
        } else {
            favoriteViewModel.addToFavorites(product)
        }
        
        // Show feedback
        withAnimation {
            showingAddedToFavorites = true
        }
        
        // Hide feedback after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showingAddedToFavorites = false
            }
        }
    }
}

//struct CommonProductView_Previews: PreviewProvider {
//    static var previews: some View {
//        let sampleProduct = ProductModel(
//            id: 1,
//            name: "Sample Product",
//            price: "29.99",
//            regularPrice: "29.99",
//            salePrice: nil,
//            onSale: false,
//            description: "Sample description",
//            shortDescription: "Short description",
//            images: [
//                ProductImage(id: 1, src: "https://example.com/image.jpg", name: "Sample Image")
//            ],
//            categories: [
//                CategoryModel(id: 1, name: "Sample Category", slug: "sample-category")
//            ],
//            stockStatus: "instock",
//            stockQuantity: 10
//        )
//        
//        CommonProductView(product: sampleProduct, onAddToCart: {})
//            .environmentObject(CartViewModel())
//            .environmentObject(FavoriteViewModel())
//            .padding()
//            .previewLayout(.sizeThatFits)
//    }
//} 
