import Foundation
import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import repositories

class ReactiveRespositoryTest: repositoriesTests {

    var readableDataSource = ReadableDataSourceMock<String, TestValue>()
    var writeableDataSource = WriteableDataSourceMock<String, TestValue>()
    var cacheDataSource = CacheDataSourceMock<String, TestValue>()

    var repositoryMother: RepositoryMother?

    override func setUp() {
        repositoryMother = RepositoryMother(readableDataSource: readableDataSource, writeableDataSource: writeableDataSource, cacheDataSource: cacheDataSource)
    }

    func testShouldEmitNoSuchElementExceptionIfThereAreNoDataSourcesWithData() {
        repositoryMother!.givenCacheDataSourceReturnsNil()
        repositoryMother!.givenReadableDataSourceReturnsNil()
        let repository = repositoryMother!.givenAReadableAndCacheReactiveRepository()

        let observer = startTestObserver(onObservable: repository.getAllReactive().asObservable())

        XCTAssertEqual(observer.events[0].value.error! as! RepositoryError, RepositoryError.elementNotFound)
    }

    func testShouldEmitDataFromCacheDataSourceIfDataIsValid() {
        let cacheValues = repositoryMother!.givenCacheDataSourceReturnsValidValues()
        repositoryMother!.givenReadableDataSourceReturnsNil()
        let repository = repositoryMother!.givenAReadableAndCacheReactiveRepository()

        let observer = startTestObserver(onObservable: repository.getAllReactive().asObservable())

        XCTAssertEqual(observer.events.count, 2)
        XCTAssertEqual(observer.events[0].value.element!, cacheValues)
    }

    func testShouldEmitDataFromReadableDataSourceIfCacheDataSourceReturnsEmptyOnGetAll() {
        repositoryMother!.givenCacheDataSourceReturnsNil()
        let readableValues = repositoryMother!.givenReadableDataSourceReturnsValidValues()
        let repository = repositoryMother!.givenAReadableAndCacheReactiveRepository()

        let observer = startTestObserver(onObservable: repository.getAllReactive().asObservable())

        XCTAssertEqual(observer.events[0].value.element!, readableValues)
    }

    func testShouldEmitDataFromReadableDataSourceIfTheCacheDataSourceReturnsNoValidData() {
        let _ = repositoryMother!.givenCacheDataSourceReturnsNonValidValues()
        let readableValues = repositoryMother!.givenReadableDataSourceReturnsValidValues()
        let repository = repositoryMother!.givenAReadableAndCacheReactiveRepository()

        let observer = startTestObserver(onObservable: repository.getAllReactive().asObservable())

        XCTAssertEqual(observer.events[0].value.element!, readableValues)
    }

    func testShouldGetDataFromReadableDataSourceIfReadPolicyForcesOnlyReadable() {
        let _ = repositoryMother!.givenCacheDataSourceReturnsValidValues()
        let _ = repositoryMother!.givenReadableDataSourceReturnsValidValues()
        let repository = repositoryMother!.givenAReadableAndCacheReactiveRepository()

        let expect = expectation(description: "Readable data source was called")
        readableDataSource.getAllCompletionBlock = {
            expect.fulfill()
        }

        var cacheGetAllCalled = false
        cacheDataSource.getAllCompletionBlock = {
            cacheGetAllCalled = true
        }

        let _ = repository.getAllReactive(policy: ReadPolicy.readableOnly).subscribe()

        waitForExpectations()
        XCTAssertFalse(cacheGetAllCalled)
    }

    func testShouldPopulateCacheDataSources() {
        repositoryMother!.givenCacheDataSourceReturnsNil()
        let readableValues = repositoryMother!.givenReadableDataSourceReturnsValidValues()
        let repository = repositoryMother!.givenAReadableAndCacheReactiveRepository()

        let expect = expectation(description: "Cache data source should add or update all")
        cacheDataSource.addOrUpdateAllCompletionBlock = { (values) in
            XCTAssertEqual(readableValues, values)
            expect.fulfill()
        }
        let _ = repository.getAllReactive().subscribe()

        waitForExpectations()
    }

    func testShouldDeleteAllFromCacheDataSourceIfDataIsNotValid() {
        let _ = repositoryMother!.givenCacheDataSourceReturnsNonValidValues()
        let repository = repositoryMother!.givenAReadableAndCacheReactiveRepository()

        let expect = expectation(description: "Cache data source should delete all")
        cacheDataSource.deleteAllCompletionBlock = {
            expect.fulfill()
        }

        let _ = repository.getAllReactive().subscribe()

        waitForExpectations()
    }

