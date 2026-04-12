//
//  VenuesPerformancesEndpoint.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import Foundation

struct VenuesPerformancesEndpoint: EndpointProtocol {
    private var venueId: Int
    private var from: String?
    private var to: String?
    
    init(venueId: Int, from: String? = nil, to: String? = nil) {
        self.venueId = venueId
        self.from = from
        self.to = to
    }
    
    var path: String {
        "/venues/\(venueId)/performances"
    }
    
    var queryParams: [String : String]? {
        switch (self.from, self.to) {
        case (.some(let from), .some(let to)):
            return [
                "from": from,
                "to": to
            ]
        case (.some(let from), _):
            return [
                "from": from
            ]
        case (_, .some(let to)):
            return [
                "to": to
            ]
        default:
            return nil
        }
    }
}
