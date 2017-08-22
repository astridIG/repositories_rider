class CachePolicy<K, V : Identifiable<K>> {

    func isValid(cacheItem: CacheItem<V>) -> Bool {
        fatalError("cache policy is not valid")
    }
}

