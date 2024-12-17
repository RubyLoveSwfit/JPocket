//
//  DatabaseManager.swift
//  JPocket
//
//  Created by Ruby on 15/12/2024.
//


import Foundation
import SQLite3

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?
    
    private init() {
        setupDatabase()
    }
    
    private func setupDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("products.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
            return
        }
        
        // Create products table
        let createTableString = """
            CREATE TABLE IF NOT EXISTS products(
                id INTEGER PRIMARY KEY,
                name TEXT,
                price TEXT,
                regular_price TEXT,
                sale_price TEXT,
                on_sale INTEGER,
                description TEXT,
                stock_status TEXT,
                stock_quantity INTEGER,
                images TEXT,
                categories TEXT,
                last_updated INTEGER
            );
        """
        
        var createTableStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Products table created")
            }
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func saveProducts(_ products: [ProductModel]) {
        let insertString = """
            INSERT OR REPLACE INTO products (
                id, name, price, regular_price, sale_price, on_sale,
                description, stock_status, stock_quantity, images, categories, last_updated
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        var insertStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, insertString, -1, &insertStatement, nil) == SQLITE_OK {
            for product in products {
                // Bind integer values
                sqlite3_bind_int(insertStatement, 1, Int32(product.id))
                
                // Bind text values
                product.name.withCString { sqlite3_bind_text(insertStatement, 2, $0, -1, nil) }
                product.price.withCString { sqlite3_bind_text(insertStatement, 3, $0, -1, nil) }
                (product.regularPrice ?? "").withCString { sqlite3_bind_text(insertStatement, 4, $0, -1, nil) }
                (product.salePrice ?? "").withCString { sqlite3_bind_text(insertStatement, 5, $0, -1, nil) }
                
                // Bind boolean as integer
                sqlite3_bind_int(insertStatement, 6, product.onSale ?? false ? 1 : 0)
                
                // Bind more text values
                product.description.withCString { sqlite3_bind_text(insertStatement, 7, $0, -1, nil) }
                product.stockStatus.withCString { sqlite3_bind_text(insertStatement, 8, $0, -1, nil) }
                
                // Bind stock quantity
                sqlite3_bind_int(insertStatement, 9, Int32(product.stockQuantity ?? 0))
                
                // Convert arrays to JSON strings
                if let imagesData = try? JSONEncoder().encode(product.images),
                   let imagesString = String(data: imagesData, encoding: .utf8) {
                    imagesString.withCString { sqlite3_bind_text(insertStatement, 10, $0, -1, nil) }
                }
                
                if let categoriesData = try? JSONEncoder().encode(product.categories),
                   let categoriesString = String(data: categoriesData, encoding: .utf8) {
                    categoriesString.withCString { sqlite3_bind_text(insertStatement, 11, $0, -1, nil) }
                }
                
                // Bind timestamp
                sqlite3_bind_int64(insertStatement, 12, Int64(Date().timeIntervalSince1970))
                
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    print("Successfully inserted product: \(product.id)")
                }
                sqlite3_reset(insertStatement)
            }
        }
        sqlite3_finalize(insertStatement)
    }
    
    func loadProducts() -> [ProductModel] {
        var products: [ProductModel] = []
        let queryString = "SELECT * FROM products ORDER BY id DESC;"
        var queryStatement: OpaquePointer? // Optional
        
        // Prepare the query
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            // Safely unwrap the queryStatement using guard or if let
            guard let statement = queryStatement else {
                print("Query preparation failed: queryStatement is nil")
                return products
            }
            
            // Execute the query
            while sqlite3_step(statement) == SQLITE_ROW {
                if let product = extractProduct(from: statement) { // Pass the unwrapped statement
                    products.append(product)
                }
            }
            
            // Finalize the statement
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare query: \(queryString)")
        }
        
        return products
    }
    
    private func extractProduct(from statement: OpaquePointer) -> ProductModel? {
        guard let id = Int32(exactly: sqlite3_column_int(statement, 0)) else { return nil }
        
        let name = String(cString: sqlite3_column_text(statement, 1))
        let price = String(cString: sqlite3_column_text(statement, 2))
        let regularPrice = sqlite3_column_text(statement, 3).map { String(cString: $0) }
        let salePrice = sqlite3_column_text(statement, 4).map { String(cString: $0) }
        let onSale = sqlite3_column_int(statement, 5) != 0
        let description = String(cString: sqlite3_column_text(statement, 6))
        let stockStatus = String(cString: sqlite3_column_text(statement, 7))
        let stockQuantity = Int(sqlite3_column_int(statement, 8))
        
        // Safely decode JSON arrays
        var images: [ProductImage] = []
        var categories: [CategoryModel] = []
        
        if let imagesText = sqlite3_column_text(statement, 9).map({ String(cString: $0) }),
           let imagesData = imagesText.data(using: .utf8) {
            images = (try? JSONDecoder().decode([ProductImage].self, from: imagesData)) ?? []
        }
        
        if let categoriesText = sqlite3_column_text(statement, 10).map({ String(cString: $0) }),
           let categoriesData = categoriesText.data(using: .utf8) {
            categories = (try? JSONDecoder().decode([CategoryModel].self, from: categoriesData)) ?? []
        }
        
        return ProductModel(
            id: Int(id),
            name: name,
            price: price,
            regularPrice: regularPrice,
            salePrice: salePrice,
            onSale: onSale,
            description: description,
            images: images,
            categories: categories,
            stockStatus: stockStatus,
            stockQuantity: stockQuantity
        )
    }
    
    func clearProducts() {
        let deleteString = "DELETE FROM products;"
        var deleteStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteString, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted all products")
            }
        }
        sqlite3_finalize(deleteStatement)
    }
} 
