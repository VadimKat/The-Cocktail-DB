//
//  CocktailModels.swift
//  The Cocktail DB
//
//  Created by Vadim Katenin on 22.06.2020.
//  Copyright © 2020 Vadim Katenin. All rights reserved.
//

import Foundation

struct Cocktail: Codable {
    let name: String
    let thumbUrl: URL
    
    enum CodingKeys: String, CodingKey {
        case name = "strDrink"
        case thumbUrl = "strDrinkThumb"
    }
}

struct CocktailResponce: Codable {
    let cocktails: [Cocktail]
    
    enum CodingKeys: String, CodingKey {
        case cocktails = "drinks"
    }
}
