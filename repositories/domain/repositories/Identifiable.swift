import Foundation

protocol Identifiable {
    associatedtype Key: Hashable

    func getKey() -> Key
}
