//
//  DataStore.swift
//  FrostKit
//
//  Created by James Barrow on 20/01/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit

/// The data store delegate provides callback for when a item or page will be accessed. This can be used to work out if a item or page needs to be updated with the API or service.
@objc public protocol DataStoreDelegate {
    /**
    This function is called when an item will be accessed at an index.
    
    :param: dataStore The data store the item resides in.
    :param: index     The index of the item being accessed.
    :param: object    The item being accessed.
    */
    optional func dataStore(dataStore: DataStore, willAccessIndex index: Int, returnObject object: AnyObject)
    
    /**
    This function is called when a page will be accessed.
    
    :param: dataStore The data store the item resides in.
    :param: page      The page being accessed.
    */
    optional func dataStore(dataStore: DataStore, willAccessPage page: Int)
}

///
/// Data store allows storing of data in paged or non-paged form. Paged data is added and removed dynamically as it is set or cleared from the store. For example, a data store might have 1000 entires, but if only the first 3 pages have been set then it will only be 3 * objects per page in size.
///
/// However it also provides a correct representation of how large a table or collection view should be when used like an array in a data source for these UI items. It also allows the ability to only load items when they are needed and with the delegate method, to cancel or lower priority during fast scrolling past pages.
///
/// For more information on how FUS passes paginated data to clients, check out the Wiki page at: https://github.com/FrostlightSolutions/fus-server/wiki/Pagination-API
///
/// A data store object also allows for storing of non-paged data. This would be either an non-paged array or a single dictionary object of data.
///
public class DataStore: NSObject, NSCoding, NSCopying {
    
    /// Returns the total count of objects stated by FUS.
    public var count = 0
    private var _objectsPerPage = 0
    /// Returns the total number of objects per page. All pages will have the same number of objects, apart from the last which might have less.
    public var objectsPerPage: Int {
        return _objectsPerPage
    }
    /// The number of pages in the store (not loaded, in total).
    public var numberOfPages: Int {
        return Int(ceil(Double(count) / Double(_objectsPerPage)))
    }
    /// The delegate of the store.
    public var delegate: DataStoreDelegate?
    /// The last accessed page.
    private var lastAccessedPage = NSNotFound
    /// The objects in the store.
    private var objects = NSArray()
    /// The first object in the store.
    public var firstObject: AnyObject? {
        return objects.firstObject
    }
    /// The last object in the store.
    public var lastObject: AnyObject? {
        return objects.lastObject
    }
    /// Returns a dictionary object if it is the first item in the array. This is used as a convenience method for getting a single dictionary object in the store.
    public var dictionary: NSDictionary? {
        return firstObject as? NSDictionary
    }
    /// A string that represents the contents of the stores array, formatted as a property list.
    override public var description: String {
        return objects.description
    }
    override public var hash: Int {
        return objects.hash ^ objectsPerPage
    }
    
    /**
    Initializes a store from anouther store.
    
    :param: store The store object to base the new one from.
    */
    init(store: DataStore) {
        super.init()
        
        count = store.count
        _objectsPerPage = store._objectsPerPage
        objects = store.objects.copy() as! NSArray
    }
    
    /**
    Initializes a store object from the total count and the number of objects per page.
    
    :param: totalCount     The total count of the store.
    :param: objectsPerPage The total objects per page. This should be the same for all pages (though it is excepted the last page may not furfil this value).
    */
    public init(totalCount: Int, objectsPerPage: Int) {
        super.init()
        
        count = totalCount
        _objectsPerPage = objectsPerPage
        objects = NSMutableArray(capacity: count)
    }
    
    /**
    Initializes a store object from a JSON dictionary returned from FUS. It is assumed that the values returned in the dictionary will always be from page 1 (the first page).
    
    :param: json           The JSON dictionary returned from FUS.
    :param: objectsPerPage The total objects per page. This should be the same for all pages (though it is excepted the last page may not furfil this value).
    */
    convenience public init(json: NSDictionary) {
        var totalCount = 0
        if let count = json["count"] as? Int {
            totalCount = count
        }
        var objects = []
        if let results = json["results"] as? NSArray {
            objects = results
        }
        
        var objectsPerPage = 10
        if let perPage = json["per_page"] as? Int {
            objectsPerPage = perPage
        }
        
        self.init(totalCount: totalCount, objectsPerPage: objectsPerPage)
        setObjects(objects, page: 1)
    }
    
    /**
    Initializes a store object for a non-paged array of objects returned from FUS. This creates a normal paged store but takes the whole array of objects as page 1 (the first page).
    
    :param: nonPagedObjects An array of objects to store.
    */
    convenience public init(nonPagedObjects: NSArray) {
        
        self.init(totalCount: nonPagedObjects.count, objectsPerPage: nonPagedObjects.count)
        setObjects(nonPagedObjects, page: 1)
    }
    
