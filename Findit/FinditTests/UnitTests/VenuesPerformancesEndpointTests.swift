//
//  VenuesPerformancesEndpointTests.swift
//  FinditTests
//
//  Created by Diego Mieth on 2026-04-12.
//

import XCTest
@testable import Findit

final class VenuesPerformancesEndpointTests: XCTestCase {
    private let baseURL = "https://api.leapmobileinterview.com"
    private let formatter = DateFormatter.formatter(for: .apiQueryFormat)

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)!
    }

    func testPathContainsVenueId() {
        let endpoint = VenuesPerformancesEndpoint(venueId: 99)
        XCTAssertEqual(endpoint.path, "/venues/99/performances")
    }

    func testNoDatesProducesNilQueryParams() {
        let endpoint = VenuesPerformancesEndpoint(venueId: 1)
        XCTAssertNil(endpoint.queryParams)
    }

    func testFromDateOnly() {
        let from = makeDate(year: 2026, month: 6, day: 15)
        let endpoint = VenuesPerformancesEndpoint(venueId: 1, from: from)
        let params = endpoint.queryParams

        XCTAssertNotNil(params)
        XCTAssertEqual(params?["from"], formatter.string(from: from))
        XCTAssertNil(params?["to"])
    }

    func testToDateOnly() {
        let to = makeDate(year: 2026, month: 6, day: 30)
        let endpoint = VenuesPerformancesEndpoint(venueId: 1, to: to)
        let params = endpoint.queryParams

        XCTAssertNotNil(params)
        XCTAssertNil(params?["from"])
        XCTAssertEqual(params?["to"], formatter.string(from: to))
    }

    func testBothDates() {
        let from = makeDate(year: 2026, month: 6, day: 15)
        let to = makeDate(year: 2026, month: 6, day: 30)
        let endpoint = VenuesPerformancesEndpoint(venueId: 1, from: from, to: to)
        let params = endpoint.queryParams

        XCTAssertNotNil(params)
        XCTAssertEqual(params?["from"], formatter.string(from: from))
        XCTAssertEqual(params?["to"], formatter.string(from: to))
    }

    func testGeneratedRequestHasCorrectPath() {
        let endpoint = VenuesPerformancesEndpoint(venueId: 3)
        let request = endpoint.generateRequest(for: baseURL)

        XCTAssertNotNil(request)
        XCTAssertEqual(request?.url?.path, "/venues/3/performances")
    }
}
