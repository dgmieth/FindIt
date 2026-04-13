//
//  MockData.swift
//  FinditTests
//
//  Created by Diego Mieth on 2026-04-12.
//

import UIKit
@testable import Findit

// Used to locate the FinditTests bundle for asset loading.
private final class TestBundleLocator {}

enum MockData {

    // MARK: - Artists

    static let artist1 = Artist(id: 1, name: "The Rolling Stones", genre: "Rock")
    static let artist2 = Artist(id: 2, name: "Adele", genre: "Pop")
    static let artists: [Artist] = [artist1, artist2]

    // MARK: - Venues

    static let venue1 = Venue(id: 1, name: "Madison Square Garden", sortId: 1)
    static let venue2 = Venue(id: 2, name: "The Forum", sortId: 2)
    static let venues: [Venue] = [venue1, venue2]

    // MARK: - Nested / embedded models

    static let performanceVenue = PerformanceVenue(id: 1, name: "Madison Square Garden", sortId: 1)
    static let performanceArtist = PerformanceArtist(id: 1, name: "The Rolling Stones", genre: "Rock")

    // MARK: - Performances

    static let artistPerformances: [ArtistPerformance] = [
        ArtistPerformance(id: 1, artistId: 1, date: "2026-04-20 20:00:00", venue: performanceVenue),
        ArtistPerformance(id: 2, artistId: 1, date: "2026-04-26 21:30:00", venue: performanceVenue),
    ]

    static let venuePerformances: [VenuePerformance] = [
        VenuePerformance(id: 1, venueId: 1, date: "2026-04-20 20:00:00", artist: performanceArtist),
        VenuePerformance(id: 2, venueId: 1, date: "2026-04-26 21:30:00", artist: performanceArtist),
    ]

    // MARK: - Sample image

    /// Returns the `sample_image` asset from `UnitTests.xcassets`, falling back
    /// to the SF Symbol "photo" so tests never crash if the asset is missing.
    static var sampleImage: UIImage {
        UIImage(named: "sample_image",
                in: Bundle(for: TestBundleLocator.self),
                compatibleWith: nil)
            ?? UIImage(systemName: "photo")!
    }
}
