//
//  DBTable.swift
//  DBRepository
//
//  Created by Swapnil Nandgave on 25/03/18.
//  Copyright © 2018 Appcredence. All rights reserved.
//

import Foundation
//import GRDB
import GRDBCipher

open class DBColumn {
    
    var name:String = ""
    var colType: Database.ColumnType = Database.ColumnType.text
    var primary: Bool = false
    var auto: Bool = false
    var notnull: Bool = false
    var defaultValue: DatabaseValue? = nil
    var unique: Bool = false
    var index: Bool = false
    
    public init(name:String) {
        self.name = name
    }
    
    public func colType(_ colType:Database.ColumnType)-> DBColumn {
        self.colType = colType
        return self
    }
    
    public func primary(_ primary:Bool)-> DBColumn {
        self.primary = primary
        return self
    }
    
    public func primary(_ primary:Bool,_ autoIncrement:Bool)-> DBColumn {
        self.primary = primary
        self.auto = autoIncrement
        return self
    }
    
    public func notnull(_ notnull:Bool)-> DBColumn {
        self.notnull = notnull
        return self
    }
    
    public func defaultTo(_ value:Any)-> DBColumn {
        defaultValue = DatabaseValue(value: value)
        return self
    }
 
    public func unique(_ unique:Bool)-> DBColumn {
        self.unique = unique
        return self
    }
    
    public func index(_ index:Bool)-> DBColumn {
        self.index = index
        return self
    }
    
}
