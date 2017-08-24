import Foundation
import XCTest
@testable import repositories

class SQLiteDataSourceTest: XCTestCase {

    let timeUnit = NSDate().timeIntervalSince1970 * 3000
    let dbName = "test_db"
    let version = 1

    func testShouldAddValue() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: 12, timeUnit: timeUnit, timeProvider: TimeProvider())
        let sqlLiteDataSource = SQLiteDataSource(version: version, dbName: dbName, policies: [cachePolicy], isCache: false, sqliteRuntimeConfiguration: SQLiteRuntimeConfiguration.defaultConfiguration)

        let test1 = TestValue(id: "id1")
        let value = sqlLiteDataSource.addOrUpdate(value: test1)

        XCTAssert(value == test1 )
    }

    func testAddOrUpdateValues() {
        let test1 = TestValue(id: "id1")
        let test2 = TestValue(id: "id2")
        let test3 = TestValue(id: "id3")

        let cachePolicy = CachePolicyTtl<TestValue>(ttl: 12, timeUnit: timeUnit, timeProvider: TimeProvider())
        let sqlLiteDataSource = SQLiteDataSource(version: version, dbName: dbName, policies: [cachePolicy], isCache: false, sqliteRuntimeConfiguration: SQLiteRuntimeConfiguration.defaultConfiguration)

        let values = sqlLiteDataSource.addOrUpdateAll(values: [test1, test2, test3])

        XCTAssert(values?.count == 3)
    }

    func testShouldGetValueByKey() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: 12, timeUnit: timeUnit, timeProvider: TimeProvider())
        let sqlLiteDataSource = SQLiteDataSource(version: version, dbName: dbName, policies: [cachePolicy], isCache: false, sqliteRuntimeConfiguration: SQLiteRuntimeConfiguration.defaultConfiguration)

        let value = sqlLiteDataSource.getByKey(key: "id1")
        
        XCTAssert(value?.id == "id1")
    }

    func testShouldGetAllValues() {
        let cachePolicy = CachePolicyTtl<TestValue>(ttl: 12, timeUnit: timeUnit, timeProvider: TimeProvider())
        let sqlLiteDataSource = SQLiteDataSource(version: version, dbName: dbName, policies: [cachePolicy], isCache: false, sqliteRuntimeConfiguration: SQLiteRuntimeConfiguration.defaultConfiguration)

        let count = sqlLiteDataSource.getAll()?.count

        XCTAssert(count == 3)
    }
}
