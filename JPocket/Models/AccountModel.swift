//
//  AccountModel.swift
//  JPocket
//
//  Created by Ruby on 13/12/2024.
//

import Foundation

struct AccountModel: Codable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let username: String
    let avatarUrl: String?
    let role: String
    var isAuthenticated: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case avatarUrl = "avatar_url"
        case role
        case isAuthenticated
    }
}
