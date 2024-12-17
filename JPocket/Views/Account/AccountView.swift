//
//  AccountView.swift
//  JPocket
//
//  Created by Ruby on 17/4/2024.
//

import SwiftUI

struct AccountView: View {
    @StateObject private var viewModel = AccountViewModel()
    
    var body: some View {
        UserProfileView()
            .environmentObject(viewModel)
    }
} 
