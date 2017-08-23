import Foundation

protocol CachePolicyProtocol {
    associatedtype Value: CodableProtocol

    func isValid(cacheItem: CacheItem<Value>) -> Bool
}
