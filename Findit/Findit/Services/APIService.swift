import Foundation

// MARK: - Protocol

protocol APIServiceProtocol {
    func fetchArtists() async throws -> [Artist]
    func fetchVenues() async throws -> [Venue]
    func fetchArtistPerformances(artistId: Int, from: Date, to: Date) async throws -> [ArtistPerformance]
    func fetchVenuePerformances(venueId: Int, from: Date, to: Date) async throws -> [VenuePerformance]
}

// MARK: - Errors

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

// MARK: - Implementation

final class APIService: APIServiceProtocol {
    static let shared = APIService()

    private let baseURL = "https://api.leapmobileinterview.com"
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func fetchArtists() async throws -> [Artist] {
        try await fetch(endpoint: "/artists")
    }

    func fetchVenues() async throws -> [Venue] {
        try await fetch(endpoint: "/venues")
    }

    func fetchArtistPerformances(artistId: Int, from: Date, to: Date) async throws -> [ArtistPerformance] {
        let fromStr = DateFormatter.apiQueryFormatter.string(from: from)
        let toStr   = DateFormatter.apiQueryFormatter.string(from: to)
        return try await fetch(endpoint: "/artists/\(artistId)/performances?from=\(fromStr)&to=\(toStr)")
    }

    func fetchVenuePerformances(venueId: Int, from: Date, to: Date) async throws -> [VenuePerformance] {
        let fromStr = DateFormatter.apiQueryFormatter.string(from: from)
        let toStr   = DateFormatter.apiQueryFormatter.string(from: to)
        return try await fetch(endpoint: "/venues/\(venueId)/performances?from=\(fromStr)&to=\(toStr)")
    }

    // MARK: - Private

    private func fetch<T: Decodable>(endpoint: String) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)
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
