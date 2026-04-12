//
//  Servers.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import Foundation

enum Servers {
    case leapInterview
    
    func getServerAddress() -> String {
        switch self {
        case .leapInterview:
            return LEAP_MOBILE_INTERVIEW_API_ADDRESS
        }
    }
    
    func httpClient() -> HTTPClientProtocol {
        switch self {
        case .leapInterview:
            return HTTPClient(server: .leapInterview)
        }
    }
}
