import Foundation

protocol Codable: Identifiable {
    init?(jsonDictionary: [Key: Any])

    func toJson() -> [Key: Any]
}
