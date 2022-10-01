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
    
    fileprivate let sessionDelegate = SessionDelegate()
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


class SessionDelegate: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse) async -> CachedURLResponse? {
        print("cached  delegate called")
        return proposedResponse
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse) async -> URLSession.ResponseDisposition {
        return .allow
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
    }
}
