//
//  GameNetworkManager.swift
//  SpriteKitApp
//
//  Created by NikoS on 26.05.2023.
//

import Foundation

final class GameNetworkManager {
    
    private let service = NetworkService()
    
    func getFinishURL(completionHandler: @escaping (ResultNetworkingURLModel?) -> Void) {
        service.fetch(from: Constants.resultPathURL, model: ResultNetworkingURLModel.self) {(result: NetworkService.Result) in
            switch result {
            case let .success(value):
                let fetchResult = value as? ResultNetworkingURLModel
                completionHandler(fetchResult)
            case .error(_):
                print("Ooops, there's an error")
            }
        }
    }
}
