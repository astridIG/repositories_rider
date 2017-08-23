import Foundation
import XCTest
@testable import repositories

class BaseRespositoryTest: XCTestCase {

    var readableDataSource = ReadableDataSourceMock<String, TestValue>()
    var writeableDataSource = WriteableDataSourceMock<String, TestValue>()
    var cacheDataSource = CacheDataSourceMock<String, TestValue>()

    var repositoryMother: RepositoryMother<String, TestValue>?

    override func setUp() {
        repositoryMother = RepositoryMother<String, TestValue>(readableDataSources: [readableDataSource], writeableDataSources: [writeableDataSource], cacheDataSource:[cacheDataSource])
    }

    func testshouldReturnNullIfThereAreNoDataSourcesWithData() {
        let repository = repositoryMother!.givenAReadableAndCacheRepository()
        readableDataSource.returnCollectionValue = nil
        cacheDataSource.returnCollectionValue = nil
        let values = repository.getAll()
        XCTAssertNil(values)
    }
}
