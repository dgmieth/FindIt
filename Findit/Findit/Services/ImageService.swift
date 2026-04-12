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
    private let cache = NSCache<NSURL, UIImage>()

    func fetchImage(for url: URL?) async -> UIImage? {
        guard let url else { return nil }
        
        if let image = self.get(for: url as NSURL) {
            return image
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let image = UIImage(data: data) else {
                return nil
            }
            
            self.set(for: url as NSURL, image: image)
            
            return image
        } catch {
            return nil
        }
    }
    
    private func get(for url: NSURL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }
    
    private func set(for url: NSURL, image: UIImage) {
        cache.setObject(image, forKey: url as NSURL)
    }
}
