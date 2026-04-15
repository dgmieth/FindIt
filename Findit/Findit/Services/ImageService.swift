//
//  ImageService.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import UIKit

protocol ImageServiceProtocol: Actor {
    func fetchImage(for url: URL?) async -> UIImage?
}

actor ImageService: ImageServiceProtocol {
    private let cache = NSCache<NSString, UIImage>()
    private var tasks: [URL: Task<UIImage?, Never>] = [:]
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
        cache.countLimit = 150
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }

    func fetchImage(for url: URL?) async -> UIImage? {
        guard let url else { return nil }
        let key = url.absoluteString as NSString

        if let cached = cache.object(forKey: key) {
            return cached
        }

        if let existingTask = tasks[url] {
            return await existingTask.value
        }

        let task = Task<UIImage?, Never> {
            do {
                let (data, _) = try await self.urlSession.data(from: url)
                return UIImage(data: data)
            } catch {
                return nil
            }
        }

        tasks[url] = task

        let image = await task.value

        self.tasks[url] = nil
        
        if let image {
            self.set(image, for: key)
        }
        
        return image
    }
    

    // MARK: - Cache

    private func set(_ image: UIImage, for key: NSString) {
        let cost = Int(image.size.width * image.size.height * 4)
        cache.setObject(image, forKey: key, cost: cost)
    }
}
