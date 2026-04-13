//
//  EndpointProtocolTests.swift
//  FinditTests
//
//  Created by Diego Mieth on 2026-04-12.
//

import XCTest
@testable import Findit

struct MockedEndpoint: EndpointProtocol {
    var path: String = "/path"
    var paramOne: String?
    var paramTwo: String?
    
    init(paramOne: String? = nil, paramTwo: String? = nil) {
        self.paramOne = paramOne
        self.paramTwo = paramTwo
    }
    
    var queryParams: Findit.QueryParams? {
        switch (self.paramOne, self.paramTwo) {
        case (.some(let one), .some(let two)):
            return [
                "one": one,
                "two": two,
            ]
        case (.some(let one), _):
            return [
                "one": one,
            ]
        case (_, .some(let two)):
            return [
                "two": two,
            ]
        default: return nil
        }
    }
}

final class EndpointProtocolTests: XCTestCase {
    func testEndpointNoParams() throws {
        let _endpoint = MockedEndpoint()
        let request = _endpoint.generateRequest(for: "https:example.com")
        XCTAssertNotNil(request?.url?.absoluteString)
        XCTAssertEqual(request!.url!.absoluteString, "https:example.com/path")
    }
    
    func testEndpointParamOne() throws {
        let _endpoint = MockedEndpoint(paramOne: "One")
        let request = _endpoint.generateRequest(for: "https:example.com")
        XCTAssertNotNil(request?.url?.absoluteString)
        XCTAssertEqual(request!.url!.absoluteString, "https:example.com/path?one=One")
    }
    
    func testEndpointParamTwo() throws {
        let _endpoint = MockedEndpoint(paramTwo: "Two")
        let request = _endpoint.generateRequest(for: "https:example.com")
        XCTAssertNotNil(request?.url?.absoluteString)
        XCTAssertEqual(request!.url!.absoluteString, "https:example.com/path?two=Two")
    }
    
    func testEndpointParams() throws {
        let _endpoint = MockedEndpoint(paramOne: "One", paramTwo: "Two")
        let request = _endpoint.generateRequest(for: "https:example.com")
        XCTAssertNotNil(request?.url?.absoluteString)
        XCTAssertEqual(request!.url!.absoluteString, "https:example.com/path?one=One&two=Two")
    }
}
