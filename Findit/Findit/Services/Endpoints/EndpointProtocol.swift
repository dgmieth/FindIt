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
        guard let url = URL(string: serverAddress + self.path) else {
            return nil
        }
        
        let urlParams = self.queryParams?.compactMap {
            URLQueryItem(name: $0.key, value: $0.value)
        } ?? []
        
        return URLRequest(url: url.appending(queryItems: urlParams))
    }
}
