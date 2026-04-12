//
//  HTTPClient.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import Foundation

protocol HTTPClientProtocol {
    func fetch<T: Decodable>(endpoint: EndpointProtocol) async throws -> T
}

final class HTTPClient: HTTPClientProtocol {
    private let server: Servers
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(server: Servers, urlSession: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.server = server
        self.session = urlSession
        self.decoder = decoder
    }
    
    func fetch<T: Decodable>(endpoint: EndpointProtocol) async throws -> T {
        guard let url = URL(string: self.server.getServerAddress() + endpoint.path) else {
            throw APIError.invalidURL
        }

        let request = self.createRequest(for: url, endpoint: endpoint)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let http = response as? HTTPURLResponse else {
                throw APIError.invalidResponse(statusCode: -1)
            }
            guard (200...299).contains(http.statusCode) else {
                throw APIError.invalidResponse(statusCode: http.statusCode)
            }
            return try decoder.decode(T.self, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    private func createRequest(for url: URL, endpoint: EndpointProtocol) -> URLRequest {
        let urlParams = endpoint.queryParams?.compactMap {
            URLQueryItem(name: $0.key, value: $0.value)
        } ?? []
        
        return URLRequest(url: url.appending(queryItems: urlParams))
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse(let code):
            return "Server returned status code \(code)."
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
