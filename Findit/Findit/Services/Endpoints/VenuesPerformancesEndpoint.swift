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
        let dateFormmater = DateFormatter.formatter(for: .apiQueryFormat)
        
        switch (self.from, self.to) {
        case (.some(let from), .some(let to)):
            return [
                "from": dateFormmater.string(from: from),
                "to": dateFormmater.string(from: to)
            ]
        case (.some(let from), _):
            return [
                "from": dateFormmater.string(from: from)
            ]
        case (_, .some(let to)):
            return [
                "to": dateFormmater.string(from: to)
            ]
        default:
            return nil
        }
    }
}
