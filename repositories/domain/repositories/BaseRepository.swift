import Foundation

class BaseRepository<Key: Hashable, Value: Codable>: ReadableDataSourceProtocol, WritableDataSourceProtocol {

    private var readableDataSources = [ReadableDataSource<Key, Value>]()
    private var writableDataSources = [WriteableDataSource<Key, Value>]()
    private var cacheDataSources = [CacheDataSource<Key, Value>]()

    func addReadablaDataSource(readableDataSources: ReadableDataSource<Key, Value>) {
        self.readableDataSources.append(readableDataSources)
    }

    func addWritableDataSources(writableDataSources: WriteableDataSource<Key, Value>) {
        self.writableDataSources.append(writableDataSources)
    }

    func addCacheDataSources(cacheDataSources: CacheDataSource<Key, Value>) {
        self.cacheDataSources.append(cacheDataSources)
    }

    // MARK: ReadableDataSourceProtocol
    func getByKey(key: Key) -> Value? {
        return getByKey(key: key, policy: ReadPolicy.readAll)
    }

    func getByKey(key: Key, policy: ReadPolicy) -> Value? {
        var value: Value? = nil

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

    func getAll() -> [Value]? {
        return getAll(policy: ReadPolicy.readAll)
    }

    func getAll(policy: ReadPolicy) -> [Value]? {
        var values: [Value]? = nil

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
    func addOrUpdate(value: Value) -> Value? {
        var updatedValue: Value? = nil

        for writableDataSource in writableDataSources {
            updatedValue = writableDataSource.addOrUpdate(value: value)
        }

        if let updatedValue = updatedValue {
            populateCaches(value: updatedValue)
        }

        return updatedValue
    }

    func addOrUpdateAll(values: [Value]) -> [Value]? {
        var updatedValues: [Value]? = nil

        for writableDataSource in writableDataSources {
            updatedValues = writableDataSource.addOrUpdateAll(values: values)
        }

        if let updatedValues = updatedValues {
            populateCaches(values: updatedValues)
        }

        return updatedValues
    }

    func deleteByKey(key: Key) {
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
    private func getValueFromCaches(id: Key) -> Value? {
        var value: Value? = nil

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

    private func getValueFromReadables(key: Key) -> Value? {
        var value: Value? = nil

        for readableDataSource in readableDataSources {
            value = readableDataSource.getByKey(key: key)

            if let _ = value {
                break
            }
        }

        return value
    }

    private var valuesFromCaches: [Value]? {
        get {
            var values: [Value]? = nil

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

    private var valuesFromReadables: [Value]? {
        var values: [Value]? = nil

        for readableDataSource in readableDataSources {
            values = readableDataSource.getAll()

            if let _ = values {
                break
            }
        }

        return values
    }

    private func populateCaches(value: Value) {
        cacheDataSources.forEach { cacheDataSource in
            let _ = cacheDataSource.addOrUpdate(value: value)
        }

        if let cacheDataSource =  cacheDataSources.first,
            let updatedValue = cacheDataSource.getAll() {
            populateCaches(values: updatedValue)
        }
    }

    private func populateCaches(values: [Value]) {
        cacheDataSources.forEach { cacheDataSource in
            let _ = cacheDataSource.addOrUpdateAll(values: values)
        }
    }

    private func areValidValues(values: [Value], cacheDataSource: CacheDataSource<Key, Value>) -> Bool {
        return values.reduce(true) { (result, value) in
            return result && cacheDataSource.isValid(value: value)
        }
    }
}
