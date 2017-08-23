//import Foundation
//
//enum DataSource {
//    case readable
//    case writeable
//    case cache
//}
//
////class ReadableDataSourceMock<Key, Value>: ReadableDataSource<Key, Value> {
////
////}
//
//class RepositoryMother {
//
//    private var readableDataSource: [ReadableDataSource<Key, Value>]
//    private var writableDataSource: [WriteableDataSource<Key, Value>]
//    private var cacheDataSource: [CacheDataSource<Key, Value>]
//
//    init(readableDataSource: [ReadableDataSource<Key, Value>],
//         writableDataSource: [WriteableDataSource<Key, Value>],
//         cacheDataSource: [CacheDataSource<Key, Value>]) {
//        self.readableDataSource = readableDataSource
//        self.writableDataSource = writableDataSource
//        self.cacheDataSource = cacheDataSource
//    }
//
//    func givenAReadableAndCacheRepository(): BaseRepository<Key, Value> {
//        return givenARepository(dataSources: [DataSource.readable, .DataSourcecache])
//    }
//
//    func givenAWriteableAndCacheRepository(): BaseRepository<Key, Value> {
//        return givenARepository(dataSources: [DataSource.writeable, DataSource.cache])
//    }
//
//    func givenARepository(dataSources: [DataSource]) -> BaseRepository<Key, Value> {
//        var repository = BaseRepository<Key, Value>()
//
//        if (dataSources.contains(DataSource.readable)) {
//            repository.addReadableDataSources(readableDataSource)
//        }
//
//        if (dataSources.contains(DataSource.writeable)) {
//            repository.addWritableDataSources(writeableDataSource)
//        }
//
//        if (dataSources.contains(DataSource.cache)) {
//            repository.addCacheDataSources(cacheDataSource)
//        }
//
//        return repository
//    }
//
//    func givenAReadableAndCacheReactiveRepository() -> ReactiveBaseRepository<Key, Value> {
//        return givenAReactiveRepository(EnumSet.of(DataSource.READABLE, DataSource.CACHE))
//    }
//
//    func givenAWriteableAndCacheReactiveRepository(): ReactiveBaseRepository<Key, Value> {
//        return givenAReactiveRepository(EnumSet.of(DataSource.WRITEABLE, DataSource.CACHE))
//    }
//
//    func givenAReactiveRepository(dataSources: [DataSource]) -> ReactiveBaseRepository<Key, Value> {
//        var repository = ReactiveBaseRepository<Key, Value>()
//
//        if (dataSources.contains(DataSource.readable)) {
//            repository.addReadableDataSources(readableDataSource)
//        }
//
//        if (dataSources.contains(DataSource.writeable)) {
//            repository.addWritableDataSources(writeableDataSource)
//        }
//
//        if (dataSources.contains(DataSource.cache)) {
//            repository.addCacheDataSources(cacheDataSource)
//        }
//
//        return repository
//    }
//
//    func givenCacheDataSourceReturnsNull() {
//
//        `when`(cacheDataSource.getByKey(any())).thenReturn(null)
//        `when`(cacheDataSource.getAll()).thenReturn(null)
//    }
//
////    func givenReadableDataSourceReturnsNull() {
////        `when`(readableDataSource.getAll()).thenReturn(null)
////    }
////
////    func givenCacheDataSourceReturnsValidValueWithKey(key: AnyRepositoryKey): AnyRepositoryValue {
////        return givenCacheDataSourceReturnsValueWithKey(key, true)
////    }
////
////    func givenCacheDataSourceReturnsNonValidValueWithKey(key: AnyRepositoryKey): AnyRepositoryValue {
////        return givenCacheDataSourceReturnsValueWithKey(key, false)
////    }
////
////    private func givenCacheDataSourceReturnsValueWithKey(key: AnyRepositoryKey,
////                                                         isValidValue: Boolean): AnyRepositoryValue {
////        val value = AnyRepositoryValue(key)
////        `when`(cacheDataSource.getByKey(key)).thenReturn(value)
////        `when`(cacheDataSource.isValid(value)).thenReturn(isValidValue)
////        return value
////    }
////
////    func givenReadableDataSourceReturnsValidValueWithKey(key: AnyRepositoryKey): AnyRepositoryValue {
////        val value = AnyRepositoryValue(key)
////        `when`(readableDataSource.getByKey(key)).thenReturn(value)
////        return value
////    }
////
////    func givenCacheDataSourceReturnsValidValues(): Collection<AnyRepositoryValue> {
////        return givenCacheDataSourceReturnsValues(true)
////    }
////
////    func givenCacheDataSourceReturnsNonValidValues(): Collection<AnyRepositoryValue> {
////        return givenCacheDataSourceReturnsValues(false)
////    }
////
////    private func givenCacheDataSourceReturnsValues(areValidValues: Boolean): Collection<AnyRepositoryValue> {
////        val values = someValues
////        `when`(cacheDataSource.getAll()).thenReturn(values)
////        `when`(cacheDataSource.isValid(any())).thenReturn(areValidValues)
////        return values
////    }
////
////    func givenReadableDataSourceReturnsValidValues(): Collection<AnyRepositoryValue> {
////        val values = someValues
////        `when`(readableDataSource.getAll()).thenReturn(values)
////        return values
////    }
////
////    func givenReadableDataSourceThrowsException(exception: Exception) {
////        `when`(readableDataSource.getAll()).thenThrow(exception)
////    }
////
////    func givenWriteableDataSourceWritesValue(value: AnyRepositoryValue): AnyRepositoryValue {
////        val writeableValue = AnyRepositoryValue(value.key)
////        `when`(writeableDataSource.addOrUpdate(value)).thenReturn(writeableValue)
////        return writeableValue
////    }
////
////    func givenWriteableDataSourceDoesNotWriteValues(values: Collection<AnyRepositoryValue>) {
////        `when`(writeableDataSource.addOrUpdateAll(values)).thenReturn(null)
////    }
////
////    func givenWriteableDataSourceWritesValues(
////        values: Collection<AnyRepositoryValue>): Collection<AnyRepositoryValue> {
////        val updatedValues = LinkedList(values)
////        `when`(writeableDataSource.addOrUpdateAll(values)).thenReturn(values)
////        return updatedValues
////    }
//}

