import Foundation
import RxSwift

enum RepositoryError: Error {
    case elementNotFound
    case unknown
}

class ReactiveBaseRepository<Key: Hashable, Value: CodableProtocol> : BaseRepository<Key, Value> {

    func getByKeyReactive(key: Key) -> Observable<Value> {
        return getByKeyReactive(key: key, policy: ReadPolicy.readAll)
    }

    func getByKeyReactive(key: Key, policy: ReadPolicy) -> Observable<Value> {
        return Observable.create({ [weak self] observer -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            let item = strongSelf.getByKey(key: key, policy: policy)
            if let item = item {
                observer.onNext(item)
                observer.onCompleted()
            } else {
                observer.onError(RepositoryError.elementNotFound)
            }
            return Disposables.create()
        })
    }

    func getAllReactive() -> Observable<[Value]> {
        return getAllReactive(policy: ReadPolicy.readAll)
    }

    func getAllReactive(policy: ReadPolicy) -> Observable<[Value]> {
        return Observable.create({ [weak self] observer -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            let allItems = strongSelf.getAll(policy: policy)
            if let allItems = allItems {
                observer.onNext(allItems)
                observer.onCompleted()
            } else {
                observer.onError(RepositoryError.elementNotFound)
            }
            return Disposables.create()
        })
    }

    func addOrUpdateReactive(value: Value) -> Observable<Value?> {
        return Observable.just(addOrUpdate(value: value))
    }

    func addOrUpdateAllReactive(values: [Value]) -> Observable<[Value]?> {
        return Observable.just(addOrUpdateAll(values: values))
    }

    func deleteByKeyReactive(key: Key) -> Completable {
        if self.deleteByKey(key: key) {
            return Completable.empty()
        } else {
            return Completable.error(RepositoryError.unknown)
        }
    }

    func deleteAllReactive() -> Completable {
        if self.deleteAll() {
            return Completable.empty()
        } else {
            return Completable.error(RepositoryError.unknown)
        }
    }

}
