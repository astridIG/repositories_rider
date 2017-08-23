import Foundation

protocol ReadableDataSourceProtocol {
    associatedtype Key: Hashable
    associatedtype Value: Codable

    func getByKey(key: Key) -> Value?
    func getAll() -> [Value]?
}

class ReadableDataSource<Key: Hashable, Value: Codable>: ReadableDataSourceProtocol {
    func getByKey(key: Key) -> Value? { fatalError("Must override") }
    func getAll() -> [Value]? { fatalError("Must override") }
}

protocol WritableDataSourceProtocol {
    associatedtype Key: Hashable
    associatedtype Value: Codable

    func addOrUpdate(value: Value) -> Value?
    func addOrUpdateAll(values: [Value]) -> [Value]?
    func deleteByKey(key: Key) -> Bool
    func deleteAll() -> Bool
}

class WriteableDataSource<Key: Hashable, Value: Codable>: WritableDataSourceProtocol {
    func addOrUpdate(value: Value) -> Value? { fatalError("Must override") }
    func addOrUpdateAll(values: [Value]) -> [Value]? { fatalError("Must override") }
    func deleteByKey(key: Key) -> Bool { fatalError("Must override") }
    func deleteAll() -> Bool { fatalError("Must override") }
}

protocol CacheDataSourceProtocol: ReadableDataSourceProtocol, WritableDataSourceProtocol {
    var policies: [CachePolicy<Value>] { get set }
    func isValid(value: Value) -> Bool
}

class CacheDataSource<Key: Hashable, Value: Codable>: CacheDataSourceProtocol {
    var policies: [CachePolicy<Value>] = []

    func getByKey(key: Key) -> Value? { fatalError("Must override") }
    func getAll() -> [Value]? { fatalError("Must override") }

    func addOrUpdate(value: Value) -> Value? { fatalError("Must override") }
    func addOrUpdateAll(values: [Value]) -> [Value]? { fatalError("Must override") }
    func deleteByKey(key: Key) -> Bool{ fatalError("Must override") }
    func deleteAll() -> Bool { fatalError("Must override") }

    func isValid(value: Value) -> Bool { fatalError("Must override") }
}
