//
//  DataSource.swift

// Data source interface meant to be used only to retrieve data.
//
// @param <K> The class of the key used by this data source.
// @param <V> The class of the values retrieved from this data source.
//
import Foundation

class ReadableDataSource<K, V> {
    func getByKey(key: K) -> V? {
        fatalError("Readable data source needs getByKey method")
    }

    func getAll() -> [V]? {
        fatalError("Readable data source needs getAll method")
    }
}
