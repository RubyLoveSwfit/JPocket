//
//  OrderDetailView.swift
//  JPocket
//
//  Created by Ruby on 14/12/2024.
//

import Foundation
import SwiftUI

struct OrderDetailView: View {
    let order: OrderModel
    
    var body: some View {
        List {
            Section(header: Text("Order Information")) {
                InfoRow(title: "Order Number", value: "#\(order.id)")
                InfoRow(title: "Date", value: order.dateCreated.formatted(date: .long, time: .shortened))
                InfoRow(title: "Status", value: order.status.capitalized)
                InfoRow(title: "Total", value: String(format: "$%.2f", order.total))
            }
            
            Section(header: Text("Items")) {
                ForEach(order.lineItems) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text("Quantity: \(item.quantity)")
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text(String(format: "$%.2f", item.price))
                            .bold()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

//struct OrderDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            OrderDetailView(order: Order(
//                id: 1234,
//                status: "processing",
//                dateCreated: Date(),
//                total: 99.99,
//                lineItems: [
//                    OrderItem(id: 1, name: "Sample Product", quantity: 2, total: "49.99", price: 49.99)
//                ]
//            ))
//        }
//    }
//}
