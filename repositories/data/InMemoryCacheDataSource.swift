//
//class InMemoryCacheDataSource<K:Hashable, V: Identifiable<K>> : ReadableDataSource<K, V> {
//
//    var version: Int
//    var timeProvider: TimeProvider
//    var policies : [CachePolicy<K,V>]
//
//    init(version: Int, timeProvider: TimeProvider, policies : [CachePolicy<K,V>]) {
//        self.version = version
//        self.timeProvider = timeProvider
//        self.policies = policies
//    }
//
//    var items = [K : CacheItem<V>]()
//
//    override func getByKey(key: K) -> V? {
//        return items[key]?.value
//
//    }
//
//    override func getAll() -> [V]? {
//        return items.map { $0.value}
//    }
//
//    func addOrUpdate(value: V) -> V {
//        items.put(value.key, cacheItemFor(value: value))
//        return value
//    }
//
//    private func cacheItemFor(value: V) -> CacheItem<V> {
//        return CacheItem(value: value, version: version, timestamp: timeProvider.currentTimeMillis())
//    }
//
//    func addOrUpdateAll(values: [V]) -> [V] {
//        for value in values {
//            addOrUpdate(value: value)
//        }
//        return values
//    }
//
//    func deleteByKey(key: K) {
//        items.remove(key)
//    }
//
//    func deleteAll() {
//        items.clear()
//    }
//
//    func isValid(value: V) -> Bool {
//        if let cacheItem = items[value.key] {
//            return policies.all { self.isValid(value: cacheItem) }
//        }
//        return false
//    }
//
//}

