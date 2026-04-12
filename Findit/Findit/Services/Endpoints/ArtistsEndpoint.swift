//
//  ArtistsEndpoint.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import Foundation

struct ArtistsEndpoint: EndpointProtocol {
    var path: String = "/artists"
    
    var queryParams: [String : String]? {
        return nil
    }
}
