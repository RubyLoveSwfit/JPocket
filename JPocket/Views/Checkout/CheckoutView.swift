import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject private var cartViewModel: CartViewModel
    @EnvironmentObject var viewModel: AccountViewModel
    @StateObject private var orderViewModel = OrderViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var postcode = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isProcessing = false
    @State private var showingLoginPrompt = false
    
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !phone.isEmpty &&
        !address.isEmpty &&
        !city.isEmpty &&
        !state.isEmpty &&
        !postcode.isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                if !viewModel.isAuthenticated {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sign in to checkout")
                                .font(.headline)
                            Text("Sign in to your account for a faster checkout experience")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Button("Sign In") {
                                showingLoginPrompt = true
                            }
                            .foregroundColor(.accentColor)
                        }
                    }
                }
                
                Section(header: Text("Contact Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone", text: $phone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("Shipping Address")) {
                    TextField("Address", text: $address)
                        .textContentType(.streetAddressLine1)
                    TextField("City", text: $city)
                        .textContentType(.addressCity)
                    TextField("State", text: $state)
                        .textContentType(.addressState)
                    TextField("Postcode", text: $postcode)
                        .textContentType(.postalCode)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Order Summary")) {
                    ForEach(cartViewModel.items) { item in
                        HStack {
                            Text(item.product.name)
                            Spacer()
                            Text("\(item.quantity)x")
                            Text(item.product.price)
                        }
                    }
                    
                    HStack {
                        Text("Total")
                            .fontWeight(.bold)
                        Spacer()
                        Text(String(format: "$%.2f", cartViewModel.total))
                            .fontWeight(.bold)
                    }
                }
                
                Section {
                    Button(action: placeOrder) {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Place Order")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(isFormValid ? Color.accentColor : Color.gray)
                    .disabled(!isFormValid || isProcessing)
                }
            }
            .navigationTitle("Checkout")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
            .alert(alertMessage, isPresented: $showingAlert) {
                Button("OK", role: .cancel) {
                    if !alertMessage.contains("Error") {
                        cartViewModel.clearCart()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingLoginPrompt) {
                SignInView()
                    .environmentObject(viewModel)
            }
            .onAppear {
                if let user = viewModel.user {
                    email = user.email ?? ""
                }
            }
            .onChange(of: orderViewModel.errorMessage) { error in
                if let error = error {
                    alertMessage = error
                    showingAlert = true
                    isProcessing = false
                }
            }
        }
    }
    
    private func placeOrder() {
        isProcessing = true
        
        let orderRequest = OrderRequest(
            paymentMethod: "cod",
            paymentMethodTitle: "Cash on Delivery",
            setPaid: false,
            billing: BillingShipping(
                firstName: firstName,
                lastName: lastName,
                address1: address,
                city: city,
                state: state,
                postcode: postcode,
                country: "AU",
                email: email,
                phone: phone
            ),
            shipping: BillingShipping(
                firstName: firstName,
                lastName: lastName,
                address1: address,
                city: city,
                state: state,
                postcode: postcode,
                country: "AU",
                email: email,
                phone: phone
            ),
            lineItems: cartViewModel.items.map { item in
                LineItem(
                    productId: Int(item.product.id) ?? 0,
                    quantity: Int(item.quantity) ?? 1
                )
            }
        )
        
        Task {
            do {
                let _ = try await orderViewModel.createOrder(orderRequest)
                await MainActor.run {
                    alertMessage = "Order placed successfully!"
                    showingAlert = true
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    alertMessage = error.localizedDescription
                    showingAlert = true
                    isProcessing = false
                }
            }
        }
    }
}
