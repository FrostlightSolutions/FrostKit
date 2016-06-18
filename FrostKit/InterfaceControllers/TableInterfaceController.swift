//
//  TableInterfaceController.swift
//  FrostKit
//
//  Created by James Barrow on 18/06/2016.
//  Copyright © 2016-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import WatchKit

public class TableInterfaceController: WKInterfaceController {
    
    @IBInspectable public var rowType: String! = nil
    lazy var dataArray = [AnyObject]()
    @IBInspectable public var limit: Int = 10
    private var skip = 0
    @IBInspectable public var resetLimitAndSkipOnReload: Bool = false
    private var updateFromStart = false
    public var noDataString: String { return FKLocalizedString("NO_DATA", comment: "No Data") }
    @IBOutlet public weak var table: WKInterfaceTable!
    @IBOutlet public weak var titleGroup: WKInterfaceGroup?
    @IBOutlet public weak var titleLabel: WKInterfaceLabel?
    @IBOutlet public weak var statusLabel: WKInterfaceLabel?
    @IBOutlet public weak var moreButton: WKInterfaceButton?
    @IBInspectable public var showReloadMenuItem: Bool = true
    
    override public init() {
        super.init()
        
        moreButton?.setTitle(FKLocalizedString("MORE_", comment: "More..."))
        statusLabel?.setText(FKLocalizedString("LOADING_", comment: "Loading..."))
        
        dispatch_async(dispatch_get_main_queue()) {
            self.updateTable()
        }
    }
    
    override public func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if showReloadMenuItem == true {
            addMenuItemWithItemIcon(.Resume, title: FKLocalizedString("RELOAD", comment: "Reload"), action: #selector(updateData))
        }
    }
    
    override public func willActivate() {
        super.willActivate()
        
        updateData()
    }
    
    public func updateData() {
        // Used to override in subclasses
    }
    
    private func updateTable() {
        
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
            let range = NSRange(location: rowCount, length: count - rowCount)
            table.insertRowsAtIndexes(NSIndexSet(indexesInRange: range), withRowType: rowType)
        } else if rowCount > count {
            let range = NSRange(location: count, length: rowCount - count)
            table.removeRowsAtIndexes(NSIndexSet(indexesInRange: range))
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
            updateRow(table, index: index, data: dataDict)
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
    
    public func updateRow(table: WKInterfaceTable, index: Int, data: AnyObject) {
        // Used to override in subclasses
    }
    
    @IBAction public func moreButtonPressed() {
        
        skip += limit
        if skip >= dataArray.count {
            skip = dataArray.count
        }
        
        updateTable()
    }
    
}
