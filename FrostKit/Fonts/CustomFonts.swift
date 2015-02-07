//
//  CustomFonts.swift
//  FrostKit
//
//  Created by James Barrow on 02/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

///
/// :FontAwesome Links:
/// - https://raw.githubusercontent.com/FortAwesome/Font-Awesome/master/less/variables.less
/// - https://github.com/FortAwesome/Font-Awesome/blob/master/fonts/fontawesome-webfont.ttf
///
/// :IonIcons Links:
/// - https://raw.githubusercontent.com/driftyco/ionicons/master/less/_ionicons-variables.less
/// - https://github.com/driftyco/ionicons/blob/master/fonts/ionicons.ttf
///
public class CustomFonts: NSObject {
    
    /// Loads custom fonts imbedded in the Framework.
    public class func loadCustomFonts() {
        loadFont("fontawesome-webfont", withExtension: "ttf")
        loadFont("ionicons", withExtension: "ttf")
    }
    
    /**
        Load a custom font from it's name and extention from within the bundle without having to declare it in the `Info.plist`.
    
        :param: name    The name of the font file name.
        :param: ext     The extention of the file.
    */
    private class func loadFont(name: String, withExtension ext: String) {
        
        let bundle = NSBundle(forClass: CustomFonts.self)
        if let url = bundle.URLForResource(name, withExtension: ext) {
            
            let fontData = NSData(contentsOfURL: url)
            var error: Unmanaged<CFErrorRef>?
            let provider = CGDataProviderCreateWithCFData(fontData)
            let font = CGFontCreateWithDataProvider(provider)
            if CTFontManagerRegisterGraphicsFont(font, &error) == false {
                NSLog("ERROR: Failed to load \"\(name)\" font!")
            } else {
                NSLog("Loaded \"\(name)\" successfully")
            }
        } else {
            NSLog("ERROR: Failed to get URL for \"\(name)\" font!")
        }
    }
    
    /// Loops though all the fonts families loaded onto the device and prints them to the console.
    public class func printAllFontFamilies() {
        
        for fontFamily in UIFont.familyNames() {
            
            let name = fontFamily as String
            NSLog("\(name): \(UIFont.fontNamesForFamilyName(name))")
        }
    }
    
}
