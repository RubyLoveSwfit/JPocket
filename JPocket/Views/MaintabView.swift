//
//  MaintabView.swift
//  JPocket
//
//  Created by Ruby on 4/5/24.
//

import Foundation
import SwiftUI

struct MainTabView: View {

    @StateObject private var cartViewModel = CartViewModel()
    @StateObject private var favoriteViewModel = FavoriteViewModel()
    @StateObject private var accountViewModel = AccountViewModel()

        var body: some View {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                
                FavoriteView()
                    .tabItem {
                        Label("Favorites", systemImage: "heart")
                    }
                
                CartView()
                    .tabItem {
                        Label("Cart", systemImage: "cart")
                    }
                    .badge(cartViewModel.totalItems)
                
                AccountView()
                    .tabItem {
                        Label("Account", systemImage: "person")
                    }
            }
            .environmentObject(cartViewModel)
            .environmentObject(favoriteViewModel)
            .environmentObject(accountViewModel)

        }
}
