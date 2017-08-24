import Foundation

class MemoryDataSource<Key, Value: CodableProtocol> : CacheDataSource<Key,Value> where Value.Key == Key {
    var items: OrderedDictionary<Key, CacheItem<Value>>!
    let version: Int

    var lastOffsetWithMoreItems: Int

    public init(version: Int, policies: [CachePolicy<Value>], isCache: Bool = true) {
        self.version = version

        let hasVersionPolicy = policies.index { $0 is CachePolicyVersion } != nil

        self.lastOffsetWithMoreItems = NoMoreItemsOffset
        super.init()
        if !hasVersionPolicy {
            self.policies = [CachePolicyVersion(version: version)] + policies
        } else {
            self.policies = policies
        }
    }

    public convenience init(version: Int) {
        self.init(
            version: version,
            policies: [
                CachePolicyVersion(version: version)
            ]
        )
    }

    public convenience init(version: Int, ttl: Int, timeUnit: TimeInterval) {
        self.init(
            version: version,
            policies: [
                CachePolicyVersion(version: version),
                CachePolicyTtl(ttl: ttl, timeUnit: timeUnit, timeProvider: TimeProvider())
            ]
        )
    }

    override func getByKey(key: Key) -> Value? {
        if items != nil && !items.isEmpty, let cachedItem = self.items[key] {
            if self.itemIsValid(item: cachedItem, forCachePolicies: self.policies) {
//                executeAsCriticalSection {
                    // OrderedDictionary implementation of .values makes a temporary array and append elements to it
                    // so we need to make that part of the critical section
                    return cachedItem.value
//                }
            }
        }
        return nil
    }
    // MARK: ReadableDataSource
    override func getAll() -> [Value]? {

        if let cachedItems : OrderedDictionary<Key, CacheItem<Value>> = self.items {
            var filteredItems = [CacheItem<Value>]()

            executeAsCriticalSection {
                // .values must be accessed by a single thread
                filteredItems = cachedItems.values.filter {
                    [unowned self] (item) -> Bool in
                    return self.itemIsValid(item: item, forCachePolicies: self.policies)
                }
            }

            // If there is any invalid item in the list, treat as a miss
            if filteredItems.count != cachedItems.count {
                _ = self.deleteAll()

            } else {
                 // Return the unwrapped items
                return self.unwrapCachedItems(items: filteredItems)
            }
        }

        return nil
    }


    // MARK: WritableDataSource
    override func addOrUpdate(value: Value) -> Value? {
        append(items: [value])
        return value
    }

    override func addOrUpdateAll(values: [Value]) -> [Value]? {
        append(items: values)
        return values
    }

    func append(items: [Value]) {
        executeAsCriticalSection {
            self.ensureDictionaryExists()

            for item in items {
                self.items[item.getKey()] = self.buildCacheItem(item: item, withVersion: self.version)
            }
        }
    }

    override func deleteByKey(key: Key) {
        executeAsCriticalSection {
            _ = self.items.removeEntryForKey(key: key)
        }
    }

    override func deleteAll() {
        executeAsCriticalSection {
            self.items.removeAllEntries()
        }
    }

    // MARK: Private methods
    private func itemIsValid(item: CacheItem<Value>, forCachePolicies policies:[CachePolicy<Value>]) -> Bool {
        return policies.reduce(true) {
            (valid, policy) -> Bool in
            return valid && policy.isValid(cacheItem: item)
        }
    }

    private func buildCacheItem(item: Value, withVersion version: Int) -> CacheItem<Value> {
        return CacheItem(
            value: item,
            version: version,
            timestamp: NSDate().timeIntervalSinceNow
        )
    }

    private func unwrapCachedItems(items: [CacheItem<Value>]) -> [Value] {
        return items.flatMap { (cachedItem: CacheItem<Value>) -> Value? in
            cachedItem.value
        }
    }

    private func ensureDictionaryExists() {
        if items == nil {
            items = OrderedDictionary<Key, CacheItem<Value>>()
        }
    }

    func executeAsCriticalSection(block: () -> ()) {
        objc_sync_enter(self)
        block()
        objc_sync_exit(self)
    }
}
