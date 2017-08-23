import XCTest
@testable import repositories
@testable import FMDB
@testable import RxSwift

class repositoriesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {

        let user = User(id: "id1", name: "usernameq")
        let user2 = User(id: "id2", name: "username2")
        let user3 = User(id: "id3", name: "username3")
        let timeUnit = NSDate().timeIntervalSince1970 * 3000
        let dbName = "test_db"

        let cachePolicy = CachePolicyTtl<User>(ttl: 12, timeUnit: timeUnit, timeProvider: TimeProvider())
        let version = 5
        let sqlLiteDataSource = SQLiteDataSource(version: version, dbName: dbName, policies: [cachePolicy], isCache: false, sqliteRuntimeConfiguration: SQLiteRuntimeConfiguration.defaultConfiguration)

        _ = sqlLiteDataSource.addOrUpdate(value: user)

        _ = sqlLiteDataSource.addOrUpdateAll(values: [user2, user3])

        let values = sqlLiteDataSource.getAll()

        let keyUser0 = values?[0].getKey()
        let user0 = sqlLiteDataSource.getByKey(key: keyUser0!)
        if user0?.id == values?[0].id {
            XCTAssert(true)
        }

        if values?.count == 3 {
            XCTAssert(true)
        } else {
            XCTFail("Error, there are not 3 users")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
