//
//  ArtistsPerformancesEndpoint.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import Foundation

struct ArtistsPerformancesEndpoint: EndpointProtocol {
    private var artistId: Int
    private var from: Date?
    private var to: Date?
    
    init(artistId: Int, from: Date? = nil, to: Date? = nil) {
        self.artistId = artistId
        self.from = from
        self.to = to
    }
    
    var path: String {
        "/artists/\(artistId)/performances"
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
