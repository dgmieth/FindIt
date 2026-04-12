//
//  Services.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import Foundation

final class Services {
    nonisolated(unsafe) private static let instance = Services()
    
    init() {
        self._artistService = ArtistService()
        self._venueService = VenueService()
        self._imageService = ImageService()
    }
    
    // services
    private let _venueService: VenueServiceProtocol
    private let _artistService: ArtistServiceProtocol
    private let _imageService: ImageServiceProtocol
    
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
    
    static var imageService: ImageServiceProtocol {
        get {
            return Self.instance._imageService
        }
    }
}
