//import Foundation
//import FMDB
//
//struct HighlanderRepositoryError {
//    static let Domain = "HighlanderRepositoryError"
//}
//
//public let HighlanderRepositoryErrorDescriptionKey = "HighlanderRepositoryErrorDescriptionKey"
//
//private enum SQLiteDataSourceErrorCode: Int {
//    case GenericError = -900
//    case UnableToCreateTable = -901
//    case TableDoesNotExists = -902
//    case QueryError = -903
//    case InvalidItem = -904
//    case NoItemsInRepository = -905
//}
//
//private struct Keys {
//    static let LastOffsetWithMoreItems = "lo"
//    static let Items = "it"
//}
//
//struct SQLiteRuntimeConfiguration {
//    let logsErrors: Bool
//    let traceExecution: Bool
//    let crashOnErrors: Bool
//
//    static var defaultConfiguration: SQLiteRuntimeConfiguration {
//        return SQLiteRuntimeConfiguration(logsErrors: false, traceExecution: false, crashOnErrors: false)
//    }
//}
//
//public class SQLiteDataSource<K:Hashable, T:Cacheable> : BaseDataSource<K,T> where T.K == K {
//
//    private let dbPath: String
//    let version: Int
//    let policies: [CachePolicy<T>]
//    private let sqliteRuntimeConfiguration: SQLiteRuntimeConfiguration
//
//    private let queue: FMDatabaseQueue
//    private var tableCreated = false
//    private let tableName = "items"
//
//    var lastOffsetWithMoreItems: Int
//
//    init(version: Int, dbPath: String, policies: [CachePolicy<T>] = [], isCache: Bool = true, sqliteRuntimeConfiguration: SQLiteRuntimeConfiguration) {
//        self.dbPath = dbPath
//        self.version = version
//        self.policies = policies
//        self.sqliteRuntimeConfiguration = sqliteRuntimeConfiguration
//
//        self.queue = FMDatabaseQueue(path: dbPath)
//        self.lastOffsetWithMoreItems = NoMoreItemsOffset
//
//        super.init(isCache: isCache)
//    }
//
//    public convenience init(version: Int, dbName: String) {
//        self.init(
//            version: version,
//            dbPath: generateDBPath(dbName),
//            policies: [
//                VersionCachePolicy(version: version),
//                ],
//            sqliteRuntimeConfiguration: SQLiteRuntimeConfiguration.defaultConfiguration
//        )
//    }
//
//    public convenience init(version: Int, ttl: TimeInterval, dbName: String) {
//        self.init(
//            version: version,
//            dbPath: generateDBPath(dbName),
//            policies: [
//                VersionCachePolicy(version: version),
//                TTLCachePolicy(ttl: ttl),
//                ],
//            sqliteRuntimeConfiguration: SQLiteRuntimeConfiguration.defaultConfiguration
//        )
//    }
//
//    convenience init(version: Int, policies: [CachePolicy<T>]) {
//        self.init(
//            version: version,
//            dbPath: generateDBPath(),
//            policies: policies,
//            sqliteRuntimeConfiguration: SQLiteRuntimeConfiguration.defaultConfiguration
//        )
//    }
//
//    convenience init(version: Int, ttl: NSTimeInterval) {
//        self.init(
//            version: version,
//            dbPath: generateDBPath(),
//            policies: [
//                VersionCachePolicy(version: version),
//                TTLCachePolicy(ttl: ttl)
//            ],
//            sqliteRuntimeConfiguration: SQLiteRuntimeConfiguration.defaultConfiguration
//        )
//    }
//
//    convenience init(version: Int, ttl: TimeInterval, sqliteRuntimeConfiguration: SQLiteRuntimeConfiguration) {
//        self.init(
//            version: version,
//            dbPath: generateDBPath(),
//            policies: [
//                VersionCachePolicy(version: version),
//                TTLCachePolicy(ttl: ttl)
//            ],
//            sqliteRuntimeConfiguration: sqliteRuntimeConfiguration
//        )
//    }
//
//    convenience init(version: Int) {
//        self.init(
//            version: version,
//            dbPath: generateDBPath(),
//            policies: [
//                VersionCachePolicy(version: version),
//                ],
//            sqliteRuntimeConfiguration: SQLiteRuntimeConfiguration.defaultConfiguration
//        )
//    }
//
//    // MARK: ReadableDataSource
//    public override func get(key: K) -> T? {
//        guard tableExists() else {
//            return nil
//        }
//
//        let sql = "SELECT * from \(tableName) WHERE id = ? ;"
//        var resultItem: T? = nil
//
//        queue.inTransaction { db, rollback in
//            do {
//                try self.executeSQLBlock(dataBase: db, fromInsideTransaction: true) { db in
//                    let result = try db.executeQuery(sql, values: [key.hashValue])
//                    if result.next() {
//                        if  let cachedItem = self.cachedItemFromDBResult(result: result),
//                            let item = cachedItem.item, self.itemIsValid(cachedItem, forCachePolicies: self.policies) {
//
//                            resultItem = item
//                        }
//                    }
//                }
//
//            } catch {
//
//            }
//        }
//
//        return resultItem
//    }
//
//    public override func get(key: K) -> Promise<T> {
//        return Promise {
//            (fulfill, reject) in
//
//            let item: T? = self.get(key)
//            if let item = item {
//                fulfill(item)
//            } else {
//                reject(self.noItemsInRepositoryError)
//            }
//        }
//    }
//
//    public override func getAll() -> [T]? {
//        guard tableExists() else {
//            return nil
//        }
//
//        let sql = "SELECT * from \(tableName)"
//        var returnValue: [T]? = nil
//
//        queue.inTransaction { db, rollback in
//            do {
//                try self.executeSQLBlock(db, fromInsideTransaction: true) { db in
//                    var cachedItems: [CacheItem<T>] = []
//                    let result = try db.executeQuery(sql, values: [])
//
//                    while result.next() {
//                        if let cachedItem = self.cachedItemFromDBResult(result) {
//                            cachedItems.append(cachedItem)
//                        }
//                    }
//
//                    let filteredItems: [CacheItem<T>] = cachedItems.filter {
//                        [unowned self] (item) -> Bool in
//                        return self.itemIsValid(item, forCachePolicies: self.policies)
//                    }
//
//                    // If there is any invalid item in the list, treat as a miss
//                    if filteredItems.count != cachedItems.count {
//                        self.doInvalidateAll(db, rollback: rollback)
//
//                    } else {
//                        // populateNext works with CacheItem internally
//                        self.populateNext(filteredItems)
//
//                        // Return the unwrapped items
//                        returnValue = self.unwrapCachedItems(filteredItems)
//                    }
//
//                }
//            } catch {
//
//            }
//        }
//
//        return returnValue
//    }
//
//    public override func getAll() -> Promise<[T]> {
//        return Promise {
//            (fulfill, reject) in
//
//            let items: [T]? = self.getAll()
//            if let items = items {
//                fulfill(items)
//            } else {
//                reject(self.noItemsInRepositoryError)
//            }
//        }
//    }
//
//
//    override public func populate(items: [T])  {
//        append(items)
//    }
//
//    override public func populate(collectionContainer: CollectionContainer<T>) {
//        if collectionContainer.pagination.hasMore {
//            lastOffsetWithMoreItems = collectionContainer.pagination.offset + collectionContainer.pagination.limit
//        }
//        append(collectionContainer.items)
//    }
//
//    // MARK: WritableDataSource
//    public override func set(item: T) {
//        append([item])
//    }
//
//    public override func replace(items: [T]) {
//        invalidateAll()
//        append(items)
//    }
//
//    public override func append(items: [T]) {
//        executeAsCriticalSection {
//
//            guard self.ensureTableIsCreated() else {
//                return
//            }
//
//            var cachedItems: [CacheItem<T>] = []
//
//            for item in items {
//
//                let cachedItem = self.buildCacheItem(item, withVersion: self.version)
//                cachedItems.append(cachedItem)
//                let json = cachedItem.toJson()!
//                queue.inTransaction { db, rollback in
//                    do {
//                        try self.executeSQLBlock(db, fromInsideTransaction: true) { db in
//                            let sql = "INSERT OR REPLACE INTO \(self.tableName) (id, item, version, updated) VALUES (?, ?, ?, ?)"
//
//                            let values: [AnyObject] = [
//                                NSNumber(integer: item.getKey().hashValue),
//                                json[CacheItemKeys.Item] as! NSString,
//                                NSNumber(integer: json[CacheItemKeys.Version] as! Int),
//                                json[CacheItemKeys.Updated] as! NSString,
//                                ]
//
//                            try db.executeUpdate(
//                                sql,
//                                values: values
//                            )
//                        }
//                    } catch {
//                        rollback.memory = true
//                    }
//                }
//            }
//
//            // Other dataSources might not be thread safe so we execute it in a critical section
//            self.populateNext(cachedItems)
//        }
//    }
//
//    override public func invalidate(key: K) {
//        queue.inTransaction { db, rollback in
//            do {
//                try self.executeSQLBlock(db, fromInsideTransaction: true) { db in
//                    let sql = "DELETE FROM \(self.tableName) WHERE id = ?"
//                    try db.executeUpdate(
//                        sql,
//                        values: [
//                            key.hashValue
//                        ]
//                    )
//                }
//            } catch {
//                rollback.memory = true
//            }
//        }
//
//        nextDataSource?.invalidate(key)
//    }
//
//    override public func invalidateAll() {
//        queue.inTransaction { db, rollback in
//            self.doInvalidateAll(db, rollback: rollback)
//        }
//    }
//
//    private func doInvalidateAll(db: FMDatabase!, rollback: UnsafeMutablePointer<ObjCBool>) {
//        do {
//            try self.executeSQLBlock(db, fromInsideTransaction: true) { db in
//                let sql = "DROP TABLE \(self.tableName)"
//                try db.executeUpdate(
//                    sql,
//                    values: []
//                )
//            }
//        } catch {
//            rollback.memory = true
//        }
//
//        self.nextDataSource?.invalidateAll()
//    }
//
//    private func ensureTableIsCreated() -> Bool {
//        guard !tableCreated else {
//            return true
//        }
//
//        queue.inTransaction { db, rollback in
//            do {
//                try self.executeSQLBlock(db, fromInsideTransaction: true) { db in
//                    let sql = "CREATE TABLE IF NOT EXISTS \(self.tableName) (id BIGINT PRIMARY KEY, item TEXT, version TINYINT, updated TEXT);"
//                    try db.executeUpdate(sql, values: [])
//                    self.tableCreated = true
//                }
//            } catch {
//                rollback.memory = true
//                self.tableCreated = false
//            }
//        }
//
//        return tableCreated
//    }
//
//    private func tableExists() -> Bool {
//        guard !tableCreated else {
//            // The table might have been created in this execution or a previous one
//            return true
//        }
//
//        queue.inTransaction { db, rollback in
//            do {
//                try self.executeSQLBlock(db, fromInsideTransaction: true) { db in
//                    let sql = "SELECT * FROM sqlite_master WHERE name = ? and type='table';"
//                    let result = try db.executeQuery(sql, values: [self.tableName])
//                    self.tableCreated = result.next()
//                }
//            } catch {
//                rollback.memory = true
//                self.tableCreated = false
//            }
//        }
//
//        return tableCreated
//
//    }
//
//    private func getCount() -> Int {
//        var count = 0
//
//        guard tableExists() else {
//            return count
//        }
//
//        queue.inTransaction { db, rollback in
//            do {
//                try self.executeSQLBlock(db, fromInsideTransaction: true) { db in
//                    let sql = "select COUNT(*) from \(self.tableName);"
//                    let result = try db.executeQuery(sql, values: [])
//                    if result.next() {
//                        count = Int(result.intForColumnIndex(0))
//                    }
//                }
//            } catch {
//                rollback.memory = true
//            }
//        }
//
//        return count
//    }
//
//    private func executeAsCriticalSection(@noescape block: () -> ()) {
//        objc_sync_enter(self)
//        block()
//        objc_sync_exit(self)
//    }
//
//    private func buildCacheItem(item: T, withVersion version: Int) -> CacheItem<T> {
//        return CacheItem(
//            item: item,
//            version: version,
//            updated: NSDate()
//        )
//    }
//
//    private func populateNext(cachedItems: [CacheItem<T>]?) {
//        if let items = cachedItems {
//            nextDataSource?.populate(
//                items.flatMap { cacheItem -> T? in
//                    return cacheItem.item
//                }
//            )
//        }
//    }
//
//    private func populateNext(collection: CollectionContainer<T>?) {
//        if let collection = collection {
//            nextDataSource?.populate(collection)
//        }
//    }
//
//    private func itemIsValid(item: CacheItem<T>, forCachePolicies policies:[CachePolicy<T>]) -> Bool {
//        return policies.reduce(true) {
//            (valid, policy) -> Bool in
//            return valid && policy.isValid(item)
//        }
//    }
//
//    private func unwrapCachedItems(items: [CacheItem<T>]) -> [T] {
//        return items.flatMap { (cachedItem: CacheItem<T>) -> T? in
//            cachedItem.item
//        }
//    }
//
//    private func executeSQLBlock(dataBase: FMDatabase, fromInsideTransaction: Bool = false, @noescape block: (FMDatabase) throws -> ()) rethrows {
//        dataBase.logsErrors = sqliteRuntimeConfiguration.logsErrors
//        dataBase.traceExecution = sqliteRuntimeConfiguration.traceExecution
//        dataBase.crashOnErrors = sqliteRuntimeConfiguration.crashOnErrors
//
//        dataBase.open()
//        try block(dataBase)
//        if !fromInsideTransaction {
//            dataBase.close()
//        }
//    }
//
//    private func cachedItemFromDBResult(result: FMResultSet) -> CacheItem<T>? {
//        let itemString = result.stringForColumn("item")
//        let version = result.intForColumn("version")
//        let updated = result.stringForColumn("updated")
//
//        let dictionary: [String:AnyObject] = [
//            CacheItemKeys.Item: itemString,
//            CacheItemKeys.Version: Int(version),
//            CacheItemKeys.Updated: updated
//        ]
//
//        return CacheItem<T>(json: dictionary, version: Int(self.version))
//    }
//
//    private func getError(code: SQLiteDataSourceErrorCode, description: String) -> NSError {
//        return NSError(
//            domain: HighlanderRepositoryError.Domain,
//            code: code.rawValue,
//            userInfo: [
//                HighlanderRepositoryErrorDescriptionKey: description
//            ]
//        )
//    }
//
//    private func getError(error: NSError) -> NSError {
//        return getError(
//            .QueryError,
//            description: error.localizedDescription
//        )
//    }
//
//    private var dbCreationError: NSError {
//        return getError(
//            .UnableToCreateTable,
//            description: "Unable to create \(tableName) data"
//        )
//    }
//
//    private var genericError: NSError {
//        return getError(
//            .GenericError,
//            description: "Something went really wrong"
//        )
//    }
//
//    private var noItemsInRepositoryError: NSError {
//        return getError(
//            .NoItemsInRepository,
//            description: "The request item(s) could not be found in the repository"
//        )
//    }
//
//    private var invalidItemsInRepositoryError: NSError {
//        return getError(
//            .InvalidItem,
//            description: "The fetched items did not pass the caching policies check"
//        )
//    }
//}
//
//// Can't make it part of the object as it is used in the init method
//private func generateDBPath(fileName: String = NSUUID().UUIDString) -> String {
//    let cachesPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
//    return "\(cachesPath)/\(fileName).sqlite"
//}
//
