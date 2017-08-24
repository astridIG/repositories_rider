import Foundation

class CacheItem<Value: CodableProtocol> {
    var value: Value
    var version: Int
    var timestamp: Double

    init(value: Value,
         version: Int,
         timestamp:  Double) {
        self.value = value
        self.version = version
        self.timestamp = timestamp
    }
}
