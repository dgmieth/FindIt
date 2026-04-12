import Foundation

struct Venue: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let sortId: Int

    var imageURL: URL? {
        let encodedName = name.replacingOccurrences(of: " ", with: "+")
        return URL(string: "https://songleap.s3.amazonaws.com/venues/\(encodedName).png")
    }
}
