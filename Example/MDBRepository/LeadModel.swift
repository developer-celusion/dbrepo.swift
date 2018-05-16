//
//  LeadModel.swift
//  MDBRepository_Example
//
//  Created by Celusion Technologies on 16/05/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import GRDB
import MDBRepository

class LeadModel: Record, Codable {
    
    static let TABLE_NAME = "LeadModel"
    
    enum Columns {
        static let id = Column("id")
        static let person = Column("person")
        static let transactionType = Column("transactionTypeID")
        static let entity = Column("entity")
    }
    
    var id:Int64?
    var person:String
    var transactionType:Int64?
    
    init(person: String, transactionType:Int64) {
        self.id = nil
        self.person = person
        self.transactionType = transactionType
        super.init()
    }
    
    override class var databaseTableName: String {
        return TABLE_NAME
    }
    
    required init(row: Row) {
        id = row[Columns.id]
        person = row[Columns.person]
        transactionType = row[Columns.transactionType]
        super.init(row: row)
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.person] = person
        container[Columns.transactionType] = transactionType
    }
    
    /// When relevant, update record ID after a successful insertion
    override func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
    
    public static func create() {
        var list = [DBColumn]()
        list.append(DBColumn(name: Columns.id.name).colType(Database.ColumnType.integer).primary(true,true))
        list.append(DBColumn(name: Columns.person.name).notnull(true))
        list.append(DBColumn(name: Columns.transactionType.name).colType(Database.ColumnType.integer))
        DBRepository.shared.create(tableName: TABLE_NAME, columns: list) { status in
            print(status)
        }
    }
    
}
