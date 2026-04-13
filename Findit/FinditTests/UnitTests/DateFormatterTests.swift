//
//  DateFormatterTests.swift
//  FinditTests
//
//  Created by Diego Mieth on 2026-04-12.
//

import XCTest
@testable import Findit

final class DateFormatterTests: XCTestCase {
    private func getDate() -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = 2026
        dateComponents.month = 04
        dateComponents.day = 12
        dateComponents.hour = 22
        dateComponents.minute = 02
        dateComponents.second = 00
        
        return Calendar.current.date(from: dateComponents)
    }

    func testDateFormatterApiDateFormat() throws {
        let testDate = getDate()
        XCTAssertNotNil(testDate)
        
        let formatter = DateFormatter.formatter(for: .apiDateFormat)
        let formattedDateString = formatter.string(from: testDate!)
        
        XCTAssertEqual(formattedDateString, "2026-04-12 22:02:00")
    }
    
    func testDateFormatterApiQueryFormat() throws {
        let testDate = getDate()
        XCTAssertNotNil(testDate)
        
        let formatter = DateFormatter.formatter(for: .apiQueryFormat)
        let formattedDateString = formatter.string(from: testDate!)
        
        XCTAssertEqual(formattedDateString, "2026-04-12")
    }
}
