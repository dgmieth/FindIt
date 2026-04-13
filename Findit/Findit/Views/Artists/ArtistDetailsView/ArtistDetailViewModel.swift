//
//  ArtistDetailViewModel.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-09.
//

import Foundation
import Combine

@MainActor
final class ArtistDetailViewModel: ObservableObject {
    @Published var performances: [ArtistPerformance] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var filterSelection: FilterOptions = .next14Days
    @Published var startDate: Date?
    @Published var endDate: Date?
    
    let artist: Artist
    
    private var initialLoad = true
    
    private var cancellable: AnyCancellable?
    
    init(artist: Artist) {
        self.artist = artist
        
        self.cancellable = self.$filterSelection
            .receive(on: DispatchQueue.main)
            .sink { _ in
                Task {
                    await self.loadPerformances()
                }
            }
    }
    
    func updateViewModel(_ filterSelection: FilterOptions, _ startDate: Date?, _ endDate: Date?) {
        self.startDate = startDate
        self.endDate = endDate
        self.filterSelection = filterSelection
    }

    func loadPerformances() async {
        switch self.filterSelection {
        case .next14Days:
            // AC -> The detail will contain all the performances for that entity for the current day and the following two weeks.
            let today = Date()
            let twoWeeksLater = Calendar.current.date(byAdding: .day, value: 14, to: today) ?? today
            await self.filterPerformances(startDate: today, endDate: twoWeeksLater)
        case .next30Days:
            let today = Date()
            let twoWeeksLater = Calendar.current.date(byAdding: .day, value: 30, to: today) ?? today
            await self.filterPerformances(startDate: today, endDate: twoWeeksLater)
        case .next60Days:
            let today = Date()
            let twoWeeksLater = Calendar.current.date(byAdding: .day, value: 60, to: today) ?? today
            await self.filterPerformances(startDate: today, endDate: twoWeeksLater)
        case .custom:
            await self.filterPerformances(startDate: self.startDate, endDate: self.endDate)
        }
        
        self.initialLoad = false
    }
    
    private func filterPerformances(startDate: Date?, endDate: Date?) async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            self.performances = try await Services.artistService.fetchArtistPerformances(
                artistId: self.artist.id,
                from: startDate,
                to: endDate
            )
            // AC -> The performances must obviously be shown in order of date and time
            .sorted(by: { $0.parsedDate ?? .now < $1.parsedDate  ?? .now })
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        self.isLoading = false
    }
}
