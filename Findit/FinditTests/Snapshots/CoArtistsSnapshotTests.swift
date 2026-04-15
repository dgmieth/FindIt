//
//  CoArtistsSnapshotTests.swift
//  FinditTests
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import Findit

@MainActor
final class CoArtistsSnapshotTests: XCTestCase {

    private var sampleImage: UIImage { MockData.sampleImage }

    // MARK: - CoArtistsSheetView

    func testCoArtistsLoaded() {
        let vm = CoArtistsSheetViewModel(
            venue: MockData.performanceVenue,
            performances: MockData.venuePerformances
        )
        let view = CoArtistsSheetView(viewModel: vm)
            .environment(\.testImageOverride, sampleImage)
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecordMode.recording)
    }

    func testCoArtistsLoading() {
        let vm = CoArtistsSheetViewModel(
            venue: MockData.performanceVenue,
            performances: [],
            isLoading: true
        )
        let view = CoArtistsSheetView(viewModel: vm)
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecordMode.recording)
    }

    func testCoArtistsError() {
        let vm = CoArtistsSheetViewModel(
            venue: MockData.performanceVenue,
            performances: [],
            errorMessage: "Failed to load artists."
        )
        let view = CoArtistsSheetView(viewModel: vm)
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecordMode.recording)
    }

    func testCoArtistsEmpty() {
        let vm = CoArtistsSheetViewModel(
            venue: MockData.performanceVenue,
            performances: []
        )
        let view = CoArtistsSheetView(viewModel: vm)
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecordMode.recording)
    }
}