    /**
    Initializes a store object for a non-paged single NSDictionary object returned from FUS. This creates a normal paged store but only sets it with 1 object. To access this object you should use the `dictionary` variable on the store object.
    
    :param: dictionary The dictionary to store.
    */
    convenience public init(dictionary: NSDictionary) {
        self.init(nonPagedObjects: [dictionary])
    }
    
    /**
    Initializes a store object from a paged, non-paged or single object. This init will work out what type of store needs to be made and call the correct init method. If none of the expected type are passed in it just creates an empty object.
    
    :param: object A NSDictionary or NSArray representing a paged, non-paged or single object.
    */
    convenience public init(object: AnyObject) {
        if let dict = object as? NSDictionary {
            if dict["results"] != nil && dict["count"] != nil {
                // Paged Dictionary Reference with Objects
                self.init(json: dict)
            } else {
                // Single Object
                self.init(dictionary: dict)
            }
        } else if let array = object as? NSArray {
            // Non-Paged Array of Objects
            self.init(nonPagedObjects: array)
        } else {
            // Unknown Object Type
            self.init(nonPagedObjects: [])
        }
    }
    
    // MARK: - NSCoding Methods
    
    required public init(coder aDecoder: NSCoder) {
        super.init()
        
        count = aDecoder.decodeIntegerForKey("count")
        _objectsPerPage = aDecoder.decodeIntegerForKey("objectsPerPage")
        if let objects = aDecoder.decodeObjectForKey("objects") as? NSArray {
            self.objects = objects
        }
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(count, forKey: "count")
        aCoder.encodeInteger(_objectsPerPage, forKey: "objectsPerPage")
        aCoder.encodeObject(objects, forKey: "objects")
    }
    
