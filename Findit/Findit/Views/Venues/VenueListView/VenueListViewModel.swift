//
//  VenueListViewModel.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-09.
//

import Foundation

@MainActor
final class VenueListViewModel: ObservableObject {
    @Published var venues: [Venue] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() { }

    func loadVenues() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            // AC ->  Venues will be displayed in order of their sortId
            self.venues = try await Services.venueService.fetchVenues()
                .sorted { $0.sortId < $1.sortId }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        self.isLoading = false
    }
}
