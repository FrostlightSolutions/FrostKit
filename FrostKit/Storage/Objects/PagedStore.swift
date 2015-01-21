//
//  PagedStore.swift
//  FrostKit
//
//  Created by James Barrow on 20/01/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit

protocol PagedArrayDelegate {
    func pagedArray(pagedArray: PagedStore, willAccessIndex: Int, returnObject: AnyObject)
}

class PagedStore: NSObject, NSCoding, NSCopying {
    
    private lazy var _count = 0
    var count: Int {
        return objects.count
    }
    private lazy var _objectsPerPage = 0
    var objectsPerPage: Int {
        return _objectsPerPage
    }
    var numberOfPages: Int {
        return Int(ceil(Double(_count) / Double(_objectsPerPage)))
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
    
    override init() {
        super.init()
    }
    
    convenience init(store: PagedStore) {
        self.init()
        
        _count = store._count
        _objectsPerPage = store._objectsPerPage
        objects = store.objects
    }
    
    convenience init(totalCount: Int, objectsPerPage: Int) {
        self.init()
        
        _count = totalCount
        _objectsPerPage = objectsPerPage
        
        let objects = NSMutableArray(capacity: _count)
        for pageIndex in 0..<_count {
            objects.addObject(NSNull())
        }
        self.objects = objects
    }
    
    convenience init(json: NSDictionary, objectsPerPage: Int, page: Int) {
        var totalCount = 0
        if let count = json["count"] as? Int {
            totalCount = count
        }
        var objects = []
        if let results = json["results"] as? NSArray {
            objects = results
        }
        
        self.init(totalCount: totalCount, objectsPerPage: objectsPerPage)
        setObjects(objects, page: page)
    }
    
    convenience init(nonPagedObjects: NSArray) {
        
        self.init(totalCount: nonPagedObjects.count, objectsPerPage: nonPagedObjects.count)
        setObjects(nonPagedObjects, page: 1)
    }
    
    // MARK: - NSCoding Methods
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        _count = aDecoder.decodeIntegerForKey("count")
        _objectsPerPage = aDecoder.decodeIntegerForKey("objectsPerPage")
        if let objects = aDecoder.decodeObjectForKey("objects") as? NSArray {
            self.objects = objects
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeInteger(_count, forKey: "count")
        aCoder.encodeInteger(_objectsPerPage, forKey: "objectsPerPage")
        aCoder.encodeObject(objects, forKey: "objects")
    }
    
    // MARK: - NSCopying Methods
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return PagedStore(store: self)
    }
    
    // MARK: - Helper Methods
    
    func setObjects(newObjects: NSArray, page: Int, totalCount: Int? = nil) {
        
        let objects = self.objects.mutableCopy() as NSMutableArray
        
        if let newTotalCount = totalCount {
            if newTotalCount > _count {
                // Add missing placeholder objects
                for index in _count..<newTotalCount {
                    objects.addObject(NSNull())
                }
            } else if _count > newTotalCount {
                // Remove extra objects
                let range = NSMakeRange(newTotalCount, _count - newTotalCount)
                objects.removeObjectsInRange(range)
            }
            _count = newTotalCount
        }
        
        let indexSet = indexSetForPage(page)
        objects.replaceObjectsAtIndexes(indexSet, withObjects: newObjects)
        
        self.objects = objects
    }
    
    func objectAtIndex(index: Int) -> AnyObject {
        let object: AnyObject = objects[index]
        if let delegate = self.delegate {
            delegate.pagedArray(self, willAccessIndex: index, returnObject: object)
        }
        return object
    }
    
    subscript (idx: Int) -> AnyObject {
        return objectAtIndex(idx)
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
            rangeLength = _count - ((numberOfPages - 1) * objectsPerPage)
        }
        return NSIndexSet(indexesInRange: NSMakeRange((page - 1) * objectsPerPage, rangeLength))
    }
    
    func pageForObject(anObject: AnyObject) -> Int {
        let index = indexOfObject(anObject)
        return Int(floor(Double(index) / Double(objectsPerPage)))
    }
    
}
