//
//  VenueListViewModel.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-09.
//

import Foundation

enum VenueSortOrder {
    case sortId
    case name
}

@MainActor
final class VenueListViewModel: ObservableObject {
    @Published var venues: [Venue] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var sortOrder: VenueSortOrder = .sortId
    
    init() { }

    // MARK: - Testing Support
    init(venues: [Venue]) {
        self.venues = venues
        self.isLoading = false
    }

    func loadVenues() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            self.venues = try await Services.venueService.fetchVenues()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        self.isLoading = false
    }
}
