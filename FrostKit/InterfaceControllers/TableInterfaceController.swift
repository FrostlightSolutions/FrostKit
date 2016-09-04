//
//  TableInterfaceController.swift
//  FrostKit
//
//  Created by James Barrow on 18/06/2016.
//  Copyright © 2016-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import WatchKit

public class TableInterfaceController: WKInterfaceController {
    
    public var rowType: String! { return nil }
    private lazy var dataArray = [AnyObject]()
    public var limit: Int { return 10 }
    private var skip = 0
    public var resetLimitAndSkipOnReload: Bool { return false }
    private var updateFromStart = false
    public var noDataString: String { return FKLocalizedString(key: "NO_DATA", comment: "No Data") }
    @IBOutlet public weak var table: WKInterfaceTable!
    @IBOutlet public weak var titleGroup: WKInterfaceGroup?
    @IBOutlet public weak var titleLabel: WKInterfaceLabel?
    @IBOutlet public weak var statusLabel: WKInterfaceLabel?
    @IBOutlet public weak var moreButton: WKInterfaceButton?
    public var showReloadMenuItem: Bool { return true }
    
    public override init() {
        super.init()
        
        moreButton?.setTitle(FKLocalizedString(key: "MORE_", comment: "More..."))
        statusLabel?.setText(FKLocalizedString(key: "LOADING_", comment: "Loading..."))
        
        DispatchQueue.main.async() {
            self.updateTable()
        }
    }
    
    public override func awake(withContext context: AnyObject?) {
        super.awake(withContext: context)
        
        if showReloadMenuItem == true {
            addMenuItem(with: .resume, title: FKLocalizedString(key: "RELOAD", comment: "Reload"), action: #selector(updateData))
        }
        
        updateData()
    }
    
    public func updateData() {
        // Used to override in subclasses
        finishedUpdatingData([])
    }
    
    public func finishedUpdatingData(dataArray: [AnyObject]) {
        
        dispatch_async(dispatch_get_main_queue()) { 
            self.dataArray = dataArray
            self.updateTable()
        }
    }
    
    public func updateTable() {
        
        guard let table = self.table else {
            return
        }
        
        var topCount = skip+limit
        var count = dataArray.count
        
        if moreButton == nil {
            topCount = count
        } else if topCount < count {
            count = topCount
        }
        
        var rowCount = table.numberOfRows
        
        // Configure the table object and get the row controllers.
        if rowCount < count {
            let indexSet = IndexSet(integersIn: rowCount ..< count - rowCount)
            table.insertRows(at: indexSet, withRowType: rowType)
        } else if rowCount > count {
            let indexSet = IndexSet(integersIn: rowCount ..< count - rowCount)
            table.removeRows(at: indexSet)
        } else {
            table.setNumberOfRows(count, withRowType: rowType)
        }
        rowCount = count
        
        // Iterate over the rows and set the label for each one.
        if resetLimitAndSkipOnReload == false && updateFromStart == true {
            updateFromStart = false
        }
        
        for index in 0..<rowCount {
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
    }
    
    public func update(rowIn table: WKInterfaceTable, index: Int, data: AnyObject) {
        // Used to override in subclasses
    }
    
    public func objectAtIndex(index: Int) -> AnyObject? {
        
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
