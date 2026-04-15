//
//  CoVenuesSnapshotTests.swift
//  FinditTests
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import Findit

@MainActor
final class CoVenuesSnapshotTests: XCTestCase {

    private var sampleImage: UIImage { MockData.sampleImage }

    // MARK: - CoVenuesSheetView

    func testCoVenuesLoaded() {
        let vm = CoVenuesSheetViewModel(
            artist: MockData.performanceArtist,
            performances: MockData.artistPerformances,
            date: Date.getDate()!
        )
        let view = CoVenuesSheetView(viewModel: vm)
            .environment(\.testImageOverride, sampleImage)
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecordMode.recording)
    }

    func testCoVenuesLoading() {
        let vm = CoVenuesSheetViewModel(
            artist: MockData.performanceArtist,
            performances: [],
            isLoading: true,
            date: Date.getDate()!
        )
        let view = CoVenuesSheetView(viewModel: vm)
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecordMode.recording)
    }

    func testCoVenuesError() {
        let vm = CoVenuesSheetViewModel(
            artist: MockData.performanceArtist,
            performances: [],
            errorMessage: "Failed to load venues.",
            date: Date.getDate()!
        )
        let view = CoVenuesSheetView(viewModel: vm)
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecordMode.recording)
    }

    func testCoVenuesEmpty() {
        let vm = CoVenuesSheetViewModel(
            artist: MockData.performanceArtist,
            performances: [],
            date: Date.getDate()!
        )
        let view = CoVenuesSheetView(viewModel: vm)
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecordMode.recording)
    }
}
