//
//  APIService.swift
//  JPocket
//
//  Created by Ruby on 13/12/2024.
//

import Foundation

class WooCommerceService {
    let baseURL = APIConfig.baseURL
    let consumerKey = APIConfig.consumerKey
    let consumerSecret = APIConfig.consumerSecret
    
    static let shared = WooCommerceService()
    
    private func createAuthRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        let loginString = "\(consumerKey):\(consumerSecret)"
        guard let loginData = loginString.data(using: .utf8) else {
            return request
        }
        
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }

    func getCategories(page: Int = 1, perPage: Int = 100) async throws -> [CategoryModel] {
        var components = URLComponents(string: "\(baseURL)/products/categories")!
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "orderby", value: "name"),
            URLQueryItem(name: "order", value: "asc")
        ]
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        let request = createAuthRequest(for: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Categories Response: \(jsonString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.networkError
        }
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([CategoryModel].self, from: data)
        case 401:
            throw NetworkError.authenticationError
        case 403:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError(httpResponse.statusCode)
        }
    }
    func getAllProducts() async throws -> [ProductModel] {
        var allProducts: [ProductModel] = []
        var currentPage = 1
        let perPage = 100 // Maximum allowed by WooCommerce
        var hasMorePages = true
        
        while hasMorePages {
            var components = URLComponents(string: "\(baseURL)/products")!
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(currentPage)"),
                URLQueryItem(name: "per_page", value: "\(perPage)"),
                URLQueryItem(name: "status", value: "publish"),
                URLQueryItem(name: "orderby", value: "date"),
                URLQueryItem(name: "order", value: "desc")
            ]
            
            guard let url = components.url else {
                throw NetworkError.invalidURL
            }
            
            let request = createAuthRequest(for: url)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.networkError
            }
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let products = try decoder.decode([ProductModel].self, from: data)
                
                // Add products from this page
                allProducts.append(contentsOf: products)
                
                // Check if we have more pages
                if let totalPages = httpResponse.value(forHTTPHeaderField: "X-WP-TotalPages"),
                   let totalPagesInt = Int(totalPages) {
                    hasMorePages = currentPage < totalPagesInt
                } else {
                    // If we can't get total pages, check if we got a full page
                    hasMorePages = products.count == perPage
                }
                
                // Move to next page
                currentPage += 1
                
                // Add a small delay to avoid rate limiting
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
            case 401:
                throw NetworkError.authenticationError
            case 403:
                throw NetworkError.unauthorized
            default:
                throw NetworkError.serverError(httpResponse.statusCode)
            }
        }
        
        return allProducts
    }
    
    func getBestSellingProducts(page: Int = 1, perPage: Int = 100)  async throws -> [ProductModel] {
            var components = URLComponents(string: "\(baseURL)/products")!
            components.queryItems = [
                URLQueryItem(name: "category", value: String(APIConfig.HotTopSellerID)),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
            
            guard let url = components.url else {
                throw NetworkError.invalidURL
            }
            
            let request = createAuthRequest(for: url)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.networkError
            }
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode([ProductModel].self, from: data)
            case 401:
                throw NetworkError.authenticationError
            case 403:
                throw NetworkError.unauthorized
            default:
                throw NetworkError.serverError(httpResponse.statusCode)
            }
    }
    
    func getProducts(page: Int = 1, perPage: Int = 100) async throws -> [ProductModel] {
        var components = URLComponents(string: "\(baseURL)/products")!
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        let request = createAuthRequest(for: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.networkError
        }
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([ProductModel].self, from: data)
        case 401:
            throw NetworkError.authenticationError
        case 403:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError(httpResponse.statusCode)
        }
    }
    
    func signIn(email: String, password: String) async throws -> String {
        var components = URLComponents(string: "\(baseURL)/auth/login")!
        
        // Create request
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create body
        let body = [
            "username": email,
            "password": password
        ]
        
        request.httpBody = try? JSONEncoder().encode(body)
        
        // Make request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.networkError
        }
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            struct LoginResponse: Codable {
                let token: String
                let userEmail: String
            }
            
            let loginResponse = try decoder.decode(LoginResponse.self, from: data)
            return loginResponse.token
            
        case 401:
            throw NetworkError.authenticationError
        case 403:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError(httpResponse.statusCode)
        }
    }
    
    func resetPassword(email: String) async throws {
        var components = URLComponents(string: "\(baseURL)/auth/reset-password")!
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email]
        request.httpBody = try? JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.networkError
        }
        
        switch httpResponse.statusCode {
        case 200:
            return
        case 404:
            throw NetworkError.userNotFound
        default:
            throw NetworkError.serverError(httpResponse.statusCode)
        }
    }
    
    func register(email: String, password: String, firstName: String, lastName: String) async throws -> String {
        var components = URLComponents(string: "\(baseURL)/auth/register")!
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "email": email,
            "password": password,
            "first_name": firstName,
            "last_name": lastName
        ]
        
        request.httpBody = try? JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.networkError
        }
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            struct RegisterResponse: Codable {
                let token: String
                let userEmail: String
            }
            
            let registerResponse = try decoder.decode(RegisterResponse.self, from: data)
            return registerResponse.token
            
        case 400:
            throw NetworkError.validationError("Email already exists")
        case 401:
            throw NetworkError.authenticationError
        default:
            throw NetworkError.serverError(httpResponse.statusCode)
        }
    }
    
    func createOrder(_ orderRequest: OrderRequest) async throws -> OrderModel {
        var components = URLComponents(string: "\(baseURL)/orders")!
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = createAuthRequest(for: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode the order request
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(orderRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.networkError
        }
        
        switch httpResponse.statusCode {
        case 200, 201:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(OrderModel.self, from: data)
        case 401:
            throw NetworkError.authenticationError
        case 403:
            throw NetworkError.unauthorized
        default:
            if let errorString = String(data: data, encoding: .utf8) {
                print("Order creation error: \(errorString)")
            }
            throw NetworkError.serverError(httpResponse.statusCode)
        }
    }
    
    func getOrders(email: String) async throws -> [OrderModel] {
        var components = URLComponents(string: "\(baseURL)/orders")!
        components.queryItems = [URLQueryItem(name: "customer", value: email)]
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        let request = createAuthRequest(for: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.networkError
        }
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([OrderModel].self, from: data)
        case 401:
            throw NetworkError.authenticationError
        case 403:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError(httpResponse.statusCode)
        }
    }
    
    // Add other API methods here
}

enum NetworkError: Error {
    case invalidURL
    case decodingError
    case networkError
    case authenticationError
    case unauthorized
    case serverError(Int)
    case userNotFound
    case validationError(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .decodingError:
            return "Failed to decode response"
        case .networkError:
            return "Network error occurred"
        case .authenticationError:
            return "Authentication failed"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError(let code):
            return "Server error: \(code)"
        case .userNotFound:
            return "User not found"
        case .validationError(let message):
            return message
        }
    }
} 
