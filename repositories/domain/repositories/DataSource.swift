import Foundation

protocol ReadableDataSourceProtocol {
    associatedtype K: Hashable
    associatedtype V: Codable

    func getByKey(key: K) -> V?
    func getAll() -> [V]?
}

class ReadableDataSource<Key: Hashable, Value: Codable>: ReadableDataSourceProtocol {
    func getByKey(key: Key) -> Value? { fatalError("Must override") }
    func getAll() -> [Value]? { fatalError("Must override") }
}

protocol WritableDataSourceProtocol {
    associatedtype K: Hashable
    associatedtype V: Codable

    func addOrUpdate(value: V) -> V?
    func addOrUpdateAll(values: [V]) -> [V]?
    func deleteByKey(key: K)
    func deleteAll()
}

class WriteableDataSource<K: Hashable, V: Codable>: WritableDataSourceProtocol {
    func addOrUpdate(value: V) -> V? { fatalError("Must override") }
    func addOrUpdateAll(values: [V]) -> [V]? { fatalError("Must override") }
    func deleteByKey(key: K) { fatalError("Must override") }
    func deleteAll() { fatalError("Must override") }
}

protocol CacheDataSourceProtocol: ReadableDataSourceProtocol, WritableDataSourceProtocol {
//    var policies: [CachePolicy<K, V>] { get }
    func isValid(value: V) -> Bool
}

class CacheDataSource<K: Hashable, V: Codable>: CacheDataSourceProtocol {
//    var policies: [CachePolicy<K, V>]
    func getByKey(key: K) -> V? { fatalError("Must override") }
    func getAll() -> [V]? { fatalError("Must override") }

    func addOrUpdate(value: V) -> V? { fatalError("Must override") }
    func addOrUpdateAll(values: [V]) -> [V]? { fatalError("Must override") }
    func deleteByKey(key: K) { fatalError("Must override") }
    func deleteAll() { fatalError("Must override") }

    func isValid(value: V) -> Bool { fatalError("Must override") }
}
