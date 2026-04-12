//
//  URL+extensions.swift
//  Findit
//
//  Created by Diego Mieth on 2026-04-12.
//

import Foundation

extension URL {
    static func createEncodedURL(urlString: String) -> URL? {
        guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        return URL(string: encodedString)
    }
}
