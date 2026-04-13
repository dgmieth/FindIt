//
//  FilterSnapshotTests.swift
//  FinditTests
//
//  Created by Diego Mieth on 2026-04-13.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import Findit

@MainActor
final class FilterSnapshotTests: XCTestCase {

    private var fixedStartDate: Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 20))!
    }

    private var fixedEndDate: Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 10))!
    }

    // MARK: - Preset filters

    func testFilterNext14Days() {
        let view = FilterView(
            filterOption: .next14Days,
            startDate: nil,
            endDate: nil
        ) { _, _, _ in }
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecordMode.recording)
    }

    func testFilterNext30Days() {
        let view = FilterView(
            filterOption: .next30Days,
            startDate: nil,
            endDate: nil
        ) { _, _, _ in }
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecordMode.recording)
    }

    func testFilterNext60Days() {
        let view = FilterView(
            filterOption: .next60Days,
            startDate: nil,
            endDate: nil
        ) { _, _, _ in }
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecordMode.recording)
    }

    // MARK: - Custom filter

    func testFilterCustomNoDates() {
        let view = FilterView(
            filterOption: .custom,
            startDate: nil,
            endDate: nil
        ) { _, _, _ in }
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecordMode.recording)
    }

    func testFilterCustomOnlyStartDate() {
        let view = FilterView(
            filterOption: .custom,
            startDate: fixedStartDate,
            endDate: nil
        ) { _, _, _ in }
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecordMode.recording)
    }

    func testFilterCustomOnlyEndDate() {
        let view = FilterView(
            filterOption: .custom,
            startDate: nil,
            endDate: fixedEndDate
        ) { _, _, _ in }
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecordMode.recording)
    }

    func testFilterCustomBothDates() {
        let view = FilterView(
            filterOption: .custom,
            startDate: fixedStartDate,
            endDate: fixedEndDate
        ) { _, _, _ in }
        assertSnapshot(of: UIHostingController(rootView: view), as: .lightIPhone13Pro, record: RecordMode.recording)
    }
}
