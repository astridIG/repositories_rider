import Foundation

protocol CachePolicyProtocol {
    associatedtype Key: Hashable
    associatedtype Value: Codable

    func isValid(cacheItem: CacheItem<Value>) -> Bool
}

class CachePolicy<Key: Hashable, Value: Codable>: CachePolicyProtocol {
    func isValid(cacheItem: CacheItem<Value>) -> Bool  { fatalError("Must override") }
}

class CachePolicyTtl<Key, Value: Codable>: CachePolicy<Key ,Value> where Value.Key == Key {

    private var ttl: Int
    private var timeUnit: TimeInterval
    private var timeProvider: TimeProvider

    init(ttl: Int, timeUnit: TimeInterval, timeProvider: TimeProvider) {
        self.ttl = ttl
        self.timeUnit = timeUnit
        self.timeProvider = timeProvider
    }

    override func isValid(cacheItem: CacheItem<Value>) -> Bool {
        let lifeTime = cacheItem.timestamp + timeUnit
        return lifeTime > timeProvider.currentTimeMillis()
    }

}

class CachePolicyVersion<Key, Value: Codable>: CachePolicy<Key ,Value> where Value.Key == Key {

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
