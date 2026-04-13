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
    
    init() { }

    // MARK: - Testing Support
    init(artists: [Artist]) {
        self.artists = artists
        self.isLoading = false
    }

    func loadArtists() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            // AC -> Artists must be displayed in alphabetical order by name
            self.artists = try await Services.artistService.fetchArtists()
                .sorted { $0.name < $1.name }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        self.isLoading = false
    }
}
