//  ArtistListViewModel.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-09.
//

import SwiftUI

enum ArtistSortOrder {
    case name
    case genre
}

@MainActor
final class ArtistListViewModel: ObservableObject {
    @Published var artists: [Artist] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var sortOrder: ArtistSortOrder = .name
    
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
            self.artists = try await Services.artistService.fetchArtists()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        self.isLoading = false
    }
}
