import Foundation
@testable import repositories

enum DataSource {
    case readable
    case writeable
    case cache
}

class RepositoryMother {

    private var readableDataSource: ReadableDataSourceMock<String, TestValue>
    private var writeableDataSource: WriteableDataSourceMock<String, TestValue>
    private var cacheDataSource: CacheDataSourceMock<String, TestValue>

    init(readableDataSource: ReadableDataSourceMock<String, TestValue>,
         writeableDataSource: WriteableDataSourceMock<String, TestValue>,
         cacheDataSource: CacheDataSourceMock<String, TestValue>) {
        self.readableDataSource = readableDataSource
        self.writeableDataSource = writeableDataSource
        self.cacheDataSource = cacheDataSource
    }

    func givenAReadableAndCacheRepository() -> BaseRepository<String, TestValue> {
        return givenARepository(dataSources: [DataSource.readable, DataSource.cache])
    }

    func givenAWriteableAndCacheRepository() -> BaseRepository<String, TestValue> {
        return givenARepository(dataSources: [DataSource.writeable, DataSource.cache])
    }

    func givenARepository(dataSources: [DataSource]) -> BaseRepository<String, TestValue> {
        let repository = BaseRepository<String, TestValue>()

        if (dataSources.contains(DataSource.readable)) {
            repository.addReadableDataSources(readableDataSources: [readableDataSource])
        }

        if (dataSources.contains(DataSource.writeable)) {
            repository.addWritableDataSources(writableDataSources: [writeableDataSource])
        }

        if (dataSources.contains(DataSource.cache)) {
            repository.addCacheDataSources(cacheDataSources: [cacheDataSource])
        }

        return repository
    }

    func givenAReadableAndCacheReactiveRepository() -> ReactiveBaseRepository<String, TestValue> {
        return givenAReactiveRepository(dataSources: [DataSource.readable, DataSource.cache])
    }

    func givenAWriteableAndCacheReactiveRepository() -> ReactiveBaseRepository<String, TestValue> {
        return givenAReactiveRepository(dataSources: [DataSource.writeable, DataSource.cache])
    }

    func givenAReactiveRepository(dataSources: [DataSource]) -> ReactiveBaseRepository<String, TestValue> {
        let repository = ReactiveBaseRepository<String, TestValue>()

        if (dataSources.contains(DataSource.readable)) {
            repository.addReadableDataSources(readableDataSources: [readableDataSource])
        }

        if (dataSources.contains(DataSource.writeable)) {
            repository.addWritableDataSources(writableDataSources: [writeableDataSource])
        }

        if (dataSources.contains(DataSource.cache)) {
            repository.addCacheDataSources(cacheDataSources: [cacheDataSource])
        }

        return repository
    }

    func givenCacheDataSourceReturnsNil() {
        cacheDataSource.returnValue = nil
        cacheDataSource.returnCollectionValue = nil
    }

    func givenReadableDataSourceReturnsNil() {
        readableDataSource.returnValue = nil
        readableDataSource.returnCollectionValue = nil
    }

    func givenCacheDataSourceReturnsValidValueWithKey(key: String) -> TestValue {
        return givenCacheDataSourceReturnsValueWithKey(key: key, isValidValue: true)
    }

    func givenCacheDataSourceReturnsNonValidValueWithKey(key: String) -> TestValue {
        return givenCacheDataSourceReturnsValueWithKey(key: key, isValidValue: false)
    }

    private func givenCacheDataSourceReturnsValueWithKey(key: String, isValidValue: Bool) -> TestValue {
        let value = TestValue(id: key)
        cacheDataSource.returnValue = value
        cacheDataSource.isValid = isValidValue
        return value
    }

    func givenReadableDataSourceReturnsValidValueWithKey(key: String) -> TestValue {
        let value = TestValue(id: key)
        readableDataSource.returnValue = value
        return value
    }

    func givenCacheDataSourceReturnsValidValues() -> [TestValue] {
        return givenCacheDataSourceReturnsValues(areValidValues: true)
    }

    func givenCacheDataSourceReturnsNonValidValues() -> [TestValue] {
        return givenCacheDataSourceReturnsValues(areValidValues: false)
    }

    private func givenCacheDataSourceReturnsValues(areValidValues: Bool) -> [TestValue] {
        let values = someValues
        cacheDataSource.returnCollectionValue = values
        cacheDataSource.isValid = areValidValues
        return values
    }

    func givenReadableDataSourceReturnsValidValues() -> [TestValue] {
        let values = someValues
        readableDataSource.returnCollectionValue = someValues
        return values
    }

    func givenWriteableDataSourceWritesValue(value: TestValue) -> TestValue {
        let writeableValue = TestValue(id: value.id)
        writeableDataSource.returnValue = writeableValue
        return writeableValue
    }

    func givenWriteableDataSourceDoesNotWriteValues(values: [TestValue]) {
        writeableDataSource.returnValue = nil
        writeableDataSource.returnCollectionValue = nil
    }

    func givenWriteableDataSourceWritesValues(values: [TestValue]) -> [TestValue] {
        let updatedValues = values
        writeableDataSource.returnCollectionValue = values
        return updatedValues
        }

    var someValues: [TestValue] {
        get {
            var values = [TestValue]()
            for letter in ["a", "b", "c"] {
                values.append(TestValue(id: letter))
            }
            return values
        }
    }

    var key: String {
        get {
            return "key"
        }
    }

    var value: TestValue {
        get {
            return TestValue(id: key)
        }
    }
}
