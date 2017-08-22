import Foundation

class CachePolicyTtl<K,  V : Identifiable<K>> : CachePolicy<K, V> {
    var ttl: Int
    var timeUnit: TimeInterval
    private var timeProvider: TimeProvider

    init(ttl: Int, timeUnit: TimeInterval, timeProvider: TimeProvider) {
        self.ttl = ttl
        self.timeUnit = timeUnit
        self.timeProvider = timeProvider
    }

    override func isValid(cacheItem : CacheItem<V>) -> Bool {
        let lifeTime = cacheItem.timestamp + timeUnit
        return lifeTime > timeProvider.currentTimeMillis()
    }

}


class CachePolicyVersion<K, V : Identifiable<K>> : CachePolicy<K, V> {

    private var version: Int

    init(version: Int) {
        self.version = version
    }

    override func isValid(cacheItem: CacheItem<V>) -> Bool {
        return version <= cacheItem.version
    }

}


class TimeProvider {

    func currentTimeMillis() -> Double {
        return NSDate().timeIntervalSince1970 * 1000
    }

}