    // MARK: - NSCopying Methods
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        return DataStore(store: self)
    }
    
    // MARK: - Comparison Methods
    
    public func isEqualToDataStore(object: DataStore?) -> Bool {
        if let dataStore = object {
            
            let haveEqualCounts = self.count == dataStore.count
            let haveEqualObjectsPerPage = self.objectsPerPage == dataStore.objectsPerPage
            let haveEqualObjects = self.objects.isEqualToArray(dataStore.objects as! [AnyObject])
            
            return haveEqualCounts && haveEqualObjectsPerPage && haveEqualObjects
        }
        return false
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if let dataStore = object as? DataStore {
            return self.isEqualToDataStore(dataStore)
        }
        return false
    }
    
    // MARK: - Helper Methods
    
    /**
    Sets object into the store for a current page. This will either replace palceholder objects with data or update previous stored objects with the new values. If `totalCount` is returned and if it is different from the previous number then the store will add or remove the relevaent placeholders or objects in the store respectively.
    
    :param: newObjects The new objects to add or update into the store.
    :param: page       The page the objects have come from in FUS.
    :param: totalCount The updated total objects count.
    
    :returns: `true` if updated store is different from previous store, `false` if nothing changed.
    */
    public func setObjects(newObjects: NSArray, page: Int, totalCount: Int? = nil) -> Bool {
        
        var objectsChanged = false
        let objects = self.objects.mutableCopy() as! NSMutableArray
        if newObjects.count > 0 {
            if let newTotalCount = totalCount {
                count = newTotalCount
            }
            
            if count > objects.count {
                // Replace existing objects or add new objects if out of bounds
                var newObjectIndex = 0
                let indexSet = indexSetForPage(page)
                for index in indexSet.firstIndex...indexSet.lastIndex {
                    let newObject: AnyObject = newObjects[newObjectIndex]
                    newObjectIndex++
                    
                    if index < objects.count {
                        objects.replaceObjectAtIndex(index, withObject: newObject)
                    } else {
                        objects.addObject(newObject)
                    }
                }
            } else if objects.count > count {
                // Remove extra objects
                let range = NSMakeRange(count, objects.count - count)
                objects.removeObjectsInRange(range)
            }
        }
        
        if objects.isEqualToArray(self.objects as! [AnyObject]) == false {
            objectsChanged = true
        }
        
        self.objects = objects
        return objectsChanged
    }
    
    /**
    Helper method to set or update a page's data from a JSON response.
    
    :param: json The JSON dictionary to parse.
    
    :returns: `true` if updated store is different from previous store, `false` if nothing changed.
    */
    public func setObjectFrom(#json: NSDictionary, page: Int) -> Bool {
        var totalCount = 0
        if let count = json["count"] as? Int {
            totalCount = count
        }
        var objects = []
        if let results = json["results"] as? NSArray {
            objects = results
        }
        
        if let perPage = json["per_page"] as? Int {
            if objectsPerPage != perPage {
                _objectsPerPage = perPage
            }
        }
        
        return setObjects(objects, page: page, totalCount: totalCount)
    }
    
    /**
    A helper method for setting or updating the dictionary object.
    
    :param: dictionary The dictionary object to set or update in the store.
    
    :returns: `true` if updated store is different from previous store, `false` if nothing changed.
    */
    public func setDictionary(dictionary: NSDictionary) -> Bool {
        return setObjects([dictionary], page: 1)
    }
    
    /**
    A helper method to set or update the store from a paged, non-paged or single object. This setter will work out what type of store needs to be made and call the correct set method. If none of the expected type are passed in it does nothing.
    
    :param: object A NSDictionary or NSArray representing a paged, non-paged or single object.
    
    :returns: `true` if updated store is different from previous store, `false` if nothing changed.
    */
    public func setFrom(#object: AnyObject, page: Int?) -> Bool {
        var hasChanged = false
        if let dict = object as? NSDictionary {
            if dict["results"] != nil && dict["count"] != nil {
                var thePage = 1
                if page != nil {
                    thePage = page!
                }
                // Paged Dictionary Reference with Objects
                hasChanged = setObjectFrom(json: dict, page: thePage)
            } else {
                // Single Object
                hasChanged = setDictionary(dict)
            }
        } else if let array = object as? NSArray {
            // Non-Paged Array of Objects
            hasChanged = setObjects(array, page: 1, totalCount: array.count)
        }
        return hasChanged
    }
    
    /**
    Returns the object located at the specified index in the store.
    
    :param: index An index within the bounds of the store.
    
    :returns: The object located at index.
    */
    public func objectAtIndex(index: Int) -> AnyObject? {
        let page = pageForIndex(index)
        if page != lastAccessedPage {
            lastAccessedPage = page
            delegate?.dataStore?(self, willAccessPage: page)
        }
        
        if index < objects.count {
            let object: AnyObject = objects[index]
            delegate?.dataStore?(self, willAccessIndex: index, returnObject: object)
            return object
        }
        return nil
    }
    
    public subscript (idx: Int) -> AnyObject? {
        return objectAtIndex(idx)
    }
    
    /**
    Returns the page number of the specified index in the store.
    
    :param: index An index with the bounds of the store.
    
    :returns: The page number the index is located in.
    */
    public func pageForIndex(index: Int) -> Int {
        return (index / objectsPerPage) + 1
    }
    
    /**
    Returns the lowest index whose corresponding store value is equal to a given object.
    
    :param: anObject The object to find in the store.
    
    :returns: The lowest index whose corresponding store value is equal to anObject. If none of the objects in the store is equal to anObject, returns NSNotFound.
    */
    public func indexOfObject(anObject: AnyObject) -> Int {
        return objects.indexOfObject(anObject)
    }
    
    /**
    Returns the index set of the objects in the page requested.
    
    :param: page The page of the residing index sets.
    
    :returns: An index set of the indexes on the given page.
    */
    public func indexSetForPage(page: Int) -> NSIndexSet {
        
        var rangeLength = objectsPerPage
        if page == numberOfPages {
            rangeLength = count - ((numberOfPages - 1) * objectsPerPage)
        }
        return NSIndexSet(indexesInRange: NSMakeRange((page - 1) * objectsPerPage, rangeLength))
    }
    
    /**
    Retirns the index paths for the object in the page requested.
    
    :param: page The page of the residing index sets.
    
    :returns: An array of index paths on the given page.
    */
    public func indexPathsForPage(page: Int) -> [NSIndexPath] {
        let indexSet = indexSetForPage(page)
        var indexPaths = Array<NSIndexPath>()
        indexSet.enumerateIndexesUsingBlock({ (idx, stop) -> Void in
            indexPaths.append(NSIndexPath(forRow: idx, inSection: 0))
        })
        return indexPaths
    }
    
    /**
    Returns the first page number whose corresponding store value is equal to a given object.
    
    :param: anObject The object to find in the store.
    
    :returns: The lowest page number whose corresponding store value is equal to anObject. If none of the objects in the store is equal to anObject, returns NSNotFound.
    */
    public func pageForObject(anObject: AnyObject) -> Int {
        let index = indexOfObject(anObject)
        if index == NSNotFound {
            return index
        } else {
            return Int(floor(Double(index) / Double(objectsPerPage)))
        }
    }
    
}
