@testable import repositories

class ReadableDataSourceMock<Key, Value: CodableProtocol>:  ReadableDataSource<Key, Value> where Value.Key == Key {

    var returnValue: Value?
    var returnCollectionValue: [Value]?

    override func getByKey(key: Key) -> Value? {
        return returnValue
    }

    override func getAll() -> [Value]? {
        return returnCollectionValue
    }

}

class WriteableDataSourceMock<Key, Value: CodableProtocol>:  WriteableDataSource<Key, Value> where Value.Key == Key {

    var returnValue: Value?
    var returnCollectionValue: [Value]?
    var isDeleted: Bool?

    override func addOrUpdate(value: Value) -> Value? {
        return returnValue
    }

    override func addOrUpdateAll(values: [Value]) -> [Value]? {
        return returnCollectionValue
    }

    override func deleteByKey(key: Key) -> Bool {
        return isDeleted!
    }

    override func deleteAll() -> Bool {
        return isDeleted!
    }

}

class CacheDataSourceMock<Key, Value: CodableProtocol>:  CacheDataSource<Key, Value> where Value.Key == Key {

    var returnValue: Value?
    var returnCollectionValue: [Value]?
    var isDeleted: Bool?
    var isValid: Bool?

    override func getByKey(key: Key) -> Value? {
        return returnValue
    }

    override func getAll() -> [Value]? {
        return returnCollectionValue
    }

    override func addOrUpdate(value: Value) -> Value? {
        return returnValue
    }

    override func addOrUpdateAll(values: [Value]) -> [Value]? {
        return returnCollectionValue
    }

    override func deleteByKey(key: Key) -> Bool {
        return isDeleted!
    }

    override func deleteAll() -> Bool {
        return isDeleted!
    }

    override func isValid(value: Value) -> Bool {
        return isValid!
    }

}
