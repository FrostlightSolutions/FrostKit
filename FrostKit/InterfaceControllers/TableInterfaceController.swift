//
//  TableInterfaceController.swift
//  FrostKit
//
//  Created by James Barrow on 18/06/2016.
//  Copyright © 2016 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import WatchKit

open class TableInterfaceController: WKInterfaceController {
    
    open var rowType: String! { return nil }
    private lazy var dataArray = [Any]()
    open var limit: Int { return 10 }
    private var skip = 0
    open var resetLimitAndSkipOnReload: Bool { return false }
    private var updateFromStart = false
    open var noDataString: String { return FKLocalizedString("NO_DATA", comment: "No Data") }
    @IBOutlet public weak var table: WKInterfaceTable!
    @IBOutlet public weak var titleGroup: WKInterfaceGroup?
    @IBOutlet public weak var titleLabel: WKInterfaceLabel?
    @IBOutlet public weak var statusLabel: WKInterfaceLabel?
    @IBOutlet public weak var moreButton: WKInterfaceButton?
    open var showReloadMenuItem: Bool { return true }
    private var updatingTable = false
    
    public override init() {
        super.init()
        
        moreButton?.setTitle(FKLocalizedString("MORE_", comment: "More..."))
        statusLabel?.setText(FKLocalizedString("LOADING_", comment: "Loading..."))
        
        DispatchQueue.main.async {
            self.updateTable()
        }
    }
    
    open override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if showReloadMenuItem == true {
            addMenuItem(with: .resume, title: FKLocalizedString("RELOAD", comment: "Reload"), action: #selector(updateData))
        }
        
        updateData()
    }
    
    @objc open func updateData() {
        // Used to override in subclasses
        finishedUpdatingData(dataArray: [])
    }
    
    public func finishedUpdatingData(dataArray: [Any]) {
        
        DispatchQueue.main.async {
            self.dataArray = dataArray
            self.updateTable()
        }
    }
    
    public func updateTable() {
        
        guard let table = self.table, updatingTable == false else {
            return
        }
        
        updatingTable = true
        
        var topCount = skip + limit
        var count = dataArray.count
        
        if moreButton == nil {
            topCount = count
        } else if topCount < count {
            count = topCount
        }
        
        var rowCount = table.numberOfRows
        
        // Configure the table object and get the row controllers.
        if rowCount > 0 && min(topCount, count) > rowCount {
            let indexSet = IndexSet(integersIn: rowCount ..< min(topCount, count))
            table.insertRows(at: indexSet, withRowType: rowType)
        } else if rowCount > 0 && topCount < rowCount {
            let indexSet = IndexSet(integersIn: topCount ..< rowCount)
            table.removeRows(at: indexSet)
        } else if rowCount != count {
            table.setNumberOfRows(count, withRowType: rowType)
        }
        rowCount = count
        
        // Iterate over the rows and set the label for each one.
        if resetLimitAndSkipOnReload == false && updateFromStart == true {
            updateFromStart = false
        }
        
        for index in 0 ..< rowCount {
            let dataDict = dataArray[index]
            update(rowIn: table, index: index, data: dataDict)
        }
        
        if rowCount == 0 {
            statusLabel?.setText(noDataString)
            statusLabel?.setHidden(false)
            moreButton?.setHidden(true)
        } else {
            statusLabel?.setHidden(true)
            
            if count == dataArray.count {
                moreButton?.setHidden(true)
            } else {
                moreButton?.setHidden(false)
            }
        }
        
        updatingTable = false
    }
    
    open func update(rowIn table: WKInterfaceTable, index: Int, data: Any) {
        // Used to override in subclasses
    }
    
    public func object(atIndex index: Int) -> Any? {
        
        if index < dataArray.count {
            return dataArray[index]
        } else {
            return nil
        }
    }
    
    @IBAction public func moreButtonPressed() {
        
        skip += limit
        if skip >= dataArray.count {
            skip = dataArray.count
        }
        
        updateTable()
    }
}
