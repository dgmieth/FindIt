//
//  Services.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import Foundation

final class Services {
    private static let instance = Services()
    
    init() {
        self._artistService = ArtistService()
        self._venueService = VenueService()
    }
    
    // services
    private let _venueService: VenueServiceProtocol
    private let _artistService: ArtistServiceProtocol
    
    // exposed services
    static var artistService: ArtistServiceProtocol {
        get {
            return Self.instance._artistService
        }
    }
    
    static var venueService: VenueServiceProtocol {
        get {
            return Self.instance._venueService
        }
    }
}
