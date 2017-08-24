import Foundation
import XCTest
@testable import repositories

class SQLiteDataSourceTest: XCTestCase {

    let timeUnit = NSDate().timeIntervalSince1970 * 3000
    let dbName = "test_db"
    let version = 1
    let ttl = 12

    let test1 = TestValue(id: "id1")
    let test2 = TestValue(id: "id2")
    let test3 = TestValue(id: "id3")

    func testShouldAddValue() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: ttl, timeUnit: timeUnit, timeProvider: TimeProvider())
        let sqlLiteDataSource = SQLiteDataSource(version: version, dbName: dbName, policies: [cachePolicy], isCache: false, sqliteRuntimeConfiguration: SQLiteRuntimeConfiguration.defaultConfiguration)

        let value = sqlLiteDataSource.addOrUpdate(value: test1)

        XCTAssert(value == test1 )
    }

    func testAddOrUpdateValues() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: ttl, timeUnit: timeUnit, timeProvider: TimeProvider())
        let sqlLiteDataSource = SQLiteDataSource(version: version, dbName: dbName, policies: [cachePolicy], isCache: false, sqliteRuntimeConfiguration: SQLiteRuntimeConfiguration.defaultConfiguration)

        let values = sqlLiteDataSource.addOrUpdateAll(values: [test1, test2, test3])

        XCTAssert(values?.count == 3)
    }

    func testShouldGetValueByKey() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: ttl, timeUnit: timeUnit, timeProvider: TimeProvider())
        let sqlLiteDataSource = SQLiteDataSource(version: version, dbName: dbName, policies: [cachePolicy], isCache: false, sqliteRuntimeConfiguration: SQLiteRuntimeConfiguration.defaultConfiguration)

        _ = sqlLiteDataSource.addOrUpdate(value: test1)
        let value = sqlLiteDataSource.getByKey(key: "id1")
        
        XCTAssert(value?.id == "id1")
    }

    func testShouldGetValueByKeyFromEmptyDB() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: ttl, timeUnit: timeUnit, timeProvider: TimeProvider())
        let sqlLiteDataSource = SQLiteDataSource(version: version, dbName: dbName, policies: [cachePolicy], isCache: false, sqliteRuntimeConfiguration: SQLiteRuntimeConfiguration.defaultConfiguration)

        sqlLiteDataSource.deleteAll()
        let value = sqlLiteDataSource.getByKey(key: "id1")

        XCTAssert(value == nil)
    }

    func testShouldGetAllValues() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: ttl, timeUnit: timeUnit, timeProvider: TimeProvider())
        let sqlLiteDataSource = SQLiteDataSource(version: version, dbName: dbName, policies: [cachePolicy], isCache: false, sqliteRuntimeConfiguration: SQLiteRuntimeConfiguration.defaultConfiguration)

        _ = sqlLiteDataSource.addOrUpdateAll(values: [test1, test2, test3])
        let count = sqlLiteDataSource.getAll()?.count

        XCTAssert(count == 3)
    }

    func testShouldDeleteValue() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: ttl, timeUnit: timeUnit, timeProvider: TimeProvider())
        let sqlLiteDataSource = SQLiteDataSource(version: version, dbName: dbName, policies: [cachePolicy], isCache: false, sqliteRuntimeConfiguration: SQLiteRuntimeConfiguration.defaultConfiguration)

        sqlLiteDataSource.deleteByKey(key: "id1")

        let count = sqlLiteDataSource.getAll()?.count
        XCTAssert(count == 2)
    }

    func testShouldDeleteValues() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: ttl, timeUnit: timeUnit, timeProvider: TimeProvider())
        let sqlLiteDataSource = SQLiteDataSource(version: version, dbName: dbName, policies: [cachePolicy], isCache: false, sqliteRuntimeConfiguration: SQLiteRuntimeConfiguration.defaultConfiguration)

        sqlLiteDataSource.deleteAll()

        let count = sqlLiteDataSource.getAll()?.count
        XCTAssert(count == nil)
    }
}
