//
//  NetworkRequest.swift
//  CoreDataWithCodable
//
//  Created by Gagan  Vishal on 8/11/20.
//

import Foundation
import Combine
import UIKit
protocol NetworkAPI {
    func fetchRequest<T: Codable>(from urlString: String, model: T.Type, topLevelDecoder: JSONDecoder) -> AnyPublisher<T, CutomError>
}

class NetworkRequest: NetworkAPI {
    //MARK:- Fetch request
    func fetchRequest<T: Codable>(from urlString: String, model: T.Type, topLevelDecoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, CutomError> {
        guard let url = URL(string: urlString) else {
            return Fail(error: CutomError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map{$0.data}
            .decode(type: T.self, decoder: topLevelDecoder)
            .mapError{CutomError.map(error: $0)}
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    //MARK:- Get image from URL
    class func imagePublisher(for urlString: String) -> AnyPublisher<UIImage, CutomError> {
        guard let url = URL(string: urlString) else {
            return Fail(error: CutomError.invalidURL)
                .eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .compactMap { UIImage(data: $0.data) }
            .mapError{CutomError.map(error: $0)}
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
