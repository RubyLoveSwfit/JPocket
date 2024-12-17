//
//  CategoryModel.swift
//  JPocket
//
//  Created by Ruby on 12/12/2024.
//

import Foundation

struct CategoryModel: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    private let name: String
    let slug: String
    let image: CategoryImage?
    let parent: Int?
    let count: Int?
    
    var displayName: String {
        name.replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&#038;", with: "&")
            .replacingOccurrences(of: "&#8211;", with: "-")
    }
    
    static func == (lhs: CategoryModel, rhs: CategoryModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension CategoryModel {
    var isParent: Bool {
        parent == 0 || parent == nil
    }
    
    var debugDescription: String {
        """
        Category(
            id: \(id),
            name: \(displayName),
            slug: \(slug),
            parent: \(parent ?? -1),
            count: \(count ?? 0)
        )
        """
    }
}

extension CategoryModel: CustomDebugStringConvertible {
    var description: String {
        "\(displayName) (ID: \(id), Parent: \(parent ?? -1))"
    }
}

struct CategoryImage: Codable {
    let id: Int?
    let src: String?
    let name: String?
    let alt: String?
}
