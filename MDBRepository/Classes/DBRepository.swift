//
//  DBRepository.swift
//  DBRepository
//  Pending Items
//  a. Table Creation - Foreign Key references, Checks
//  b. DB Update - Database Migration, Alter Table, Rename Table
//  c. JOIN Operations - Done by Decodable
//  Created by Swapnil Nandgave on 25/03/18.
//  Copyright © 2018 Appcredence. All rights reserved.
//

import Foundation
//import GRDB
import GRDBCipher

open class DBRepository {
    public static let shared = DBRepository()
    
    private var dbQueue: DatabaseQueue!
    private let SQLITE_FRMT = "YYYY-MM-DD HH:mm:SS.SSS"
    private let jsonDecoder = JSONDecoder()
    private var dbmigrator = DatabaseMigrator()
    
    private let FIRST_MIGRATION = "v1"
    
    private init() {
        
    }
    
    public func configure(directory: FileManager.SearchPathDirectory = .libraryDirectory , dbName:String, password: String? = nil) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true).first! as NSString
        let databasePath = documentsPath.appendingPathComponent(dbName+".sqlite")
        do {
            if let passphrase = password {
                var configuration = Configuration()
                configuration.passphrase = passphrase
                dbQueue = try DatabaseQueue(path: databasePath, configuration: configuration)
            } else {
                dbQueue = try DatabaseQueue(path: databasePath)
            }
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = SQLITE_FRMT
            jsonDecoder.dateDecodingStrategy = .formatted(dateFormatterGet)
        }catch {
            print(error)
        }
    }
    
    public func appliedMigrations() throws -> Set<String> {
        return try dbmigrator.appliedMigrations(in: dbQueue)
    }
    
    public func addMigration(migrationName: String, migrations: [DBMigration], completion:@escaping(Bool)->Void) {
        var status = false
        do {
            dbmigrator.registerMigration(migrationName) { db in
                for migration in migrations {
                    if migration.alter {
                        try db.alter(table: migration.tableName) { t in
                            for column in migration.tableColumns {
                                let item = t.add(column: column.name, column.colType)
                                if(column.notnull) {
                                    item.notNull()
                                }
                                if(column.defaultValue != nil) {
                                    item.defaults(to: column.defaultValue!)
                                }
                                if(column.unique) {
                                    item.unique()
                                }
                                if(column.index) {
                                    item.indexed()
                                }
                            }
                        }
                    } else {
                        try db.create(table: migration.tableName, ifNotExists: true) { t in
                            for column in migration.tableColumns {
                                let item = t.column(column.name, column.colType)
                                if(column.primary) {
                                    if(column.auto) {
                                        item.primaryKey(onConflict: nil, autoincrement: true)
                                    } else {
                                        item.primaryKey()
                                    }
                                }
                                if(column.notnull) {
                                    item.notNull()
                                }
                                if(column.defaultValue != nil) {
                                    item.defaults(to: column.defaultValue!)
                                }
                                if(column.unique) {
                                    item.unique()
                                }
                                if(column.index) {
                                    item.indexed()
                                }
                            }
                        }
                    }
                }
                status = true
            }
            try dbmigrator.migrate(dbQueue)
        }catch {
            print(error)
        }
        return completion(status)
    }
    
    public func create(tableName:String,columns:[DBColumn],completion:@escaping(Bool)->Void) {
        var status = false
        do {
            try dbQueue.inDatabase { db in
                try db.create(table: tableName, ifNotExists: true) { t in
                    for column in columns {
                        let item = t.column(column.name, column.colType)
                        if(column.primary) {
                            if(column.auto) {
                                item.primaryKey(onConflict: nil, autoincrement: true)
                            } else {
                                item.primaryKey()
                            }
                        }
                        if(column.notnull) {
                            item.notNull()
                        }
                        if(column.defaultValue != nil) {
                            item.defaults(to: column.defaultValue!)
                        }
                        if(column.unique) {
                            item.unique()
                        }
                        if(column.index) {
                            item.indexed()
                        }
                    }
                    status = true
                }
            }
        }catch{
            print(error)
        }
        return completion(status)
    }
    
    public func insert<T:Record>(item: T) {
        insert(items: [item])
    }
    
    public func insert<T:Record>(items: [T]) {
        do {
            try dbQueue.inTransaction { db in
                for item in items {
                    try item.insert(db)
                }
                return .commit
            }
        }catch{
            print(error)
        }
    }
    
    public func update<T:Record>(item: T) {
        update(items: [item])
    }
    
    public func update<T:Record>(items: [T]) {
        do {
            try dbQueue.inTransaction { db in
                for item in items {
                    try item.updateChanges(db)
                }
                return .commit
            }
        }catch{
            print(error)
        }
    }
    
    public func delete<T:Record>(item: T) {
        delete(items: [item])
    }
    
    public func delete<T:Record>(items: [T]) {
        do {
            try dbQueue.inTransaction { db in
                for item in items {
                    try item.delete(db)
                }
                return .commit
            }
        }catch{
            print(error)
        }
    }
    
    public func deleteAll<T:Record>(type: T.Type) {
        do {
            try dbQueue.inTransaction { db in
                try type.deleteAll(db)
                return .commit
            }
        }catch{
            print(error)
        }
    }
    
    public func deleteAll<T:Record>(type: T.Type, filterby:SQLExpression) {
        do {
            try dbQueue.inTransaction { db in
                try type.filter(filterby).deleteAll(db)
                return .commit
            }
        }catch{
            print(error)
        }
    }
    
    public func deleteOne<T:Record>(type: T.Type, key:Any) {
        do {
            try dbQueue.inTransaction { db in
                try type.deleteOne(db, key: DatabaseValue(value: key))
                return .commit
            }
        }catch{
            print(error)
        }
    }
    
    public func deleteAll<T:Record>(type: T.Type, keys:[Any]) {
        do {
            try dbQueue.inTransaction { db in
                var sqlKeys = [DatabaseValue]()
                for key in keys {
                    sqlKeys.append(DatabaseValue(value:key)!)
                }
                try type.deleteAll(db, keys: sqlKeys)
                return .commit
            }
        }catch{
            print(error)
        }
    }
    
    public func deleteAll<T:Record>(queryInterfaceReq: QueryInterfaceRequest<T>) {
        do {
            try dbQueue.inTransaction { db in
                try queryInterfaceReq.deleteAll(db)
                return .commit
            }
        }catch{
            print(error)
        }
    }
    
    public func fetchAll<T:Record>(type:T.Type)-> [T] {
        var list = [T]()
        do {
            try dbQueue.inDatabase { db in
                list = try type.fetchAll(db)
            }
        }catch{
            print(error)
        }
        return list
    }
    
    public func fetchAll<T:Record>(type:T.Type, filterby:SQLExpression)-> [T] {
        var list = [T]()
        do {
            try dbQueue.inDatabase { db in
                list = try type.filter(filterby).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return list
    }
    
    public func fetchAll<T:Record>(type:T.Type, selectStatement: SelectStatement)-> [T] {
        var list = [T]()
        do {
            try dbQueue.inDatabase { db in
                list = try type.fetchAll(selectStatement)
            }
        }catch{
            print(error)
        }
        return list
    }
    
//    public func fetchAll<T:Record>(type:T.Type, fetchRequest: GRDB.Request)-> [T] {
//        var list = [T]()
//        do {
//            try dbQueue.inDatabase { db in
//                list = try type.fetchAll(db, fetchRequest)
//            }
//        }catch{
//            print(error)
//        }
//        return list
//    }
    
    public func fetchAll<T:Record>(type:T.Type, rawQuery: String)-> [T] {
        var list = [T]()
        do {
            try dbQueue.inDatabase { db in
                list = try type.fetchAll(db, rawQuery)
            }
        }catch{
            print(error)
        }
        return list
    }
    
    public func fetchAll<T:Record>(type:T.Type, keys: [Any])-> [T] {
        var list = [T]()
        do {
            var sqlKeys = [DatabaseValue]()
            for key in keys {
                sqlKeys.append(DatabaseValue(value:key)!)
            }
            try dbQueue.inDatabase { db in
                list = try type.fetchAll(db, keys: sqlKeys)
            }
        }catch{
            print(error)
        }
        return list
    }
    
    public func fetchAll<T:Record>(queryInterfaceReq: QueryInterfaceRequest<T>)-> [T] {
        var list = [T]()
        do {
            try dbQueue.inDatabase { db in
                list = try queryInterfaceReq.fetchAll(db)
            }
        }catch{
            print(error)
        }
        return list
    }
    
    public func fetchAll<T:Decodable>(type:T.Type, sql:String)->[T] {
        var list = [T]()
        do {
            try dbQueue.inDatabase { db in
                let rows = try Row.fetchAll(db, sql)
                var dicts = [[String:Any]]()
                for row in rows {
                    let dict = Dictionary(
                        row.map { (column, dbValue) in
                            (column, dbValue.storage.value as Any)
                        },
                        uniquingKeysWith: { (left, _) in left })
                    dicts.append(dict)
                }
                if let jsonData = try JSONSerialization.data(withJSONObject: dicts, options: .prettyPrinted) as Data? {
                    list = try jsonDecoder.decode([T].self, from: jsonData)
                }
                
            }
        }catch{
            print(error)
        }
        return list
    }
    
    public func values<T:DatabaseValueConvertible>(type:T.Type, sql:String)->[T] {
        var list = [T]()
        do {
            try dbQueue.inDatabase { db in
                list = try type.fetchAll(db, sql)
            }
        }catch{
            print(error)
        }
        return list
    }
    
    public func fetchOne<T:Record>(type:T.Type)-> T? {
        var item : T? = nil
        do {
            try dbQueue.inDatabase { db in
                item = try type.fetchOne(db)
            }
        }catch{
            print(error)
        }
        return item
    }
    
    public func fetchOne<T:Record>(type:T.Type, filterby:SQLExpression)-> T? {
        var item : T? = nil
        do {
            try dbQueue.inDatabase { db in
                item = try type.filter(filterby).fetchOne(db)
            }
        }catch{
            print(error)
        }
        return item
    }
    
    public func fetchOne<T:Record>(type:T.Type, selectStatement: SelectStatement)-> T? {
        var item : T? = nil
        do {
            try dbQueue.inDatabase { db in
                item = try type.fetchOne(selectStatement)
            }
        }catch{
            print(error)
        }
        return item
    }
    
//    public func fetchOne<T:Record>(type:T.Type, fetchRequest: GRDB.Request)-> T? {
//        var item : T? = nil
//        do {
//            try dbQueue.inDatabase { db in
//                item = try type.fetchOne(db,fetchRequest)
//            }
//        }catch{
//            print(error)
//        }
//        return item
//    }
    
    public func fetchOne<T:Record>(type:T.Type, rawQuery: String)-> T? {
        var item : T? = nil
        do {
            try dbQueue.inDatabase { db in
                item = try type.fetchOne(db,rawQuery)
            }
        }catch{
            print(error)
        }
        return item
    }
    
    public func fetchOne<T:Record>(type:T.Type, key: Any)-> T? {
        var item : T? = nil
        do {
            try dbQueue.inDatabase { db in
                item = try type.fetchOne(db, key: DatabaseValue(value:key))
            }
        }catch{
            print(error)
        }
        return item
    }
    
    public func fetchOne<T:Record>(queryInterfaceReq: QueryInterfaceRequest<T>)-> T? {
        var item : T? = nil
        do {
            try dbQueue.inDatabase { db in
                item = try queryInterfaceReq.fetchOne(db)
            }
        }catch{
            print(error)
        }
        return item
    }
    
    public func fetchOne<T:Decodable>(type:T.Type, sql:String)->T? {
        var item : T? = nil
        do {
            try dbQueue.inDatabase { db in
                let rrow = try Row.fetchOne(db, sql)
                if let row = rrow {
                    let dict = Dictionary(
                        row.map { (column, dbValue) in
                            (column, dbValue.storage.value as Any)
                        },
                        uniquingKeysWith: { (left, _) in left })
                    if let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) as Data? {
                        item = try jsonDecoder.decode(T.self, from: jsonData)
                    }
                }
            }
        }catch{
            print(error)
        }
        return item
    }
    
    public func value<T:DatabaseValueConvertible>(type:T.Type, sql:String)->T? {
        var item: T? = nil
        do {
            try dbQueue.inDatabase { db in
                item = try type.fetchOne(db, sql)
            }
        }catch{
            print(error)
        }
        return item
    }
    
    public func count<T:Record>(type:T.Type)-> Int {
        var count = 0
        do {
            try dbQueue.inDatabase { db in
                count = try type.fetchCount(db)
            }
        }catch{
            print(error)
        }
        return count
    }
    
    public func count<T:Record>(type:T.Type,filterby:SQLExpression)-> Int {
        var count = 0
        do {
            try dbQueue.inDatabase { db in
                count = try type.filter(filterby).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return count
    }
    
    public func count<T:Record>(queryInterfaceReq: QueryInterfaceRequest<T>)-> Int {
        var count = 0
        do {
            try dbQueue.inDatabase { db in
                count = try queryInterfaceReq.fetchCount(db)
            }
        }catch{
            print(error)
        }
        return count
    }
 
}
