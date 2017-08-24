import Foundation
import XCTest
@testable import repositories

class MemoryDataSourceTest: XCTestCase {

    let timeUnit = NSDate().timeIntervalSince1970 * 3000
    let version = 1
    let ttl = 12

    let test1 = TestValue(id: "id1")
    let test2 = TestValue(id: "id2")
    let test3 = TestValue(id: "id3")


    func testShouldAddValueUsingCachePolicyTtl() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: ttl, timeUnit: timeUnit, timeProvider: TimeProvider())
        let memoryDataSource = MemoryDataSource(version: version, policies: [cachePolicy], isCache: false)

        let value = memoryDataSource.addOrUpdate(value: test1)

        XCTAssert(value == test1)
    }

    func testShouldAddValueUsingCachePolicyVersion() {
        let cachePolicy = CachePolicyVersion<TestValue>(version: version)
        let memoryDataSource = MemoryDataSource(version: version, policies: [cachePolicy], isCache: false)

        let value = memoryDataSource.addOrUpdate(value: test1)

        XCTAssert(value == test1)
    }

    func testAddOrUpdateValues() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: ttl, timeUnit: timeUnit, timeProvider: TimeProvider())
        let memoryDataSource = MemoryDataSource(version: version, policies: [cachePolicy], isCache: false)

        let values = memoryDataSource.addOrUpdateAll(values: [test1, test2, test3])

        XCTAssert(values?.count == 3)
    }

    func testShouldGetValueByKey() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: ttl, timeUnit: timeUnit, timeProvider: TimeProvider())
        let memoryDataSource = MemoryDataSource(version: version, policies: [cachePolicy], isCache: false)

        _ = memoryDataSource.addOrUpdate(value: test1)
        let value = memoryDataSource.getByKey(key: "id1")

        XCTAssert(value?.id == "id1")
    }

    func testShouldGetValueByKeyUsingCachePolicyVersion() {
        let cachePolicy = CachePolicyVersion<TestValue>(version: version)
        let memoryDataSource = MemoryDataSource(version: version, policies: [cachePolicy], isCache: false)

        _ = memoryDataSource.addOrUpdate(value: test1)
        let value = memoryDataSource.getByKey(key: "id1")

        XCTAssert(value?.id == "id1")
    }


    func testShouldGetValueByKeyFromEmptyMemory() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: ttl, timeUnit: timeUnit, timeProvider: TimeProvider())
        let memoryDataSource = MemoryDataSource(version: version, policies: [cachePolicy], isCache: false)

        let value = memoryDataSource.getByKey(key: "id1")

        XCTAssert(value?.id == nil)
    }

    func testShouldGetAllValuesFromEmptyMemory() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: ttl, timeUnit: timeUnit, timeProvider: TimeProvider())
        let memoryDataSource = MemoryDataSource(version: version, policies: [cachePolicy], isCache: false)

        let count = memoryDataSource.getAll()?.count

        XCTAssert(count == nil)
    }

    func testShouldGetAllValues() {

        let cachePolicy = CachePolicyTtl<TestValue>(ttl: ttl, timeUnit: timeUnit, timeProvider: TimeProvider())
        let memoryDataSource = MemoryDataSource(version: version, policies: [cachePolicy], isCache: false)

        _ = memoryDataSource.addOrUpdateAll(values: [test1, test2, test3])

        let count = memoryDataSource.getAll()?.count

        XCTAssert(count == 3)
    }

    func testShouldDeleteValue() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: ttl, timeUnit: timeUnit, timeProvider: TimeProvider())
        let memoryDataSource = MemoryDataSource(version: version, policies: [cachePolicy], isCache: false)

        _ = memoryDataSource.addOrUpdateAll(values: [test1, test2, test3])
        memoryDataSource.deleteByKey(key: "id1")

        let count = memoryDataSource.getAll()?.count
        XCTAssert(count == 2)
    }

    func testShouldDeleteValues() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: ttl, timeUnit: timeUnit, timeProvider: TimeProvider())
        let memoryDataSource = MemoryDataSource(version: version, policies: [cachePolicy], isCache: false)

        _ = memoryDataSource.addOrUpdateAll(values: [test1, test2, test3])
        memoryDataSource.deleteAll()

        let count = memoryDataSource.getAll()?.count
        XCTAssert(count == 0)
    }
}
