//
//  Date+extensions.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import Foundation

extension DateFormatter {
    static let apiDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static let apiQueryFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
    
    enum DateFormat: String {
        case apiDateFormat = "yyyy-MM-dd HH:mm:ss"
        case apiQueryFormat = "yyyy-MM-dd"
    }
    
    static func formatter(for dateFormat: DateFormat) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = dateFormat.rawValue
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }
}
