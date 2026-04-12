//  ArtistListViewModel.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-09.
//

import SwiftUI

@MainActor
final class ArtistListViewModel: ObservableObject {
    @Published var artists: [Artist] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }

    func loadArtists() async {
        isLoading = true
        errorMessage = nil
        do {
            artists = try await apiService.fetchArtists()
                .sorted { $0.name < $1.name }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
