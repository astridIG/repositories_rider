import XCTest

extension XCTestCase {

    @nonobjc static let defaultExpectationTimeout: TimeInterval = 0.5

    func waitForExpectations() {
        waitForExpectations(timeout: XCTestCase.defaultExpectationTimeout, handler: nil)
    }
}
