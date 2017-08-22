import Foundation

protocol CachePolicyProtocol {
    associatedtype Key: Hashable
    associatedtype Value: Codable

    func isValid(cacheItem: CacheItem<Value>) -> Bool
}

class CachePolicyTtl<Key: Hashable, Value: Codable>: CachePolicyProtocol {

    var ttl: Int
    var timeUnit: TimeInterval
    private var timeProvider: TimeProvider

    init(ttl: Int, timeUnit: TimeInterval, timeProvider: TimeProvider) {
        self.ttl = ttl
        self.timeUnit = timeUnit
        self.timeProvider = timeProvider
    }

    func isValid(cacheItem: CacheItem<Value>) -> Bool {
        let lifeTime = cacheItem.timestamp + timeUnit
        return lifeTime > timeProvider.currentTimeMillis()
    }

}

class CachePolicyVersion<K: Hashable, V: Codable> : CachePolicyProtocol {

    private var version: Int

    init(version: Int) {
        self.version = version
    }

    override func isValid(cacheItem: CacheItem<Value>) -> Bool {
        return version <= cacheItem.version
    }

}

class TimeProvider {

    func currentTimeMillis() -> Double {
        return NSDate().timeIntervalSince1970 * 1000
    }

}
