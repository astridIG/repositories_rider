import Foundation

protocol CachePolicyProtocol {
    associatedtype Value: Codable

    func isValid(cacheItem: CacheItem<Value>) -> Bool
}
