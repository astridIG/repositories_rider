import Foundation
@testable import repositories

enum DataSource {
    case readable
    case writeable
    case cache
}

class RepositoryMother<Key, Value: CodableProtocol> where Value.Key == Key {

    private var readableDataSources: [ReadableDataSourceMock<Key, Value>]
    private var writeableDataSources: [WriteableDataSourceMock<Key, Value>]
    private var cacheDataSources: [CacheDataSourceMock<Key, Value>]

    init(readableDataSources: [ReadableDataSourceMock<Key, Value>],
         writeableDataSources: [WriteableDataSourceMock<Key, Value>],
         cacheDataSource: [CacheDataSourceMock<Key, Value>]) {
        self.readableDataSources = readableDataSources
        self.writeableDataSources = writeableDataSources
        self.cacheDataSources = cacheDataSource
    }

    func givenAReadableAndCacheRepository() -> BaseRepository<Key, Value> {
        return givenARepository(dataSources: [DataSource.readable, DataSource.cache])
    }

    func givenAWriteableAndCacheRepository() -> BaseRepository<Key, Value> {
        return givenARepository(dataSources: [DataSource.writeable, DataSource.cache])
    }

    func givenARepository(dataSources: [DataSource]) -> BaseRepository<Key, Value> {
        let repository = BaseRepository<Key, Value>()

        if (dataSources.contains(DataSource.readable)) {
            repository.addReadableDataSources(readableDataSources: readableDataSources)
        }

        if (dataSources.contains(DataSource.writeable)) {
            repository.addWritableDataSources(writableDataSources: writeableDataSources)
        }

        if (dataSources.contains(DataSource.cache)) {
            repository.addCacheDataSources(cacheDataSources: cacheDataSources)
        }

        return repository
    }
}
