//
//  ArtistDetailViewModel.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-09.
//

import Foundation

enum ArtistDetailSortOrder {
    case date
    case venueName
}

@MainActor
final class ArtistDetailViewModel: ObservableObject {
    @Published var performances: [ArtistPerformance] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var sortOrder: ArtistDetailSortOrder = .date
    
    @Published var filterSelection: FilterOptions = .next14Days
    var startDate: Date?
    var endDate: Date?
    
    let artist: Artist
    
    var titleForResults: String {
        if self.filterSelection == .custom {
            switch (self.startDate, self.endDate) {
            case (.some(let startDate), .some(let endDate)):
                let startDateString = DateFormatter.formatter(for: .apiQueryFormat).string(from: startDate)
                let endDateString = DateFormatter.formatter(for: .apiQueryFormat).string(from: endDate)
                return R.string.localizable.viewsFilterOptionLowerUpperBounds(startDateString, endDateString)
            case (.some(let startDate), _):
                let startDateString = DateFormatter.formatter(for: .apiQueryFormat).string(from: startDate)
                return R.string.localizable.viewsFilterOptionOnlyLowerBound(startDateString)
            case (_, .some(let endDate)):
                let endDateString = DateFormatter.formatter(for: .apiQueryFormat).string(from: endDate)
                return R.string.localizable.viewsFilterOptionOnlyUpperBound(endDateString)
            default: return ""
            }
        }
        return self.filterSelection.rawValue
    }
    
    init(artist: Artist) {
        self.artist = artist
    }

    // MARK: - Testing Support
    init(artist: Artist, performances: [ArtistPerformance], isLoading: Bool = false, errorMessage: String? = nil) {
        self.artist = artist
        self.performances = performances
        self.isLoading = isLoading
        self.errorMessage = errorMessage
    }
    
    func updateViewModel(_ filterSelection: FilterOptions, _ startDate: Date?, _ endDate: Date?) {
        self.startDate = startDate
        self.endDate = endDate
        self.filterSelection = filterSelection
        
        Task {
            await self.loadPerformances()
        }
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
            let monthLater = Calendar.current.date(byAdding: .day, value: 30, to: today) ?? today
            await self.filterPerformances(startDate: today, endDate: monthLater)
        case .next60Days:
            let today = Date()
            let twoMonthsLater = Calendar.current.date(byAdding: .day, value: 60, to: today) ?? today
            await self.filterPerformances(startDate: today, endDate: twoMonthsLater)
        case .custom:
            await self.filterPerformances(startDate: self.startDate, endDate: self.endDate)
        }
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
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        self.isLoading = false
    }
}
