import Foundation

class CachePolicy<Value: Codable>: CachePolicyProtocol {
    func isValid(cacheItem: CacheItem<Value>) -> Bool  { fatalError("Must override") }
}

class CachePolicyTtl<Value: Codable>: CachePolicy<Value> {

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

class CachePolicyVersion<Value: Codable>: CachePolicy<Value> {

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
