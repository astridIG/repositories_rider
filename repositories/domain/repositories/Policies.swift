import Foundation

enum  ReadPolicy {
    case cacheOnly
    case readableOnly
    case readAll
}

extension ReadPolicy {
    func useCache() -> Bool {
        return self == ReadPolicy.cacheOnly || self == ReadPolicy.readAll
    }

    func useReadable() -> Bool {
        return self == ReadPolicy.readableOnly || self == ReadPolicy.readAll
    }
}
