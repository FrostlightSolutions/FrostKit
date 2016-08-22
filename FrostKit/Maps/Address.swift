//
//  Address.swift
//  FrostKit
//
//  Created by James Barrow on 13/04/2016.
//  Copyright © 2016-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit
import MapKit

///
/// An object that contains details on a address to the plot on the map view, along with other data such as name and addressString.
///
public class Address: NSObject {
    
    /// The ID of the addres object.
    public var objectID: String?
    /// The coordinate of the address.
    public var coordinate = CLLocationCoordinate2DMake(0.0, 0.0)
    /// The latitude of the address.
    public var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    /// The longitude of the address.
    public var longitude: CLLocationDegrees {
        return coordinate.longitude
    }
    /// If the address is valid then `true`, otherwise return `false`.
    public var isValid: Bool {
        if latitude == 0 && longitude == 0 {
            return false
        } else {
            return true
        }
    }
    /// The name of the address object.
    public var name = "N/A"
    /// The address string of the object.
    public var addressString = ""
    /// Returns a string that represents the contents of the receiving class.
    public override var description: String {
        return "<Latitude: \(latitude) Longitude: \(longitude) Address: \(addressString)>"
    }
    public override var hashValue: Int {
        return Int(latitude) ^ Int(longitude)
    }
    public var key: String {
        return "\(latitude)-\(longitude)"
    }
    
    /**
     A convenience initialiser for creating an address object from a dictionary returned from a FUS based system.
     
     - parameter dictionary: The dictionary to parse the information from.
     */
    public convenience init(dictionary: NSDictionary) {
        self.init()
        
        objectID = dictionary["id"] as? String
        
        if let latitude = dictionary["latitude"] as? Double {
            coordinate.latitude = latitude
        } else if let latitude = dictionary["latitude"] as? Float {
            coordinate.latitude = Double(latitude)
        } else if let latitude = dictionary["latitude"] as? Int {
            coordinate.latitude = Double(latitude)
        }
        
        if let longitude = dictionary["longitude"] as? Double {
            coordinate.longitude = longitude
        } else if let longitude = dictionary["longitude"] as? Float {
            coordinate.latitude = Double(longitude)
        } else if let longitude = dictionary["longitude"] as? Int {
            coordinate.latitude = Double(longitude)
        }
        
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        
        if let addressString = dictionary["addressString"] as? String {
            self.addressString = addressString
        }
    }
    
    /**
     A helper method for creating an array of address objects from an array of dictionaryies.
     
     - parameter array: An array of dictionaries returned by a FUS like system.
     
     - returns: An array of address objects.
     */
    public class func addressesFromArrayOfDictionaries(array: [NSDictionary]) -> [Address] {
        var adresses = [Address]()
        for dictionary in array {
            adresses.append(Address(dictionary: dictionary))
        }
        return adresses
    }
    
}

public func == (lhs: Address, rhs: Address) -> Bool {
    
    if lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude &&
        lhs.name == rhs.name && lhs.addressString == rhs.addressString {
        return true
    }
    return false
}
