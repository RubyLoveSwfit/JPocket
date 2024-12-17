//
//  OrderDetailView.swift
//  JPocket
//
//  Created by Ruby on 14/12/2024.
//

import Foundation
import SwiftUI

struct OrderDetailView: View {
    @EnvironmentObject var viewModel: AccountViewModel
    @StateObject private var orderViewModel = OrderViewModel()
    
    var body: some View {
        Group {
            if orderViewModel.isLoading {
                ProgressView()
            } else if orderViewModel.orders.isEmpty {
                EmptyOrderView()
            } else {
                List {
                    ForEach(orderViewModel.orders) { order in
                        NavigationLink(destination: OrderItemsView(order: order)) {
                            OrderRow(order: order)
                        }
                    }
                }
            }
        }
        .navigationTitle("Order History")
        .task {
            if let email = viewModel.user?.email {
                await orderViewModel.fetchOrders(email: email)
            }
        }
        .alert("Error", isPresented: .constant(orderViewModel.errorMessage != nil)) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(orderViewModel.errorMessage ?? "")
        }
    }
}

struct OrderItemsView: View {
    let order: OrderModel
    
    var body: some View {
        List {
            Section(header: Text("Order Details")) {
                DetailRow(label: "Order Number", value: "#\(order.id)")
                DetailRow(label: "Status", value: order.status.capitalized)
                DetailRow(label: "Total", value: String(format: "$%.2f", order.total))
            }
            
            Section(header: Text("Items")) {
                ForEach(order.lineItems) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Text("\(item.quantity)x")
                        Text(item.total)
                    }
                }
            }
        }
        .navigationTitle("Order #\(order.id)")
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

struct EmptyOrderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Orders Yet")
                .font(.title2)
                .bold()
            
            Text("Your order history will appear here")
                .foregroundColor(.gray)
        }
    }
}

struct OrderRow: View {
    let order: OrderModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Order #\(order.id)")
                .font(.headline)
            
            Text(order.status.capitalized)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("$\(order.total, specifier: "%.2f")")
                .font(.subheadline)
                .bold()
        }
        .padding(.vertical, 4)
    }
}
