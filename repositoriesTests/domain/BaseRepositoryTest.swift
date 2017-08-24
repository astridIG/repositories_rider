import Foundation
import XCTest
@testable import repositories

class BaseRespositoryTest: XCTestCase {

    var readableDataSource = ReadableDataSourceMock<String, TestValue>()
    var writeableDataSource = WriteableDataSourceMock<String, TestValue>()
    var cacheDataSource = CacheDataSourceMock<String, TestValue>()

    var repositoryMother: RepositoryMother?

    override func setUp() {
        repositoryMother = RepositoryMother(readableDataSource: readableDataSource, writeableDataSource: writeableDataSource, cacheDataSource: cacheDataSource)
    }

    func testshouldReturnNilIfThereAreNoDataSourcesWithData() {
        let repository = repositoryMother!.givenAReadableAndCacheRepository()
        readableDataSource.returnCollectionValue = nil
        cacheDataSource.returnCollectionValue = nil

        let values = repository.getAll()

        XCTAssertNil(values)
    }

    func testshouldReturnDataFromCacheDataSourceIfDataIsValid() {
        let cacheValues = repositoryMother!.givenCacheDataSourceReturnsValidValues()
        repositoryMother!.givenReadableDataSourceReturnsNil()
        let repository = repositoryMother!.givenAReadableAndCacheRepository()

        let values = repository.getAll()

        XCTAssertEqual(cacheValues, values!)
    }

    func testshouldReturnDataFromReadableDataSourceIfCacheDataSourceReturnsNilOnGetAll() {
        repositoryMother!.givenCacheDataSourceReturnsNil()
        let readableValues = repositoryMother!.givenReadableDataSourceReturnsValidValues()
        let repository = repositoryMother!.givenAReadableAndCacheRepository()

        let values = repository.getAll()

        XCTAssertEqual(readableValues, values!)
    }

    func testShouldReturnDataFromReadableDataSourceIfTheCacheDataSourceReturnsNoValidData() {
        let _ = repositoryMother!.givenCacheDataSourceReturnsNonValidValues()
        let readableValues = repositoryMother!.givenReadableDataSourceReturnsValidValues()
        let repository = repositoryMother!.givenAReadableAndCacheRepository()

        let values = repository.getAll()

        XCTAssertEqual(readableValues, values!)
    }

//    func shouldPropagateExceptionsThrownByAnyDataSource() {
//        mother.givenReadableDataSourceThrowsException(IOException())
//        var repository = mother.givenARepository(of(RepositoryMother.DataSource.READABLE))
//
//        repository.getAll()
//    }

    func testShouldGetDataFromReadableDataSourceIfReadPolicyForcesOnlyReadable() {
        let _ = repositoryMother!.givenCacheDataSourceReturnsValidValues()
        let _ = repositoryMother!.givenReadableDataSourceReturnsValidValues()
        let repository = repositoryMother?.givenAReadableAndCacheRepository()

        let expect = expectation(description: "Readable data source was called")
        readableDataSource.getAllCompletionBlock = {
            expect.fulfill()
        }

        var cacheGetAllCalled = false
        cacheDataSource.getAllCompletionBlock = {
            cacheGetAllCalled = true
        }

        let _ = repository!.getAll(policy: ReadPolicy.readableOnly)

        waitForExpectations()
        XCTAssertFalse(cacheGetAllCalled)
    }

    func testShouldPopulateCacheDataSources() {
        repositoryMother!.givenCacheDataSourceReturnsNil()
        let readableValues = repositoryMother!.givenReadableDataSourceReturnsValidValues()
        let repository = repositoryMother!.givenAReadableAndCacheRepository()

        let expect = expectation(description: "Cache data source should add or update all")
        cacheDataSource.addOrUpdateAllCompletionBlock = { (values) in
            XCTAssertEqual(readableValues, values)
            expect.fulfill()
        }
        let _ = repository.getAll()

        waitForExpectations()
    }

    func testShouldDeleteAllFromCacheDataSourceIfDataIsNotValid() {
        let _ = repositoryMother!.givenCacheDataSourceReturnsNonValidValues()
        let repository = repositoryMother!.givenAReadableAndCacheRepository()

        let expect = expectation(description: "Cache data source should delete all")
        cacheDataSource.deleteAllCompletionBlock = {
            expect.fulfill()
        }

        let _ = repository.getAll()

        waitForExpectations()
    }