    func testShouldEmitValueByKeyFromCacheDataSource() {
        repositoryMother!.givenReadableDataSourceReturnsNil()
        let cacheValue = repositoryMother!.givenCacheDataSourceReturnsValidValueWithKey(key: repositoryMother!.key)
        let repository = repositoryMother!.givenAReadableAndCacheReactiveRepository()

        let observer = startTestObserver(onObservable: repository.getByKeyReactive(key: repositoryMother!.key))

        XCTAssertEqual(observer.events[0].value.element!, cacheValue)
    }

    func testShouldEmitValueFromReadableDataSourceIfCacheDataSourceValueIsNil() {
        repositoryMother!.givenCacheDataSourceReturnsNil()
        let readableValue = repositoryMother!.givenReadableDataSourceReturnsValidValueWithKey(key: repositoryMother!.key)
        let repository = repositoryMother!.givenAReadableAndCacheReactiveRepository()

        let observer = startTestObserver(onObservable: repository.getByKeyReactive(key: repositoryMother!.key).asObservable())

        XCTAssertEqual(observer.events[0].value.element!, readableValue)
    }

    func testShouldEmitItemFromReadableDataSourceIfCacheDataSourceValueIsNotValid() {
        let _ = repositoryMother!.givenCacheDataSourceReturnsNonValidValueWithKey(key: repositoryMother!.key)
        let readableValue = repositoryMother!.givenReadableDataSourceReturnsValidValueWithKey(key: repositoryMother!.key)
        let repository = repositoryMother!.givenAReadableAndCacheReactiveRepository()

        let observer = startTestObserver(onObservable: repository.getByKeyReactive(key: repositoryMother!.key).asObservable())

        XCTAssertEqual(observer.events[0].value.element!, readableValue)
    }

    func testShouldAddOrUpdateItemReactiveToWriteableDataSource() {
        let addedValue = repositoryMother!.value
        let _ = repositoryMother!.givenWriteableDataSourceWritesValue(value: addedValue)
        let repository = repositoryMother!.givenAWriteableAndCacheReactiveRepository()

        let expect = expectation(description: "Writeable data should add or update")
        writeableDataSource.addOrUpdateCompletionBlock = { [weak self] (value) in
            XCTAssertEqual(self?.repositoryMother!.value, value)
            expect.fulfill()
        }

        let _ = repository.addOrUpdateReactive(value: addedValue).subscribe()

        waitForExpectations()
    }

    func testShouldAddItemsCallToWriteableDataSource() {
        let someValues = repositoryMother!.someValues
        repositoryMother!.givenWriteableDataSourceWritesValues(values: someValues)
        let repository = repositoryMother!.givenAWriteableAndCacheReactiveRepository()

        let expect = expectation(description: "Writeable Data Soruce should add or update all")
        writeableDataSource.addOrUpdateAllCompletionBlock = { (values) in
            expect.fulfill()
            XCTAssertEqual(someValues, values)
        }

        let _ = repository.addOrUpdateAllReactive(values: someValues).subscribe()

        waitForExpectations()
    }

    func testShouldDeleteAllCallToWriteableDataSources() {
        let _ = repositoryMother!.givenCacheDataSourceReturnsNonValidValues()
        let repository = repositoryMother!.givenAWriteableAndCacheReactiveRepository()

        let cacheExpect = expectation(description: "Cache Data Soruce should delete all")
        cacheDataSource.deleteAllCompletionBlock = {
            cacheExpect.fulfill()
        }

        let writeableExpect = expectation(description: "Writeable Soruce should delete all")
        writeableDataSource.deleteAllCompletionBlock = {
            writeableExpect.fulfill()
        }

        let _ = repository.deleteAllReactive().subscribe()

        waitForExpectations()
    }

    func testShouldDeleteAllDataSourcesByKey() {
        let key = repositoryMother!.key
        let _ = repositoryMother!.givenWriteableDataSourceWritesValue(value: repositoryMother!.value)
        let _ = repositoryMother!.givenCacheDataSourceReturnsNonValidValueWithKey(key: key)

        let repository = repositoryMother!.givenAWriteableAndCacheReactiveRepository()

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

        let _ = repository.deleteByKeyReactive(key: key)
        waitForExpectations()
    }

}
