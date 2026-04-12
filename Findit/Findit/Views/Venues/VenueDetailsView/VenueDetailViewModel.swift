//
//  VenueDetailViewModel.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-09.
//

import Foundation

@MainActor
final class VenueDetailViewModel: ObservableObject {
    @Published var performances: [VenuePerformance] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() { }

    func loadPerformances(for venue: Venue) async {
        self.isLoading = true
        self.errorMessage = nil
        
        let today = Date()
        let twoWeeksLater = Calendar.current.date(byAdding: .day, value: 14, to: today) ?? today
        
        do {
            self.performances = try await Services.venueService.fetchVenuePerformances(
                venueId: venue.id,
                from: today,
                to: twoWeeksLater
            )
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        self.isLoading = false
    }
}
