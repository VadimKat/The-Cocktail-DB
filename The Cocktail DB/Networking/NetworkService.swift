//
//  NetworkService.swift
//  The Cocktail DB
//
//  Created by Vadim Katenin on 22.06.2020.
//  Copyright © 2020 Vadim Katenin. All rights reserved.
//

import Foundation
import Moya

private let url: String = "https://www.thecocktaildb.com/api/json/v1/1/"

enum CocktailService {
    case loadCategories
    case loadByCategory(category: String)
}

extension CocktailService: TargetType {
    
    var baseURL: URL {
        return URL(string: url)!
    }
    
    var path: String {
        switch self {
            
        case .loadCategories:
            return "list.php"
            
        case .loadByCategory(_):
            return "filter.php"
        }
    }
    
    var method: Moya.Method {
        switch self {
            
        case .loadCategories, .loadByCategory(_):
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
            
        case .loadCategories:
            return .requestParameters(
                parameters: ["c" : "list"],
                encoding: URLEncoding.default)
            
        case .loadByCategory(let category):
            return .requestParameters(
                parameters: ["c" : "\(category)"],
                encoding: URLEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
