import Foundation

struct Artist: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let genre: String

    var imageURL: URL? {
        let urlString = "\(Constants.songleapAmazonAddressForImages)/artists/\(self.name).png"
        return URL.createEncodedURL(urlString: urlString)
    }
}
