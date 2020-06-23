//
//  CategoryModels.swift
//  The Cocktail DB
//
//  Created by Vadim Katenin on 22.06.2020.
//  Copyright © 2020 Vadim Katenin. All rights reserved.
//

import Foundation

struct Category: Codable, Equatable {
    let category: String
    
    enum CodingKeys: String, CodingKey {
        case category = "strCategory"
    }
}

struct CategoryResponce: Codable {
    let categories: [Category]
    
    enum CodingKeys: String, CodingKey {
        case categories = "drinks"
    }
}
