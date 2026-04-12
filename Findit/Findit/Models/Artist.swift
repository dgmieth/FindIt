import Foundation

struct Artist: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let genre: String

    var imageURL: URL? {
        let urlString = "\(SONGLEAP_AMAZON_ADRESS_FOR_IMAGES)/artists/\(self.name).png"
        return URL.createEncodedURL(urlString: urlString)
    }
}
