import Foundation

class CacheItem<V: Codable> {

    var value: V
    var version: Int
    var timestamp: Double

    init(value: V,
         version: Int,
         timestamp:  Double) {
        self.value = value
        self.version = version
        self.timestamp = timestamp
    }
}
