import Foundation
import XCTest
@testable import repositories

class MemoryDataSourceTest: XCTestCase {

    let timeUnit = NSDate().timeIntervalSince1970 * 3000
    let dbName = "test_db"
    let version = 1

    func testShouldAddValue() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: 12, timeUnit: timeUnit, timeProvider: TimeProvider())
        let memoryDataSource = MemoryDataSource(version: version, policies: [cachePolicy], isCache: false)

        let test1 = TestValue(id: "id1")
        let value = memoryDataSource.addOrUpdate(value: test1)

        XCTAssert(value == test1)
    }

    func testAddOrUpdateValues() {
        let test1 = TestValue(id: "id1")
        let test2 = TestValue(id: "id2")
        let test3 = TestValue(id: "id3")

        let cachePolicy = CachePolicyTtl<TestValue>(ttl: 12, timeUnit: timeUnit, timeProvider: TimeProvider())
        let memoryDataSource = MemoryDataSource(version: version, policies: [cachePolicy], isCache: false)

        let values = memoryDataSource.addOrUpdateAll(values: [test1, test2, test3])

        XCTAssert(values?.count == 3)
    }

    func testShouldGetValueByKey() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: 12, timeUnit: timeUnit, timeProvider: TimeProvider())
        let memoryDataSource = MemoryDataSource(version: version, policies: [cachePolicy], isCache: false)

        let test1 = TestValue(id: "id1")
        _ = memoryDataSource.addOrUpdate(value: test1)
        
        let value = memoryDataSource.getByKey(key: "id1")

        XCTAssert(value?.id == "id1")
    }


    func testShouldGetValueByKeyButMemoryIsEmpty() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: 12, timeUnit: timeUnit, timeProvider: TimeProvider())
        let memoryDataSource = MemoryDataSource(version: version, policies: [cachePolicy], isCache: false)

        let value = memoryDataSource.getByKey(key: "id1")

        XCTAssert(value?.id == nil)
    }

    func testShouldGetAllValuesButMemoryIsEmpty() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: 12, timeUnit: timeUnit, timeProvider: TimeProvider())
        let memoryDataSource = MemoryDataSource(version: version, policies: [cachePolicy], isCache: false)

        let count = memoryDataSource.getAll()?.count

        XCTAssert(count == nil)
    }

    func testShouldGetAllValues() {

        let test1 = TestValue(id: "id1")
        let test2 = TestValue(id: "id2")
        let test3 = TestValue(id: "id3")

        let cachePolicy = CachePolicyTtl<TestValue>(ttl: 12, timeUnit: timeUnit, timeProvider: TimeProvider())
        let memoryDataSource = MemoryDataSource(version: version, policies: [cachePolicy], isCache: false)

        _ = memoryDataSource.addOrUpdateAll(values: [test1, test2, test3])

        let count = memoryDataSource.getAll()?.count

        XCTAssert(count == 3)
    }
}
