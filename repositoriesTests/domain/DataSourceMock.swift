@testable import repositories

class ReadableDataSourceMock<Key, Value: CodableProtocol>:  ReadableDataSource<Key, Value> where Value.Key == Key {

    var returnValue: Value?
    var returnCollectionValue: [Value]?
    var getByKeyCompletionBlock: ((Key) -> ())? = nil
    var getAllCompletionBlock: (()->())? = nil

    override func getByKey(key: Key) -> Value? {
        if let getByKeyCompletionBlock = getByKeyCompletionBlock {
            getByKeyCompletionBlock(key)
        }
        return returnValue
    }

    override func getAll() -> [Value]? {
        if let getAllCompletionBlock = getAllCompletionBlock {
            getAllCompletionBlock()
        }
        return returnCollectionValue
    }

}

class WriteableDataSourceMock<Key, Value: CodableProtocol>:  WriteableDataSource<Key, Value> where Value.Key == Key {

    var returnValue: Value?
    var returnCollectionValue: [Value]?
    var isDeleted: Bool = true
    var addOrUpdateCompletionBlock: ((Value)->())? = nil
    var addOrUpdateAllCompletionBlock: (([Value]) -> ())? = nil
    var deleteByKeyCompletionBlock: ((Key) -> ())? = nil
    var deleteAllCompletionBlock: (() -> ())? = nil

    override func addOrUpdate(value: Value) -> Value? {
        if let addOrUpdateCompletionBlock = addOrUpdateCompletionBlock {
            addOrUpdateCompletionBlock(value)
        }
        return returnValue
    }

    override func addOrUpdateAll(values: [Value]) -> [Value]? {
        if let addOrUpdateAllCompletionBlock = addOrUpdateAllCompletionBlock {
            addOrUpdateAllCompletionBlock(values)
        }
        return returnCollectionValue
    }

    override func deleteByKey(key: Key) -> Bool {
        if let deleteByKeyCompletionBlock = deleteByKeyCompletionBlock {
            deleteByKeyCompletionBlock(key)
        }
        return isDeleted
    }

    override func deleteAll() -> Bool {
        if let deleteAllCompletionBlock = deleteAllCompletionBlock {
            deleteAllCompletionBlock()
        }
        return isDeleted
    }

}

class CacheDataSourceMock<Key, Value: CodableProtocol>:  CacheDataSource<Key, Value> where Value.Key == Key {

    var returnValue: Value?
    var returnCollectionValue: [Value]?
    var isDeleted: Bool = true
    var isValid: Bool = true
    var getAllCompletionBlock: (() -> ())? = nil
    var getByKeyCompletionBlock: ((Key) -> ())? = nil
    var addOrUpdateCompletionBlock: ((Value) -> ())? = nil
    var addOrUpdateAllCompletionBlock: (([Value])->())? = nil
    var deleteByKeyCompletionBlock: ((Key) -> ())? = nil
    var deleteAllCompletionBlock: (() -> ())? = nil

    override func getByKey(key: Key) -> Value? {
        if let getByKeyCompletionBlock = getByKeyCompletionBlock {
            getByKeyCompletionBlock(key)
        }
        return returnValue
    }

    override func getAll() -> [Value]? {
        if let getAllCompletionBlock = getAllCompletionBlock {
            getAllCompletionBlock()
        }
        return returnCollectionValue
    }

    override func addOrUpdate(value: Value) -> Value? {
        if let addOrUpdateCompletionBlock = addOrUpdateCompletionBlock {
            addOrUpdateCompletionBlock(value)
        }
        return returnValue
    }

    override func addOrUpdateAll(values: [Value]) -> [Value]? {
        if let addOrUpdateAllCompletionBlock = addOrUpdateAllCompletionBlock {
            addOrUpdateAllCompletionBlock(values)
        }
        return returnCollectionValue
    }

    override func deleteByKey(key: Key) -> Bool {
        if let deleteByKeyCompletionBlock = deleteByKeyCompletionBlock {
            deleteByKeyCompletionBlock(key)
        }
        return isDeleted
    }

    override func deleteAll() -> Bool {
        if let deleteAllCompletionBlock = deleteAllCompletionBlock {
            deleteAllCompletionBlock()
        }
        return isDeleted
    }

    override func isValid(value: Value) -> Bool {
        return isValid
    }

}
