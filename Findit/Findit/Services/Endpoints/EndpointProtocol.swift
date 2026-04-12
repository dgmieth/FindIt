//
//  EndpointProtocol.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import Foundation

typealias QueryParams = [String: String]

protocol EndpointProtocol: Sendable {
    var path: String { get }
    var queryParams: QueryParams? { get }
}

extension EndpointProtocol {
    func generateRequest(for serverAddress: String) -> URLRequest? {
        guard var url = URL(string: serverAddress + self.path) else {
            return nil
        }
        
        if let queryParams {
            let queryItems = queryParams.compactMap {
                URLQueryItem(name: $0.key, value: $0.value)
            }
            
            url = url.appending(queryItems: queryItems)
        }
        
        return URLRequest(url: url)
    }
}
