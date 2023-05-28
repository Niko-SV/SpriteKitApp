//
//  NetworkService.swift
//  SpriteKitApp
//
//  Created by NikoS on 26.05.2023.
//

import Foundation

protocol Network {
    typealias Handler = (Data?, URLResponse?, Error?) -> Void
    
    func performRequest(for path: String, completionHandler: @escaping Handler)
}

extension URLSession: Network {
    typealias Handler = Network.Handler
    
    func performRequest(for path: String, completionHandler: @escaping Handler) {
        guard let url = URL(string: path) else { return }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
        task.resume()
    }
}

class NetworkService {
    enum Result {
        case success(Decodable)
        case error(Error)
    }
    
    private let netwotk: Network
    
    init(netwotk: Network = URLSession.shared) {
        self.netwotk = netwotk
    }
    
    func fetch<T: Decodable>(from path: String, model: T.Type, completionHandler: @escaping (Result) -> Void) {
        netwotk.performRequest(for: path) { (data, response, error) in
            if let error = error {
                return completionHandler(.error(error))
            }
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try decoder.decode(T.self, from: data)
                
                completionHandler(.success(decodedData))
            } catch let error{
                return completionHandler(.error(error))
            }
            
        }
    }
    
}
