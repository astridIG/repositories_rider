import Foundation

class User: CodableProtocol {
    func getKey() -> String {
        return self.id
    }

    let name: String
    let id: String

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    required init?(jsonDictionary: [String: Any]) {
        guard let id = jsonDictionary["id"] as? String, let name = jsonDictionary["name"] as? String else {
            return nil
        }

        self.id = id
        self.name = name
    }

    func toJson() -> [String: Any] {
        return ["id": self.id, "name": self.name]
    }
}

class DiskDataSource<K, V: CodableProtocol>: CacheDataSource<K,V> where V.Key == K {

    private var sqlFake: [K: [K: Any]] = [:]

    override func addOrUpdate(value: V) -> V? {
        sqlFake[value.getKey()] = value.toJson()
        return value
    }

    override func getByKey(key: K) -> V? {
        guard let dictionary = sqlFake[key] else {
            return nil
        }

        let item = V.init(jsonDictionary: dictionary)
        if let item = item {
            return item
        } else {
            try? deleteByKey(key: key)
            return nil
        }
    }
}

