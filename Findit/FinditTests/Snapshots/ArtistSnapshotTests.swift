//
//  ArtistSnapshotTests.swift
//  FinditTests
//
//  Created by Diego Mieth on 2026-04-12.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import Findit

@MainActor
final class ArtistSnapshotTests: XCTestCase {

    private var sampleImage: UIImage { MockData.sampleImage }

    // MARK: - ArtistListView

    func testArtistListLoaded() {
        let vm = ArtistListViewModel(artists: MockData.artists)
        let view = NavigationStack {
            ArtistListView(viewModel: vm)
        }
        .environment(\.testImageOverride, sampleImage)
        
        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro), record: RecodMode.recording)
    }

    func testArtistListLoading() {
        let vm = ArtistListViewModel()
        vm.isLoading = true
        let view = NavigationStack {
            ArtistListView(viewModel: vm)
        }
        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro), record: RecodMode.recording)
    }

    func testArtistListError() {
        let vm = ArtistListViewModel()
        vm.errorMessage = "Could not load artists. Please try again."
        let view = NavigationStack {
            ArtistListView(viewModel: vm)
        }
        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro), record: RecodMode.recording)
    }

    func testArtistListEmpty() {
        let vm = ArtistListViewModel(artists: [])
        let view = NavigationStack {
            ArtistListView(viewModel: vm)
        }
        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro), record: RecodMode.recording)
    }

    // MARK: - ArtistDetailView

    func testArtistDetailLoaded() {
        let vm = ArtistDetailViewModel(
            artist: MockData.artist1,
            performances: MockData.artistPerformances
        )
        let view = NavigationStack {
            ArtistDetailView(viewModel: vm)
        }
        .environment(\.testImageOverride, sampleImage)
        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro), record: RecodMode.recording)
    }

    func testArtistDetailLoading() {
        let vm = ArtistDetailViewModel(
            artist: MockData.artist1,
            performances: [],
            isLoading: true
        )
        let view = NavigationStack {
            ArtistDetailView(viewModel: vm)
        }
        .environment(\.testImageOverride, sampleImage)
        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro), record: RecodMode.recording)
    }

    func testArtistDetailError() {
        let vm = ArtistDetailViewModel(
            artist: MockData.artist1,
            performances: [],
            errorMessage: "Failed to load performances."
        )
        let view = NavigationStack {
            ArtistDetailView(viewModel: vm)
        }
        .environment(\.testImageOverride, sampleImage)
        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro), record: RecodMode.recording)
    }

    func testArtistDetailEmpty() {
        let vm = ArtistDetailViewModel(
            artist: MockData.artist1,
            performances: []
        )
        let view = NavigationStack {
            ArtistDetailView(viewModel: vm)
        }
        .environment(\.testImageOverride, sampleImage)
        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13Pro))
    }
}
