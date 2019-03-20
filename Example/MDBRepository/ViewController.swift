//
//  ViewController.swift
//  MDBRepository
//
//  Created by swapnil.nandgave@celusion.com on 04/02/2018.
//  Copyright (c) 2018 swapnil.nandgave@celusion.com. All rights reserved.
//

import UIKit
import GRDBCipher
import MDBRepository

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "DB Repository"
    }
    
    @IBAction func insertAction(_ sender:Any) {
        insert()
    }
    
    @IBAction func selectAction(_ sender:Any) {
        select()
    }
    
    @IBAction func insertAction2(_ sender:Any) {
        insertLead()
    }
    
    @IBAction func joinAction(_ sender:Any) {
        joinLead()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func select() {
        var list = DBRepository.shared.fetchAll(type: TransactionType.self)
        print(list.count)
        list = DBRepository.shared.fetchAll(type: TransactionType.self, keys: [3])
        print(list.count)
        
        var expression = Column("name") == "Robert"
        expression = expression || Column("name") == "Again Swapnil"
        list = DBRepository.shared.fetchAll(type: TransactionType.self, filterby: expression)
        print(list.count)
        
        let interface = TransactionType.filter(Column("name") != nil).order(Column("id").desc)
        list = DBRepository.shared.fetchAll(queryInterfaceReq: interface)
        print(list.count)
    }
    
    private func insert() {
        let transactionType = TransactionType(name:"Robert")
        DBRepository.shared.insert(item: transactionType)
        print(transactionType.id!)
        
        let transactionType2 = TransactionType(name:"Dicosta")
        DBRepository.shared.insert(item: transactionType2)
        print(transactionType2.id!)
        
        transactionType2.name = "Dicosta-Updated";
        DBRepository.shared.update(item: transactionType2)
        
        transactionType2.name = "Dicosta";
        DBRepository.shared.update(item: transactionType2)
        
    }
    
    private func insertLead() {
        let lead = LeadModel(person:"Swapnil Nandgave",transactionType:1)
        DBRepository.shared.insert(item: lead)
        print(lead.id!)
        
        let lead2 = LeadModel(person:"Swapnil Nandgave Trans 2",transactionType:2)
        DBRepository.shared.insert(item: lead2)
        print(lead2.id!)
        
    }
    
    private func joinLead() {
        let sql = "SELECT lead.id,lead.person AS name,(SELECT name FROM TransactionType WHERE id=lead.transactionTypeID LIMIT 1)transactionName," +
            "(SELECT createdOn FROM TransactionType WHERE id=lead.transactionTypeID LIMIT 1)transDate " +
        "FROM LeadModel AS lead";
        let list = DBRepository.shared.fetchAll(type: LeadTrans.self, sql: sql);
        for item in list {
            print(item.transactionName ?? "No Trans",item.id ?? -1,item.name ?? "No Name")
        }
        let count = DBRepository.shared.value(type: Int.self, sql: "SELECT COUNT(*) FROM LeadModel")
        print(count ?? -1)
        
        let array = DBRepository.shared.values(type: String.self,sql:"SELECT person FROM LeadModel");
        print(array.count)
    }

}

