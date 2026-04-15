//
//  Date+extensions.swift
//  FinditTests
//
//  Created by Diego Mieth on 2026-04-15.
//

import Foundation

extension Date {
    static func getDate() -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = 2026
        dateComponents.month = 04
        dateComponents.day = 12
        dateComponents.hour = 22
        dateComponents.minute = 02
        dateComponents.second = 00
        
        return Calendar.current.date(from: dateComponents)
    }
}
