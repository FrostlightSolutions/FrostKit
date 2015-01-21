//
//  PagedStore.swift
//  FrostKit
//
//  Created by James Barrow on 20/01/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit

protocol PagedArrayDelegate {
    func pagedArray(pagedArray: NSMutableArray, willAccessIndex: Int, returnObject: AnyObject)
}

class PagedStore: NSObject {
    
    private lazy var _totalCount = 0
    private lazy var _objectsPerPage = 0
    var objectsPerPage: Int {
        return _objectsPerPage
    }
    var numberOfPages: Int {
        return Int(ceil(Double(_totalCount) / Double(_objectsPerPage)))
    }
    var delegate: PagedArrayDelegate?
    lazy var objects = NSArray()
    
    convenience init(totalCount: Int, objectsPerPage: Int) {
        self.init()
        
        _totalCount = totalCount
        _objectsPerPage = objectsPerPage
        
        let objects = NSMutableArray(capacity: _totalCount)
        for pageIndex in 0..<_totalCount {
            objects.addObject(NSNull())
        }
        self.objects = objects
    }
    
    // MARK: - Helper Methods
    
    func setObjects(newObjects: NSArray, page: Int) {
        
        let indexSet = indexSetForPage(page)
        let objects = self.objects.mutableCopy() as NSMutableArray
        objects.replaceObjectsAtIndexes(indexSet, withObjects: newObjects)
        self.objects = objects
    }
    
    func pageForIndex(index: Int) -> Int {
        return index / objectsPerPage
    }
    
    func indexSetForPage(page: Int) -> NSIndexSet {
        
        var rangeLength = objectsPerPage
        if page == numberOfPages {
            rangeLength = _totalCount - ((numberOfPages - 1) * objectsPerPage)
        }
        return NSIndexSet(indexesInRange: NSMakeRange((page - 1) * objectsPerPage, rangeLength))
    }
    
}
