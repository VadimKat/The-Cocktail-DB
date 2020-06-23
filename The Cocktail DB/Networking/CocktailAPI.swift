//
//  CocktailAPI.swift
//  The Cocktail DB
//
//  Created by Vadim Katenin on 22.06.2020.
//  Copyright © 2020 Vadim Katenin. All rights reserved.
//

import Foundation
import Moya

class CocktailAPI {
    
    private let provider = MoyaProvider<CocktailService>()
    
    enum APIError: Error {
        case responseFailure, jsonDecoderFailure
    }
    
    // MARK: - Fetching Category
    func fetchCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        
        provider.request(.loadCategories) { result in
            
            switch result {
            case .success(let resp):
                
                guard let response = resp.response, 200..<300 ~= response.statusCode else {
                    completion(.failure(APIError.responseFailure))
                    return
                }
                
                guard let categoriesResponce = try? JSONDecoder().decode(CategoryResponce.self, from: resp.data) else {
                    completion(.failure(APIError.jsonDecoderFailure))
                    return
                }
                
                DispatchQueue.main.async {
                    completion(.success(categoriesResponce.categories))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    //MARK: Fetching Cocktail
    
    func fetchCocktails(category: String, completion: @escaping (Result<[Cocktail], Error>) -> Void) {
        
        provider.request(.loadByCategory(category: category)) { result in
            
            switch result {
            case .success(let resp):
                
                guard let response = resp.response, 200..<300 ~= response.statusCode else {
                    completion(.failure(APIError.responseFailure))
                    return
                }
                
                guard let cocktailsResponce = try? JSONDecoder().decode(CocktailResponce.self, from: resp.data) else {
                    completion(.failure(APIError.jsonDecoderFailure))
                    return
                }
                
                DispatchQueue.main.async {
                    completion(.success(cocktailsResponce.cocktails))
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
