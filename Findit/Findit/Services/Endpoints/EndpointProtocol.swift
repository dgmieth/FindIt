//
//  EndpointProtocol.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import Foundation

protocol EndpointProtocol {
    var path: String { get }
    var queryParams: [String: String]? { get }
}
