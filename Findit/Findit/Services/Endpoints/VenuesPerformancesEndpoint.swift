//
//  VenuesPerformancesEndpoint.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import Foundation

struct VenuesPerformancesEndpoint: EndpointProtocol {
    private var venueId: Int
    private var from: Date?
    private var to: Date?
    
    init(venueId: Int, from: Date? = nil, to: Date? = nil) {
        self.venueId = venueId
        self.from = from
        self.to = to
    }
    
    var path: String {
        "/venues/\(venueId)/performances"
    }
    
    var queryParams: [String : String]? {
        let dateFormatter = DateFormatter.formatter(for: .apiQueryFormat)
        
        switch (self.from, self.to) {
        case (.some(let from), .some(let to)):
            return [
                "from": dateFormatter.string(from: from),
                "to": dateFormatter.string(from: to)
            ]
        case (.some(let from), _):
            return [
                "from": dateFormatter.string(from: from)
            ]
        case (_, .some(let to)):
            return [
                "to": dateFormatter.string(from: to)
            ]
        default:
            return nil
        }
    }
}
