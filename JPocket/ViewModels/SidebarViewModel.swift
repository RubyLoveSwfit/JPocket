import Foundation

class SidebarViewModel: ObservableObject {
    @Published var categories: [CategoryModel] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let wooCommerceService = WooCommerceService.shared
    
    func fetchCategories() async {
        isLoading = true
        do {
            let categories = try await wooCommerceService.getCategories()
            await MainActor.run {
                self.categories = categories
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                isLoading = false
            }
        }
    }
}