    func testShouldReturnValueByKeyFromCacheDataSource() {
        let cacheValue = repositoryMother!.givenCacheDataSourceReturnsValidValueWithKey(key: repositoryMother!.key)
        let repository = repositoryMother!.givenAReadableAndCacheRepository()

        let value = repository.getByKey(key: repositoryMother!.key)

        XCTAssertEqual(cacheValue, value)
    }

    func testShouldReturnValueFromReadableDataSourceIfCacheDataSourceValueIsNil() {
        repositoryMother!.givenCacheDataSourceReturnsNil()
        let readableValue = repositoryMother!.givenReadableDataSourceReturnsValidValueWithKey(key: repositoryMother!.key)
        let repository = repositoryMother!.givenAReadableAndCacheRepository()

        let value = repository.getByKey(key: repositoryMother!.key)

        XCTAssertEqual(readableValue, value)
    }

    func testShouldReturnItemFromReadableDataSourceIfCacheDataSourceValueIsNotValid() {
        let _ = repositoryMother!.givenCacheDataSourceReturnsNonValidValueWithKey(key: repositoryMother!.key)
        let readableValue = repositoryMother!.givenReadableDataSourceReturnsValidValueWithKey(key: repositoryMother!.key)
        let repository = repositoryMother!.givenAReadableAndCacheRepository()

        let value = repository.getByKey(key: repositoryMother!.key)

        XCTAssertEqual(readableValue, value)
    }

    func testShouldPopulateCacheDataSourceWithValueIfCacheDataSourceIsNotValid() {
        let _ = repositoryMother!.givenCacheDataSourceReturnsNonValidValueWithKey(key: repositoryMother!.key)
        let readableValue = repositoryMother!.givenReadableDataSourceReturnsValidValueWithKey(key: repositoryMother!.key)
        let repository = repositoryMother!.givenAReadableAndCacheRepository()

        let expect = expectation(description: "Cache data source should add or update value")
        cacheDataSource.addOrUpdateCompletionBlock = { (value) in
            XCTAssertEqual(readableValue, value)
            expect.fulfill()
        }

        let _ = repository.getByKey(key: repositoryMother!.key)

        waitForExpectations()
    }

    func testShouldDeleteValuesIfAreNotValid() {
        let _ = repositoryMother!.givenCacheDataSourceReturnsNonValidValueWithKey(key: repositoryMother!.key)
        let _ = repositoryMother!.givenReadableDataSourceReturnsValidValueWithKey(key: repositoryMother!.key)
        let repository = repositoryMother!.givenAReadableAndCacheRepository()

        let expect = expectation(description: "Cache data source should delete value")
        cacheDataSource.deleteByKeyCompletionBlock = { [weak self] (key) in
            XCTAssertEqual(self?.repositoryMother!.key, key)
            expect.fulfill()
        }

        let _ = repository.getByKey(key: repositoryMother!.key)

        waitForExpectations()
    }

    func testShouldLoadItemFromReadableDataSourceIfReadPolicyForcesOnlyReadable() {
        let _ = repositoryMother!.givenCacheDataSourceReturnsValidValueWithKey(key: repositoryMother!.key)
        let _ = repositoryMother!.givenReadableDataSourceReturnsValidValueWithKey(key: repositoryMother!.key)
        let repository = repositoryMother!.givenAReadableAndCacheRepository()

        let expect = expectation(description: "Readable data source was called")
        readableDataSource.getByKeyCompletionBlock = { [weak self] (key) in
            XCTAssertEqual(self?.repositoryMother!.key, key)
            expect.fulfill()
        }

        var cacheGetByKeyCalled = false
        cacheDataSource.getByKeyCompletionBlock = { (_) in
            cacheGetByKeyCalled = true
        }

        let _ = repository.getByKey(key: repositoryMother!.key, policy: ReadPolicy.readableOnly)

        waitForExpectations()
        XCTAssertFalse(cacheGetByKeyCalled)
    }

    func testShouldAddOrUpdateItemToWriteableDataSource() {
        let _ = repositoryMother!.givenWriteableDataSourceWritesValue(value: repositoryMother!.value)
        let repository = repositoryMother!.givenAWriteableAndCacheRepository()

        let expect = expectation(description: "Writeable data should add or update")
        writeableDataSource.addOrUpdateCompletionBlock = { [weak self] (value) in
            XCTAssertEqual(self?.repositoryMother!.value, value)
            expect.fulfill()
        }

        let _ = repository.addOrUpdate(value: repositoryMother!.value)

        waitForExpectations()
    }

