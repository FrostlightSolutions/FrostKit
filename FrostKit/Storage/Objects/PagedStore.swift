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

///
/// Paged store allows storing of data in a paged form. It allows pre populating an array (with NSNull objects) in the store with the total number of object until they are called upon to be updated with the real data.
///
/// This class allows for a correct representation of how large a table or collection view is when used like an array in a data source for these UI items. It also allows the ability to only load items when they are needed and with the delegate method cancel or lower priority fast scroll past pages.
///
/// For more information on how FUS passes paginated data to clients, check out the Wiki page at: https://github.com/FrostlightSolutions/fus-server/wiki/Pagination-API
///
class PagedStore: NSObject, NSCoding, NSCopying {
    
    private lazy var _count = 0
    /// Returns the total count of object stored.
    var count: Int {
        return objects.count
    }
    private lazy var _objectsPerPage = 0
    /// Returns the total number of objects per page. All pages will have the same number of objects, apart from the last which might have less.
    var objectsPerPage: Int {
        return _objectsPerPage
    }
    /// THe number of pages in the store (not loaded, in total).
    var numberOfPages: Int {
        return Int(ceil(Double(_count) / Double(_objectsPerPage)))
    }
    /// The delegate of the store.
    var delegate: PagedArrayDelegate?
    private lazy var objects = NSArray()
    /// Thefirst object in the store.
    var firstObject: AnyObject? {
        return objects.firstObject
    }
    /// The last object in the store.
    var lastObject: AnyObject? {
        return objects.lastObject
    }
    /// A string that represents the contents of the stores array, formatted as a property list.
    override var description: String {
        return objects.description
    }
    
    override init() {
        super.init()
    }
    
    /**
    Initializes a store from anouther store.
    
    :param: store The store object to base the new one from.
    */
    convenience init(store: PagedStore) {
        self.init()
        
        _count = store._count
        _objectsPerPage = store._objectsPerPage
        objects = store.objects.copy() as NSArray
    }
    
    /**
    Initializes a store object from the total count and the number of objects per page.
    
    :param: totalCount     The total count of the store.
    :param: objectsPerPage The total objects per page. This should be the same for all pages (though it is excepted the last page may not furfil this value).
    */
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
    
    /**
    Initializes a store object from a JSON dictionary returned from FUS. It is assumed that the values returned in the dictionary will always be from page 1 (the first page).
    
    :param: json           The JSON dictionary returned from FUS.
    :param: objectsPerPage The total objects per page. This should be the same for all pages (though it is excepted the last page may not furfil this value).
    */
    convenience init(json: NSDictionary, objectsPerPage: Int) {
        var totalCount = 0
        if let count = json["count"] as? Int {
            totalCount = count
        }
        var objects = []
        if let results = json["results"] as? NSArray {
            objects = results
        }
        
        self.init(totalCount: totalCount, objectsPerPage: objectsPerPage)
        setObjects(objects, page: 1)
    }
    
    /**
    Initializes a store object for a non-paged array of objects returned from FUS. This creates a normal paged store but takes the whole array of objects as page 1 (the first page).
    
    :param: nonPagedObjects An array of objects to store.
    */
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
    
    /**
    Sets object into the store for a current page. This will either replace palceholder objects with data or update previous stored objects with the new values. If `totalCount` is returned and if it is different from the previous number then the store will add or remove the relevaent placeholders or objects in the store respectively.
    
    :param: newObjects The new objects to add or update into the store.
    :param: page       The page the objects have come from in FUS.
    :param: totalCount The updated total objects count.
    */
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
    
    /**
    Returns the object located at the specified index in the store.
    
    :param: index An index within the bounds of the store.
    
    :returns: The object located at index.
    */
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
    
    /**
    Returns the page number of the specified index in the store.
    
    :param: index An index with the bounds of the store.
    
    :returns: The page number the index is located in.
    */
    func pageForIndex(index: Int) -> Int {
        return index / objectsPerPage
    }
    
    /**
    Returns the lowest index whose corresponding store value is equal to a given object.
    
    :param: anObject The object to find in the store.
    
    :returns: The lowest index whose corresponding store value is equal to anObject. If none of the objects in the store is equal to anObject, returns NSNotFound.
    */
    func indexOfObject(anObject: AnyObject) -> Int {
        return objects.indexOfObject(anObject)
    }
    
    /**
    Returns the index set of the objects in the page requested.
    
    :param: page The page of the residing index sets.
    
    :returns: An index set of the indexes on the given page.
    */
    func indexSetForPage(page: Int) -> NSIndexSet {
        
        var rangeLength = objectsPerPage
        if page == numberOfPages {
            rangeLength = _count - ((numberOfPages - 1) * objectsPerPage)
        }
        return NSIndexSet(indexesInRange: NSMakeRange((page - 1) * objectsPerPage, rangeLength))
    }
    
    /**
    Returns the first page number whose corresponding store value is equal to a given object.
    
    :param: anObject The object to find in the store.
    
    :returns: The lowest page number whose corresponding store value is equal to anObject. If none of the objects in the store is equal to anObject, returns NSNotFound.
    */
    func pageForObject(anObject: AnyObject) -> Int {
        let index = indexOfObject(anObject)
        if index == NSNotFound {
            return index
        } else {
            return Int(floor(Double(index) / Double(objectsPerPage)))
        }
    }
    
}
