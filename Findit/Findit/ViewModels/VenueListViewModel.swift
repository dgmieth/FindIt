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

    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }

    func loadVenues() async {
        isLoading = true
        errorMessage = nil
        do {
            venues = try await apiService.fetchVenues()
                .sorted { $0.sortId < $1.sortId }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