    func testShouldPopulateCacheDataSourceWithWriteableDataSourceResult() {
        let _ = repositoryMother!.givenWriteableDataSourceWritesValue(value: repositoryMother!.value)
        let repository = repositoryMother!.givenAWriteableAndCacheRepository()

        let expect = expectation(description: "Cache Data Source should add or update with writeable data source result")
        cacheDataSource.addOrUpdateCompletionBlock = { [weak self] (value) in
            XCTAssertEqual(self?.repositoryMother!.value, value)
            expect.fulfill()
        }

        let _ = repository.addOrUpdate(value: repositoryMother!.value)

        waitForExpectations()
    }

    func testShouldNotPopulateCacheDataSourceIfResultIsNotSuccessful() {
        let repository = repositoryMother?.givenAWriteableAndCacheRepository()

        var addOrUpdateCalled = false
        cacheDataSource.addOrUpdateCompletionBlock = { (_) in
            addOrUpdateCalled = true
        }

        let _ = repository!.addOrUpdate(value: repositoryMother!.value)

        XCTAssertFalse(addOrUpdateCalled)
    }

    func testShouldAddItemsToWriteableDataSource() {
        let someValues = repositoryMother!.someValues
        let _ = repositoryMother!.givenWriteableDataSourceWritesValues(values: someValues)
        let repository = repositoryMother!.givenAWriteableAndCacheRepository()

        let expect = expectation(description: "Writeable Data Soruce should add or update all")
        writeableDataSource.addOrUpdateAllCompletionBlock = { (values) in
            expect.fulfill()
            XCTAssertEqual(someValues, values)
        }

        let _ = repository.addOrUpdateAll(values: someValues)

        waitForExpectations()
    }

    func testShouldPopulateCacheDataSourceWithWriteableDataSourceResults() {
        let someValues = repositoryMother!.someValues
        let _ = repositoryMother!.givenWriteableDataSourceWritesValues(values: someValues)
        let repository = repositoryMother!.givenAWriteableAndCacheRepository()

        let expect = expectation(description: "Cache Data Soruce should add or update all")
        cacheDataSource.addOrUpdateAllCompletionBlock = { (values) in
            expect.fulfill()
            XCTAssertEqual(someValues, values)
        }

        let _ = repository.addOrUpdateAll(values: someValues)

        waitForExpectations()
    }

    func testShouldNotPopulateCacheDataSourceIfWriteableDataSourceResultIsNotSuccessful() {
        let someValues = repositoryMother!.someValues
        repositoryMother!.givenWriteableDataSourceDoesNotWriteValues(values: someValues)
        let repository = repositoryMother!.givenAWriteableAndCacheRepository()

        var cacheAddOrUpdateAllCalled = false
        cacheDataSource.addOrUpdateAllCompletionBlock = { (_) in
            cacheAddOrUpdateAllCalled = true
        }

        let _ = repository.addOrUpdateAll(values: someValues)

        XCTAssertFalse(cacheAddOrUpdateAllCalled)
    }

    func testShouldDeleteAllDataSources() {
        let repository = repositoryMother!.givenAWriteableAndCacheRepository()

        let cacheExpect = expectation(description: "Cache Data Soruce should delete all")
        cacheDataSource.deleteAllCompletionBlock = {
            cacheExpect.fulfill()
        }

        let writeableExpect = expectation(description: "Writeable Soruce should delete all")
        writeableDataSource.deleteAllCompletionBlock = {
            writeableExpect.fulfill()
        }

        let _ = repository.deleteAll()

        waitForExpectations()
    }

    func testShouldDeleteAllDataSourcesByKey() {
        let repository = repositoryMother!.givenAWriteableAndCacheRepository()

        let cacheExpect = expectation(description: "Cache Data Soruce should delete by key")
        cacheDataSource.deleteByKeyCompletionBlock = { [weak self] (key) in
            XCTAssertEqual(self?.repositoryMother!.key, key)
            cacheExpect.fulfill()
        }

        let writeableExpect = expectation(description: "Writeable Soruce should delete by key")
        writeableDataSource.deleteByKeyCompletionBlock = { [weak self] (key) in
            XCTAssertEqual(self?.repositoryMother!.key, key)
            writeableExpect.fulfill()
        }

        let _ = repository.deleteByKey(key: repositoryMother!.key)

        waitForExpectations()
    }
}
