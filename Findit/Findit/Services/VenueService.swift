//
//  VenueService.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import Foundation

protocol VenueServiceProtocol {
    func fetchVenues() async throws -> [Venue]
    func fetchVenuePerformances(venueId: Int, from: Date?, to: Date?) async throws -> [VenuePerformance]
}

final class VenueService: VenueServiceProtocol {
    private var httpClient: HTTPClientProtocol {
        Servers.leapInterview.httpClient()
    }
    
    func fetchVenues() async throws -> [Venue] {
        let endpoint = VenuesEndpoint()
        return try await self.httpClient.fetch(endpoint: endpoint)
    }
    
    func fetchVenuePerformances(venueId: Int, from: Date?, to: Date?) async throws -> [VenuePerformance] {
        let endpoint = VenuesPerformancesEndpoint(venueId: venueId, from: from, to: to)
        return try await self.httpClient.fetch(endpoint: endpoint)
    }
}
