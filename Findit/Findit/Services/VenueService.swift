//
//  VenueService.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import Foundation

protocol VenueServiceProtocol {
    func fetchVenues() async throws -> [Venue]
    func fetchVenuePerformances(venueId: Int, from: Date, to: Date) async throws -> [VenuePerformance]
}

final class VenueService: VenueServiceProtocol {
    private var httpClient: HTTPClientProtocol {
        Servers.leapInterview.httpClient()
    }
    
    func fetchVenues() async throws -> [Venue] {
        let endpoint = VenuesEndpoint()
        return try await self.httpClient.fetch(endpoint: endpoint)
    }
    
    func fetchVenuePerformances(venueId: Int, from: Date, to: Date) async throws -> [VenuePerformance] {
        let dateFormmater = DateFormatter.formatter(for: .apiQueryFormat)
        let endpoint = VenuesPerformancesEndpoint(venueId: venueId, from: dateFormmater.string(from: from), to: dateFormmater.string(from: to))
        return try await self.httpClient.fetch(endpoint: endpoint)
    }
}
