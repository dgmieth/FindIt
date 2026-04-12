import Foundation

struct Artist: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let genre: String

    var imageURL: URL? {
        let encodedName = name.replacingOccurrences(of: " ", with: "+")
        return URL(string: "https://songleap.s3.amazonaws.com/artists/\(encodedName).png")
    }
}
