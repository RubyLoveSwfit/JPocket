//
//  UserProfileModel.swift
//  JPocket
//
//  Created by Ruby on 14/12/2024.
//

import Foundation

struct UserProfileModel: Codable {
    let id: Int
    let name: String
    let email: String
    let firstName: String
    let lastName: String
    let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case avatarUrl = "avatar_url"
    }
} 
