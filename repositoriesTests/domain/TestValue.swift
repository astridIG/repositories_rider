import Foundation
@testable import repositories

struct TestValue: CodableProtocol, Equatable {
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

func==(lhs: TestValue, rhs: TestValue) -> Bool {
    return lhs.id == rhs.id
}
