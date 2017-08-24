import Foundation

protocol ReadableDataSourceProtocol {
    associatedtype Key: Hashable
    associatedtype Value: CodableProtocol

    func getByKey(key: Key) -> Value?
    func getAll() -> [Value]?
}

class ReadableDataSource<Key: Hashable, Value: CodableProtocol>: ReadableDataSourceProtocol {
    func getByKey(key: Key) -> Value? { fatalError("Must override") }
    func getAll() -> [Value]? { fatalError("Must override") }
}

protocol WritableDataSourceProtocol {
    associatedtype Key: Hashable
    associatedtype Value: CodableProtocol

    func addOrUpdate(value: Value) -> Value?
    func addOrUpdateAll(values: [Value]) -> [Value]?
    func deleteByKey(key: Key) throws
    func deleteAll() throws
}

class WriteableDataSource<Key: Hashable, Value: CodableProtocol>: WritableDataSourceProtocol {
    func addOrUpdate(value: Value) -> Value? { fatalError("Must override") }
    func addOrUpdateAll(values: [Value]) -> [Value]? { fatalError("Must override") }
    func deleteByKey(key: Key) throws { fatalError("Must override") }
    func deleteAll() throws { fatalError("Must override") }
}

protocol CacheDataSourceProtocol: ReadableDataSourceProtocol, WritableDataSourceProtocol {
    var policies: [CachePolicy<Value>] { get set }
    func isValid(value: Value) -> Bool
}

class CacheDataSource<Key: Hashable, Value: CodableProtocol>: CacheDataSourceProtocol {
    var policies: [CachePolicy<Value>] = []

    func getByKey(key: Key) -> Value? { fatalError("Must override") }
    func getAll() -> [Value]? { fatalError("Must override") }

    func addOrUpdate(value: Value) -> Value? { fatalError("Must override") }
    func addOrUpdateAll(values: [Value]) -> [Value]? { fatalError("Must override") }
    func deleteByKey(key: Key) throws { fatalError("Must override") }
    func deleteAll() throws { fatalError("Must override") }

    func isValid(value: Value) -> Bool { fatalError("Must override") }
}
