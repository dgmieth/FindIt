//
//  ImageServiceTests.swift
//  FinditTests
//
//  Created by Diego Mieth on 2026-04-14.
//

import XCTest
@testable import Findit

// MARK: - Helpers

private func makeSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: config)
}

private func makePNGData() -> Data {
    UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), true, 1)
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image.pngData()!
}

// MARK: - Tests

final class ImageServiceTests: XCTestCase {

    private var service: ImageService!

    override func setUp() {
        super.setUp()
        MockURLProtocol.requestHandler = nil
        service = ImageService(urlSession: makeSession())
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        service = nil
        super.tearDown()
    }

    // MARK: Nil URL

    func testFetchImageWithNilURLReturnsNil() async {
        let result = await service.fetchImage(for: nil)
        XCTAssertNil(result)
    }

    // MARK: Successful fetch

    func testFetchImageSuccessReturnsImage() async {
        let imageData = makePNGData()
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://example.com/img.png")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, imageData)
        }

        let url = URL(string: "https://example.com/img.png")!
        let result = await service.fetchImage(for: url)
        XCTAssertNotNil(result)
    }

    // MARK: Cache hit

    func testFetchImageReturnsCachedImageOnSecondCall() async {
        let imageData = makePNGData()
        var requestCount = 0
        MockURLProtocol.requestHandler = { _ in
            requestCount += 1
            let response = HTTPURLResponse(
                url: URL(string: "https://example.com/cached.png")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, imageData)
        }

        let url = URL(string: "https://example.com/cached.png")!
        let first = await service.fetchImage(for: url)
        let second = await service.fetchImage(for: url)

        XCTAssertNotNil(first)
        XCTAssertNotNil(second)
        XCTAssertEqual(requestCount, 1, "Network should only be hit once; second call must be served from cache")
    }

    // MARK: Network error

    func testFetchImageReturnsNilOnNetworkError() async {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        let url = URL(string: "https://example.com/error.png")!
        let result = await service.fetchImage(for: url)
        XCTAssertNil(result)
    }

    // MARK: Invalid data

    func testFetchImageReturnsNilForNonImageData() async {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://example.com/text.png")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data("not an image".utf8))
        }

        let url = URL(string: "https://example.com/text.png")!
        let result = await service.fetchImage(for: url)
        XCTAssertNil(result)
    }

    // MARK: Deduplication of concurrent requests

    func testConcurrentRequestsForSameURLOnlyHitNetworkOnce() async {
        let imageData = makePNGData()
        var requestCount = 0
        MockURLProtocol.requestHandler = { _ in
            requestCount += 1
            let response = HTTPURLResponse(
                url: URL(string: "https://example.com/dedup.png")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, imageData)
        }

        let url = URL(string: "https://example.com/dedup.png")!
        async let a = service.fetchImage(for: url)
        async let b = service.fetchImage(for: url)
        async let c = service.fetchImage(for: url)

        let results = await [a, b, c]
        XCTAssertTrue(results.allSatisfy { $0 != nil })
        XCTAssertEqual(requestCount, 1, "Concurrent requests for the same URL should be deduplicated into a single network call")
    }

    // MARK: Different URLs use separate requests

    func testDifferentURLsFetchedIndependently() async {
        let imageData = makePNGData()
        var requestedURLs: [URL] = []
        MockURLProtocol.requestHandler = { request in
            requestedURLs.append(request.url!)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, imageData)
        }

        let url1 = URL(string: "https://example.com/a.png")!
        let url2 = URL(string: "https://example.com/b.png")!
        let _ = await service.fetchImage(for: url1)
        let _ = await service.fetchImage(for: url2)

        XCTAssertEqual(requestedURLs.count, 2)
        XCTAssertTrue(requestedURLs.contains(url1))
        XCTAssertTrue(requestedURLs.contains(url2))
    }
}
