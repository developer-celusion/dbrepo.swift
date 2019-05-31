//
//  DBMigration.swift
//  GRDBCipher
//
//  Created by Swapnil Nandgave on 31/05/19.
//

import Foundation

open class DBMigration {
    
    public var tableName:String = ""
    
    public var tableColumns = [DBColumn]()
    
    public var alter: Bool = false
    
    public init(tableName: String) {
        self.tableName = tableName
    }
    
    public init(tableName: String, tableColumns: [DBColumn]) {
        self.tableName = tableName
        self.tableColumns = tableColumns
    }
    
}
