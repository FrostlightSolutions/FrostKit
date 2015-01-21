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
    var count: Int {
        return objects.count
    }
    private lazy var _objectsPerPage = 0
    var objectsPerPage: Int {
        return _objectsPerPage
    }
    var numberOfPages: Int {
        return Int(ceil(Double(_totalCount) / Double(_objectsPerPage)))
    }
    var delegate: PagedArrayDelegate?
    private lazy var objects = NSArray()
    var firstObject: AnyObject? {
        return objects.firstObject
    }
    var lastObject: AnyObject? {
        return objects.lastObject
    }
    override var description: String {
        return objects.description
    }
    
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
    
    func setObjects(newObjects: NSArray, page: Int, totalCount: Int? = nil) {
        
        let objects = self.objects.mutableCopy() as NSMutableArray
        
        if let newTotalCount = totalCount {
            if newTotalCount > _totalCount {
                // Add missing placeholder objects
                for index in _totalCount..<newTotalCount {
                    objects.addObject(NSNull())
                }
            } else if _totalCount > newTotalCount {
                // Remove extra objects
                let range = NSMakeRange(newTotalCount, _totalCount - newTotalCount)
                objects.removeObjectsInRange(range)
            }
            _totalCount = newTotalCount
        }
        
        let indexSet = indexSetForPage(page)
        objects.replaceObjectsAtIndexes(indexSet, withObjects: newObjects)
        
        self.objects = objects
    }
    
    subscript (idx: Int) -> AnyObject {
        return objects[idx]
    }
    
    func pageForIndex(index: Int) -> Int {
        return index / objectsPerPage
    }
    
    func indexOfObject(anObject: AnyObject) -> Int {
        return objects.indexOfObject(anObject)
    }
    
    func indexSetForPage(page: Int) -> NSIndexSet {
        
        var rangeLength = objectsPerPage
        if page == numberOfPages {
            rangeLength = _totalCount - ((numberOfPages - 1) * objectsPerPage)
        }
        return NSIndexSet(indexesInRange: NSMakeRange((page - 1) * objectsPerPage, rangeLength))
    }
    
    func pageForObject(anObject: AnyObject) -> Int {
        let index = indexOfObject(anObject)
        return Int(floor(Double(index) / Double(objectsPerPage)))
    }
    
}
