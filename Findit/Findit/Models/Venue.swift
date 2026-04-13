import Foundation

struct Venue: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let sortId: Int

    var imageURL: URL? {
        let urlString = "\(Constants.songleapAmazonAddressForImages)/venues/\(self.name).png"
        return URL.createEncodedURL(urlString: urlString)
    }
}
