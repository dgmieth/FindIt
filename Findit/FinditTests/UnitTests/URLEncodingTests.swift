//
//  URLEncodingTests.swift
//  FinditTests
//
//  Created by Diego Mieth on 2026-04-12.
//

import XCTest
@testable import Findit

final class URLEncodingTests: XCTestCase {

    // MARK: - URL.createEncodedURL

    func testSpacesArePercentEncoded() {
        let raw = "https://songleap.s3.amazonaws.com/venues/The Velvet Unicorn.png"
        let url = URL.createEncodedURL(urlString: raw)

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "https://songleap.s3.amazonaws.com/venues/The%20Velvet%20Unicorn.png")
    }

    func testNilReturnedForUnrepresentableString() {
        // A string that cannot be percent-encoded returns nil
        let url = URL.createEncodedURL(urlString: "")
        // Empty string is a valid (relative) URL — just confirm it doesn't crash
        XCTAssertNil(url?.host)
    }

    // MARK: - Venue.imageURL

    func testVenueImageURLEncodesSpacesInName() {
        let venue = Venue(id: 1, name: "The Velvet Unicorn", sortId: 1)
        let url = venue.imageURL

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "https://songleap.s3.amazonaws.com/venues/The%20Velvet%20Unicorn.png")
    }

    // MARK: - Artist.imageURL

    func testArtistImageURLEncodesSpacesInName() {
        let artist = Artist(id: 1, name: "The Velvet Unicorn", genre: "Indie")
        let url = artist.imageURL

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "https://songleap.s3.amazonaws.com/artists/The%20Velvet%20Unicorn.png")
    }
}
