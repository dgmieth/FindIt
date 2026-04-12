//
//  HTTPClient.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import Foundation

protocol HTTPClientProtocol: Sendable {
    func fetch<T: Decodable & Sendable>(endpoint: EndpointProtocol) async throws -> T
}

actor HTTPClient: HTTPClientProtocol {
    private let server: Servers
    private let session: URLSession
    private let decoder: JSONDecoder
    
    public init(server: Servers, urlSession: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.server = server
        self.session = urlSession
        self.decoder = decoder
    }
    
    func fetch<T: Decodable & Sendable>(endpoint: EndpointProtocol) async throws -> T {
        guard let request = endpoint.generateRequest(for: self.server.getServerAddress())
        else {
            throw APIError.invalidURL
        }

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
