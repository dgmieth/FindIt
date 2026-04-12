//
//  ArtistDetailViewModel.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-09.
//

import Foundation

@MainActor
final class ArtistDetailViewModel: ObservableObject {
    @Published var performances: [ArtistPerformance] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() { }

    func loadPerformances(for artist: Artist) async {
        self.isLoading = true
        self.errorMessage = nil
        
        let today = Date()
        let twoWeeksLater = Calendar.current.date(byAdding: .day, value: 14, to: today) ?? today
        
        do {
            performances = try await Services.artistService.fetchArtistPerformances(
                artistId: artist.id,
                from: today,
                to: twoWeeksLater
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
