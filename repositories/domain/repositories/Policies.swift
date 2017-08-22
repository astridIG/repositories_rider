import Foundation

/*
 Value to specify modifiers over the retrieval operations on repositories and data sources.
*/
enum  ReadPolicy {
    case cacheOnly
    case readableOnly
    case readAll
}

extension ReadPolicy {
    func useCache() -> Bool {
        return self == ReadPolicy.readableOnly || self == ReadPolicy.readAll
    }

    func useReadable() -> Bool {
        return self == ReadPolicy.readableOnly || self == ReadPolicy.readAll
    }
}
