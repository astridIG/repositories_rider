import Foundation
import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import repositories

class repositoriesTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    func startTestObserver<O: ObservableType>(withScheduler scheduler: TestScheduler = TestScheduler.init(initialClock: 0),
                                              onObservable observable: O) -> TestableObserver<O.E> {
        let observer = scheduler.createObserver(O.E.self)
        _ = observable.subscribe(observer)
        scheduler.start()
        return observer
    }

}
