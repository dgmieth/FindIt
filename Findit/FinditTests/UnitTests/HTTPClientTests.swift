//
//  HTTPClientTests.swift
//  FinditTests
//
//  Created by Diego Mieth on 2026-04-12.
//

import XCTest
@testable import Findit

// MARK: - MockURLProtocol

final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - Helpers

private struct MockDecodable: Codable, Sendable, Equatable {
    let id: Int
}

private struct TestEndpoint: EndpointProtocol {
    var path: String = "/test"
    var queryParams: QueryParams? { nil }
}

// MARK: - Tests

final class HTTPClientTests: XCTestCase {
    private var httpClient: HTTPClient!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        httpClient = HTTPClient(server: .leapInterview, urlSession: session)
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        httpClient = nil
        super.tearDown()
    }

    func testFetchSuccessDecodesResponse() async throws {
        let expected = MockDecodable(id: 42)
        MockURLProtocol.requestHandler = { _ in
            let data = try JSONEncoder().encode(expected)
            let response = HTTPURLResponse(
                url: URL(string: "https://api.leapmobileinterview.com/test")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }

        let result: MockDecodable = try await httpClient.fetch(endpoint: TestEndpoint())
        XCTAssertEqual(result, expected)
    }

    func testFetchThrowsInvalidResponseOn404() async {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://api.leapmobileinterview.com/test")!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        do {
            let _: MockDecodable = try await httpClient.fetch(endpoint: TestEndpoint())
            XCTFail("Expected APIError.invalidResponse to be thrown")
        } catch let error as APIError {
            guard case .invalidResponse(let code) = error else {
                return XCTFail("Expected .invalidResponse, got \(error)")
            }
            XCTAssertEqual(code, 404)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchThrowsInvalidResponseOn500() async {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://api.leapmobileinterview.com/test")!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        do {
            let _: MockDecodable = try await httpClient.fetch(endpoint: TestEndpoint())
            XCTFail("Expected APIError.invalidResponse to be thrown")
        } catch let error as APIError {
            guard case .invalidResponse(let code) = error else {
                return XCTFail("Expected .invalidResponse, got \(error)")
            }
            XCTAssertEqual(code, 500)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchThrowsDecodingErrorOnBadJSON() async {
        MockURLProtocol.requestHandler = { _ in
            let data = Data("not valid json".utf8)
            let response = HTTPURLResponse(
                url: URL(string: "https://api.leapmobileinterview.com/test")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }

        do {
            let _: MockDecodable = try await httpClient.fetch(endpoint: TestEndpoint())
            XCTFail("Expected APIError.decodingError to be thrown")
        } catch let error as APIError {
            guard case .decodingError = error else {
                return XCTFail("Expected .decodingError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchThrowsNetworkErrorOnURLSessionFailure() async {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        do {
            let _: MockDecodable = try await httpClient.fetch(endpoint: TestEndpoint())
            XCTFail("Expected APIError.networkError to be thrown")
        } catch let error as APIError {
            guard case .networkError = error else {
                return XCTFail("Expected .networkError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
