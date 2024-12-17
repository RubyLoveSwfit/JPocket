import SwiftUI

enum CheckoutOption {
    case guest
    case signIn
}

enum PaymentMethod {
    case stripe
    case paypal
}

struct CheckoutView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var accountViewModel: AccountViewModel
    @State private var checkoutOption = CheckoutOption.guest
    @State private var showingSignIn = false
    @State private var paymentMethod = PaymentMethod.stripe
    @State private var showingPaymentSheet = false
    
    var body: some View {
        NavigationView {
            Form {
                if !accountViewModel.isAuthenticated {
                    checkoutOptionsSection
                }
                
                if checkoutOption == .guest || accountViewModel.isAuthenticated {
                    Group {
                        deliveryAddressSection
                        paymentSection
                        orderSummarySection
                    }
                }
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
            .sheet(isPresented: $showingSignIn) {
                SignInView(mode: .sheet)
                    .environmentObject(accountViewModel)
            }
            .sheet(isPresented: $showingPaymentSheet) {
                if paymentMethod == .stripe {
                    StripePaymentView(amount: cartViewModel.total)
                } else {
                    PayPalPaymentView(amount: cartViewModel.total)
                }
            }
        }
    }
    
    private var checkoutOptionsSection: some View {
        Section {
            Picker("Checkout Option", selection: $checkoutOption) {
                Text("Guest Checkout").tag(CheckoutOption.guest)
                Text("Sign In").tag(CheckoutOption.signIn)
            }
            .pickerStyle(.segmented)
            .onChange(of: checkoutOption) { newValue in
                if newValue == .signIn {
                    showingSignIn = true
                }
            }
        }
    }
    
    private var deliveryAddressSection: some View {
        Section("Delivery Address") {
            if accountViewModel.isAuthenticated {
                SavedAddressView()
            } else {
                AddressInputView()
            }
        }
    }
    
    private var paymentSection: some View {
        Section("Payment Method") {
            VStack(spacing: 16) {
                // Stripe Option
                HStack {
                    RadioButton(selected: paymentMethod == .stripe)
                    HStack(spacing: 12) {
                        Image("stripe-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 25)
                        Text("Credit Card")
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        paymentMethod = .stripe
                    }
                }
                
                // PayPal Option
                HStack {
                    RadioButton(selected: paymentMethod == .paypal)
                    HStack(spacing: 12) {
                        Image("paypal-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 25)
                        Text("PayPal")
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        paymentMethod = .paypal
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var orderSummarySection: some View {
        Section {
            VStack(spacing: 12) {
                ForEach(cartViewModel.cartItems) { item in
                    HStack {
                        Text(item.product.name)
                            .lineLimit(1)
                        Spacer()
                        Text("\(item.quantity)x")
                            .foregroundColor(.secondary)
                        if let price = item.product.priceAsDouble {
                            Text(String(format: "$%.2f", price * Double(item.quantity)))
                        }
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Total")
                        .font(.headline)
                    Spacer()
                    Text(String(format: "$%.2f", cartViewModel.total))
                        .font(.headline)
                }
                
                Button {
                    showingPaymentSheet = true
                } label: {
                    Text("Pay Now")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }
}

struct AddressInputView: View {
    @State private var address1 = ""
    @State private var address2 = ""
    @State private var city = ""
    @State private var state = ""
    @State private var postcode = ""
    @State private var country = ""
    @State private var phone = ""
    
    var body: some View {
        Group {
            TextField("Address Line 1", text: $address1)
                .textContentType(.streetAddressLine1)
            
            TextField("Address Line 2", text: $address2)
                .textContentType(.streetAddressLine2)
            
            TextField("City", text: $city)
                .textContentType(.addressCity)
            
            TextField("State", text: $state)
                .textContentType(.addressState)
            
            TextField("Postcode", text: $postcode)
                .textContentType(.postalCode)
                .keyboardType(.numberPad)
            
            TextField("Country", text: $country)
                .textContentType(.countryName)
            
            TextField("Phone", text: $phone)
                .textContentType(.telephoneNumber)
                .keyboardType(.phonePad)
        }
    }
}

struct SavedAddressView: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    var body: some View {
        if let user = accountViewModel.user {
            VStack(alignment: .leading, spacing: 8) {
                Text(user.fullName)
                    .font(.headline)
                
                // Add saved address display here
                Text("123 Main St")
                Text("Apt 4B")
                Text("New York, NY 10001")
                Text("United States")
                Text(user.email)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// Add RadioButton view
struct RadioButton: View {
    let selected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.accentColor, lineWidth: 2)
                .frame(width: 20, height: 20)
            
            if selected {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 12, height: 12)
            }
        }
    }
}

// Preview
struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
            .environmentObject(CartViewModel())
            .environmentObject(AccountViewModel())
    }
} 
