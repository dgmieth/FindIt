//
//  Servers.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import Foundation

enum Servers {
    case leapInterview
    case imageServer
    
    func getServerAddress() -> String {
        switch self {
        case .leapInterview:
            return LEAP_MOBILE_INTERVIEW_API_ADDRESS
        case .imageServer:
            return SONGLEAP_AMAZON_ADRESS_FOR_IMAGES
        }
    }
    
    func httpClient() -> HTTPClientProtocol {
        switch self {
        case .leapInterview:
            return HTTPClient(server: .leapInterview)
        case .imageServer:
            return HTTPClient(server: .imageServer)
        }
    }
}
