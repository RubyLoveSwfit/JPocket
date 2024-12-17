//
//  SidebarView.swift
//  JPocket
//
//  Created by Ruby on 17/4/2024.
//

import SwiftUI

struct SidebarView: View {
    @Binding var isShowing: Bool
    @Binding var selectedCategories: Set<CategoryModel>
    @ObservedObject var viewModel: HomeViewModel
    let onCategorySelected: (CategoryModel) -> Void
    
    private var parentCategories: [CategoryModel] {
        viewModel.categories.filter { $0.parent == 0 || $0.parent == nil }
    }
    
    private func childCategories(for parent: CategoryModel) -> [CategoryModel] {
        viewModel.categories.filter { $0.parent == parent.id }
    }
    
    var body: some View {
        GeometryReader { geometry in
            sidebarContainer(geometry: geometry)
        }
        .task {
            await viewModel.fetchCategories()
        }
    }
    
    private func sidebarContainer(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            if isShowing {
                overlayView
                
                mainContent(width: geometry.size.width * 0.8)
            }
        }
        .animation(.easeInOut, value: isShowing)
    }
    
    private var overlayView: some View {
        Color.black
            .opacity(0.3)
            .ignoresSafeArea()
            .onTapGesture {
                withAnimation(.easeInOut) {
                    isShowing = false
                }
            }
    }
    
    private func mainContent(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            sidebarHeader
            
            categoriesList
        }
        .frame(width: width)
        .background(Color(.systemBackground))
        .shadow(radius: 5)
        .transition(.move(edge: .leading))
    }
    
    private var categoriesList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                allProductsButton
                
                categoriesContent
            }
        }
        .background(Color(.systemBackground))
    }
    
    private var categoriesContent: some View {
        ForEach(parentCategories) { parent in
            CategoryParentView(
                parent: parent,
                children: childCategories(for: parent),
                selectedCategories: $selectedCategories,
                onCategorySelected: onCategorySelected
            )
        }
    }
    
    private var sidebarHeader: some View {
        HStack {
            Text("Categories")
                .font(.title2)
                .bold()
            
            Spacer()
            
            if !selectedCategories.isEmpty {
                Button("Clear") {
                    withAnimation {
                        selectedCategories.removeAll()
                    }
                }
                .foregroundColor(.accentColor)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var allProductsButton: some View {
        Button {
            selectedCategories.removeAll()
            isShowing = false
        } label: {
            HStack {
                Text("All Products")
                    .foregroundColor(.primary)
                Spacer()
                if selectedCategories.isEmpty {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
            .padding()
            .background(selectedCategories.isEmpty ? Color(.systemGray6) : Color.clear)
        }
    }
}

struct CategoryParentView: View {
    let parent: CategoryModel
    let children: [CategoryModel]
    @Binding var selectedCategories: Set<CategoryModel>
    let onCategorySelected: (CategoryModel) -> Void
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                if children.isEmpty {
                    handleSelection()
                } else {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            } label: {
                HStack {
                    if !children.isEmpty {
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                    
                    Text(parent.displayName)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if selectedCategories.contains(parent) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .padding()
                .background(selectedCategories.contains(parent) ? Color(.systemGray6) : Color.clear)
            }
            
            if isExpanded {
                ForEach(children) { child in
                    CategoryChildView(
                        category: child,
                        selectedCategories: $selectedCategories,
                        onCategorySelected: onCategorySelected
                    )
                }
            }
            
            Divider()
        }
    }
    
    private func handleSelection() {
        onCategorySelected(parent)
        withAnimation {
            isExpanded = false
        }
    }
}

struct CategoryChildView: View {
    let category: CategoryModel
    @Binding var selectedCategories: Set<CategoryModel>
    let onCategorySelected: (CategoryModel) -> Void
    
    var body: some View {
        Button {
            onCategorySelected(category)
        } label: {
            HStack {
                Text(category.displayName)
                    .foregroundColor(.primary)
                Spacer()
                if selectedCategories.contains(category) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.leading, 40)
            .padding(.trailing)
            .padding(.vertical)
            .background(selectedCategories.contains(category) ? Color(.systemGray6) : Color.clear)
        }
        
        Divider()
    }
}
