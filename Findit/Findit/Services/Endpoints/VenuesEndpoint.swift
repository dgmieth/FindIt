//
//  VenuesEndpoint.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import Foundation

struct VenuesEndpoint: EndpointProtocol {
    var path: String = "/venues"
    
    var queryParams: [String : String]? {
        return nil
    }
}
