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

    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }

    func loadPerformances(for artist: Artist) async {
        isLoading = true
        errorMessage = nil
        let today = Date()
        let twoWeeksLater = Calendar.current.date(byAdding: .day, value: 14, to: today) ?? today
        do {
            performances = try await apiService.fetchArtistPerformances(
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
