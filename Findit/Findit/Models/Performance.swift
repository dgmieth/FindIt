import Foundation

// Performance returned from /artists/{id}/performances
struct ArtistPerformance: Codable, Identifiable, Sendable {
    let id: Int
    let artistId: Int
    let date: String
    let venue: PerformanceVenue

    var parsedDate: Date? {
        DateFormatter.formatter(for: .apiDateFormat).date(from: date)
    }
}

// Performance returned from /venues/{id}/performances
struct VenuePerformance: Codable, Identifiable, Sendable {
    let id: Int
    let venueId: Int
    let date: String
    let artist: PerformanceArtist

    var parsedDate: Date? {
        DateFormatter.formatter(for: .apiDateFormat).date(from: date)
    }
}

// Lightweight venue embedded inside ArtistPerformance
struct PerformanceVenue: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let sortId: Int

    var imageURL: URL? {
        let urlString = "\(SONGLEAP_AMAZON_ADRESS_FOR_IMAGES)/venues/\(self.name).png"
        return URL.createEncodedURL(urlString: urlString)
    }
}

// Lightweight artist embedded inside VenuePerformance
struct PerformanceArtist: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let genre: String

    var imageURL: URL? {
        let urlString = "\(SONGLEAP_AMAZON_ADRESS_FOR_IMAGES)/artists/\(self.name).png"
        return URL.createEncodedURL(urlString: urlString)
    }
}
