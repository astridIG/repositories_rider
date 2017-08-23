class InMemoryCacheDataSource<K, V: Codable>: CacheDataSource<K,V> where V.Key == K {

    var version: Int
    var timeProvider: TimeProvider

    init(version: Int, timeProvider: TimeProvider, policies : [CachePolicy<V>]) {
        self.version = version
        self.timeProvider = timeProvider
        super.init()

        self.policies = policies
    }

    var items = [K : CacheItem<V>]()

    override func getByKey(key: K) -> V? {
        return items[key]?.value

    }

    override func getAll() -> [V]? {
        return items.map {
            $0.value.value
        }
    }

    override func addOrUpdate(value: V) -> V {
        items[value.getKey()] = cacheItemFor(value: value)
        return value
    }

    private func cacheItemFor(value: V) -> CacheItem<V> {
        return CacheItem(value: value, version: version, timestamp: timeProvider.currentTimeMillis())
    }

    override func addOrUpdateAll(values: [V]) -> [V] {
        for value in values {
            let _ = addOrUpdate(value: value)
        }
        return values
    }

    override func deleteByKey(key: K) -> Bool {
        items.removeValue(forKey: key)
        return true
    }

    override func deleteAll() -> Bool {
        items.removeAll()
        return true
    }

    override func isValid(value: V) -> Bool {
        if let cacheItem = items[value.getKey()] {
            return policies.reduce(true) { (result, policy) in
                return result && policy.isValid(cacheItem: cacheItem)
            }
        }
        return false
    }

}
