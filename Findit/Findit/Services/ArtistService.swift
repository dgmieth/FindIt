//
//  ArtistService.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import Foundation

protocol ArtistServiceProtocol {
    func fetchArtists() async throws -> [Artist]
    func fetchArtistPerformances(artistId: Int, from: Date, to: Date) async throws -> [ArtistPerformance]
}

final class ArtistService: ArtistServiceProtocol {
    private var httpClient: HTTPClientProtocol {
        Servers.leapInterview.httpClient()
    }
    
    func fetchArtists() async throws -> [Artist] {
        let endpoint = ArtistsEndpoint()
        return try await self.httpClient.fetch(endpoint: endpoint)
    }
    
    func fetchArtistPerformances(artistId: Int, from: Date, to: Date) async throws -> [ArtistPerformance] {
        let dateFormmater = DateFormatter.formatter(for: .apiQueryFormat)
        let endpoint = ArtistsPerformancesEndpoint(artistId: artistId, from: dateFormmater.string(from: from), to: dateFormmater.string(from: to))
        return try await self.httpClient.fetch(endpoint: endpoint)
    }
}
