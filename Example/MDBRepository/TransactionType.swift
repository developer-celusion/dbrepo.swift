//
//  TransactionType.swift
//  MDBRepository_Example
//
//  Created by Celusion Technologies on 16/05/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import MDBRepository
import GRDB

class TransactionType: Record,Codable {
    
    static let TABLE_NAME = "TransactionType"
    
    enum Columns {
        static let id = Column("id")
        static let name = Column("name")
        static let createdOn = Column("createdOn")
    }
    
    var id:Int64?
    var name:String
    var date:Date?
    
    init(name: String) {
        self.id = nil
        self.name = name
        self.date = Date()
        super.init()
    }
    
    override class var databaseTableName: String {
        return TABLE_NAME
    }
    
    required init(row: Row) {
        id = row[Columns.id]
        name = row[Columns.name]
        date = row[Columns.createdOn]
        super.init(row: row)
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.createdOn] = date
    }
    
    /// When relevant, update record ID after a successful insertion
    override func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
    
    public static func create() {
        var list = [DBColumn]()
        list.append(DBColumn(name: Columns.id.name).colType(Database.ColumnType.integer).primary(true,true))
        list.append(DBColumn(name: Columns.name.name).notnull(true))
        list.append(DBColumn(name: Columns.createdOn.name).colType(Database.ColumnType.datetime).notnull(true))
        DBRepository.shared.create(tableName: TABLE_NAME, columns: list) { status in
            print(status)
        }
    }
    
}
