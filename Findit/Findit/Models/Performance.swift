import Foundation

// Performance returned from /artists/{id}/performances
struct ArtistPerformance: Codable, Identifiable {
    let id: Int
    let artistId: Int
    let date: String
    let venue: PerformanceVenue

    var parsedDate: Date? {
        DateFormatter.apiDateFormatter.date(from: date)
    }
}

// Performance returned from /venues/{id}/performances
struct VenuePerformance: Codable, Identifiable {
    let id: Int
    let venueId: Int
    let date: String
    let artist: PerformanceArtist

    var parsedDate: Date? {
        DateFormatter.apiDateFormatter.date(from: date)
    }
}

// Lightweight venue embedded inside ArtistPerformance
struct PerformanceVenue: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let sortId: Int

    var imageURL: URL? {
        let encodedName = name.replacingOccurrences(of: " ", with: "+")
        return URL(string: "https://songleap.s3.amazonaws.com/venues/\(encodedName).png")
    }
}

// Lightweight artist embedded inside VenuePerformance
struct PerformanceArtist: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let genre: String

    var imageURL: URL? {
        let encodedName = name.replacingOccurrences(of: " ", with: "+")
        return URL(string: "https://songleap.s3.amazonaws.com/artists/\(encodedName).png")
    }
}
