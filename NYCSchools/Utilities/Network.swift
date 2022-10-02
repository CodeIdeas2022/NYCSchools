//
//  Network.swift
//  Utilities
//
//  Created by M1Pro on 9/30/22.
//

import Foundation
import Combine

public class Network {
    public static let `default` = Network()
    fileprivate let session: URLSession    
    // Singleton
    private  init() {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = Constants.networkTimeout
        config.requestCachePolicy = .useProtocolCachePolicy
        config.urlCache = URLCache.shared
        self.session = URLSession(configuration: config)
        return
        
    }
}

public extension Network {
    
    
}

extension Network {
    public func fetch<T: Decodable>(_ url: URL) -> AnyPublisher<T,Error> {
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        return session.dataTaskPublisher(for: request)
            .tryMap({ data, response -> Data in
                if let response = response as? HTTPURLResponse, !Constants.httpSuccessRange.contains(response.statusCode) {
                    throw NSError(domain: NSURLErrorDomain, code: response.statusCode)
                }
                return data
            })
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

fileprivate extension Network {
    struct Constants {
        static let networkTimeout = 300.0
        static let httpSuccessRange = (200..<300)
    }
}
