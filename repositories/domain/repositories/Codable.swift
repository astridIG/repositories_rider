import Foundation

protocol CodableProtocol: Identifiable {
    init?(jsonDictionary: [Key: Any])

    func toJson() -> [Key: Any]
}
