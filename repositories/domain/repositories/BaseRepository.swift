import Foundation

class BaseRepository<K,V : Identifiable<K>>: ReadableDataSource<K, V> {

    private var readableDataSources = [ReadableDataSource<K, V>]()

    func addReadablaDataSource(readableDataSources: ReadableDataSource<K, V>) {
        self.readableDataSources.append(readableDataSources)
    }


    func getByKey(key: K, policy: ReadPolicy) -> V? {
        var value: V? = nil

        if (policy.useCache()) {
            value = getValueFromCaches(id: key)
        }

        if (value == nil && policy.useReadable()) {
            value = getValueFromReadables(key: key)
        }

        if (value != nil) {
            populateCaches(value: value)
        }

        return value
    }

    func getAll(policy: ReadPolicy) -> [V]? {
        var values: [V]? = nil

        if (policy.useCache()) {
            values = valuesFromCaches
        }

        if (values == nil && policy.useReadable()) {
            values = valuesFromReadables
        }

        if (values != nil) {
            populateCaches(values: values)
        }

        return values
    }

    private func getValueFromCaches(id: K) -> V? {
        var value: V? = nil

//      for (cacheDataSource in cacheDataSources) {
//            value = cacheDataSource.getByKey(id)
//
//            if (value != nil) {
//                if (cacheDataSource.isValid(value)) {
//                    break
//                } else {
//                    cacheDataSource.deleteByKey(id)
//                    value = null
//                }
//            }
//        }
        return value
    }

    private func getValueFromReadables(key: K) -> V? {
        var value: V? = nil

        for readableDataSource in readableDataSources {
            value = readableDataSource.getByKey(key: key)

            if (value != nil) {
                break
            }
        }

        return value
    }

    private var valuesFromCaches: [V]? {
        return nil
    }

    private var valuesFromReadables: [V]? {
        var values: [V]? = nil

        for readableDataSource in readableDataSources {
            values = readableDataSource.getAll()

            if (values != nil) {
                break
            }
        }

        return values
    }

    private func populateCaches(value: V) {
    }

    private func populateCaches(values: [V]?) {
    }

    private func populateCaches(value: V?) {
    }

    override func getByKey(key: K) -> V? {
        return getByKey(key: key, policy: ReadPolicy.readAll)
    }

    override func getAll() -> [V]? {
        return getAll(policy: ReadPolicy.readAll)
    }
}

