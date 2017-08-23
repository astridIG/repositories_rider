import Foundation
@testable import repositories

struct TestValue: CodableProtocol {
    func getKey() -> String {
        return self.id
    }

    let id: String

    init(id: String) {
        self.id = id
    }

    init?(jsonDictionary: [String: Any]) {
        guard let id = jsonDictionary["id"] as? String else {
            return nil
        }
        self.id = id
    }

    func toJson() -> [String: Any] {
        return ["id": self.id]
    }
}
