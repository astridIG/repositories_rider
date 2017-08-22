import Foundation

class BaseRepository<K: Hashable, V: Codable>: ReadableDataSourceProtocol, WritableDataSourceProtocol {

    private var readableDataSources = [ReadableDataSource<K, V>]()
    private var writableDataSources = [WriteableDataSource<K, V>]()
    private var cacheDataSources = [CacheDataSource<K, V>]()

    func addReadablaDataSource(readableDataSources: ReadableDataSource<K, V>) {
        self.readableDataSources.append(readableDataSources)
    }

    func addWritableDataSources(writableDataSources: WriteableDataSource<K, V>) {
        self.writableDataSources.append(writableDataSources)
    }

    func addCacheDataSources(cacheDataSources: CacheDataSource<K, V>) {
        self.cacheDataSources.append(cacheDataSources)
    }

    // MARK: ReadableDataSourceProtocol
    func getByKey(key: K) -> V? {
        return getByKey(key: key, policy: ReadPolicy.readAll)
    }

    func getByKey(key: K, policy: ReadPolicy) -> V? {
        var value: V? = nil

        if (policy.useCache()) {
            value = getValueFromCaches(id: key)
        }

        if (value == nil && policy.useReadable()) {
            value = getValueFromReadables(key: key)
        }

        if let value = value {
            populateCaches(value: value)
        }

        return value
    }

    func getAll() -> [V]? {
        return getAll(policy: ReadPolicy.readAll)
    }

    func getAll(policy: ReadPolicy) -> [V]? {
        var values: [V]? = nil

        if (policy.useCache()) {
            values = valuesFromCaches
        }

        if (values == nil && policy.useReadable()) {
            values = valuesFromReadables
        }

        if let values = values {
            populateCaches(values: values)
        }

        return values
    }

    // MARK: WritableDataSourceProtocol
    func addOrUpdate(value: V) -> V? {
        var updatedValue: V? = nil

        for writableDataSource in writableDataSources {
            updatedValue = writableDataSource.addOrUpdate(value: value)
        }

        if let updatedValue = updatedValue {
            populateCaches(value: updatedValue)
        }

        return updatedValue
    }

    func addOrUpdateAll(values: [V]) -> [V]? {
        var updatedValues: [V]? = nil

        for writableDataSource in writableDataSources {
            updatedValues = writableDataSource.addOrUpdateAll(values: values)
        }

        if let updatedValues = updatedValues {
            populateCaches(values: updatedValues)
        }

        return updatedValues
    }

    func deleteByKey(key: K) {
        writableDataSources.forEach { writableDataSource in
            writableDataSource.deleteByKey(key: key)
        }
        cacheDataSources.forEach { cacheDataSource in
            cacheDataSource.deleteByKey(key: key)
        }
    }

    func deleteAll() {
        writableDataSources.forEach { writableDataSource in
            writableDataSource.deleteAll()
        }
        cacheDataSources.forEach { cacheDataSource in
            cacheDataSource.deleteAll()
        }
    }

    // MARK: Private
    private func getValueFromCaches(id: K) -> V? {
        var value: V? = nil

      for cacheDataSource in cacheDataSources {
        value = cacheDataSource.getByKey(key: id)

            if let val = value {
                if (cacheDataSource.isValid(value: val)) {
                    break
                } else {
                    cacheDataSource.deleteByKey(key: id)
                    value = nil
                }
            }
        }
        return value
    }

    private func getValueFromReadables(key: K) -> V? {
        var value: V? = nil

        for readableDataSource in readableDataSources {
            value = readableDataSource.getByKey(key: key)

            if let _ = value {
                break
            }
        }

        return value
    }

    private var valuesFromCaches: [V]? {
        get {
            var values: [V]? = nil

            for cacheDataSource in cacheDataSources.reversed() {
                values = cacheDataSource.getAll()

                if let val = values {
                    if areValidValues(values: val, cacheDataSource: cacheDataSource) {
                        break
                    } else {
                        cacheDataSource.deleteAll()
                        values = nil
                    }
                }
            }

        return values
        }
    }

    private var valuesFromReadables: [V]? {
        var values: [V]? = nil

        for readableDataSource in readableDataSources {
            values = readableDataSource.getAll()

            if let _ = values {
                break
            }
        }

        return values
    }

    private func populateCaches(value: V) {
        cacheDataSources.forEach { cacheDataSource in
            let _ = cacheDataSource.addOrUpdate(value: value)
        }

        if let cacheDataSource =  cacheDataSources.first,
            let updatedValue = cacheDataSource.getAll() {
            populateCaches(values: updatedValue)
        }
    }

    private func populateCaches(values: [V]) {
        cacheDataSources.forEach { cacheDataSource in
            let _ = cacheDataSource.addOrUpdateAll(values: values)
        }
    }

    private func areValidValues(values: [V], cacheDataSource: CacheDataSource<K, V>) -> Bool {
//        return values.forEach { value in
//            cacheDataSource.isValid(value: value)
//        }
        return true
    }
}

