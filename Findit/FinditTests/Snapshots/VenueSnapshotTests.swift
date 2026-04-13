//
//  VenueSnapshotTests.swift
//  FinditTests
//
//  Created by Diego Mieth on 2026-04-12.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import Findit

@MainActor
final class VenueSnapshotTests: XCTestCase {

    private var sampleImage: UIImage { MockData.sampleImage }

    // MARK: - VenueListView

    func testVenueListLoaded() {
        let vm = VenueListViewModel(venues: MockData.venues)
        let view = NavigationStack {
            VenueListView(viewModel: vm)
        }
        .environment(\.testImageOverride, sampleImage)
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecodMode.recording)
    }

    func testVenueListLoading() {
        let vm = VenueListViewModel()
        vm.isLoading = true
        let view = NavigationStack {
            VenueListView(viewModel: vm)
        }
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecodMode.recording)
    }

    func testVenueListError() {
        let vm = VenueListViewModel()
        vm.errorMessage = "Could not load venues. Please try again."
        let view = NavigationStack {
            VenueListView(viewModel: vm)
        }
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecodMode.recording)
    }

    func testVenueListEmpty() {
        let vm = VenueListViewModel(venues: [])
        let view = NavigationStack {
            VenueListView(viewModel: vm)
        }
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecodMode.recording)
    }

    // MARK: - VenueDetailView

    func testVenueDetailLoaded() {
        let vm = VenueDetailViewModel(
            venue: MockData.venue1,
            performances: MockData.venuePerformances
        )
        let view = NavigationStack {
            VenueDetailView(viewModel: vm)
        }
        .environment(\.testImageOverride, sampleImage)
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecodMode.recording)
    }

    func testVenueDetailLoading() {
        let vm = VenueDetailViewModel(
            venue: MockData.venue1,
            performances: [],
            isLoading: true
        )
        let view = NavigationStack {
            VenueDetailView(viewModel: vm)
        }
        .environment(\.testImageOverride, sampleImage)
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecodMode.recording)
    }

    func testVenueDetailError() {
        let vm = VenueDetailViewModel(
            venue: MockData.venue1,
            performances: [],
            errorMessage: "Failed to load performances."
        )
        let view = NavigationStack {
            VenueDetailView(viewModel: vm)
        }
        .environment(\.testImageOverride, sampleImage)
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecodMode.recording)
    }

    func testVenueDetailEmpty() {
        let vm = VenueDetailViewModel(
            venue: MockData.venue1,
            performances: []
        )
        let view = NavigationStack {
            VenueDetailView(viewModel: vm)
        }
        .environment(\.testImageOverride, sampleImage)
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecodMode.recording)
    }
}
