//
//  CustomFonts.swift
//  FrostKit
//
//  Created by James Barrow on 02/10/2014.
//  Copyright © 2014 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

#if os(OSX)
import AppKit
#else
import UIKit
#endif

///
/// :FontAwesome Links:
/// - https://raw.githubusercontent.com/FortAwesome/Font-Awesome/master/less/variables.less
/// - https://github.com/FortAwesome/Font-Awesome/blob/master/fonts/fontawesome-webfont.ttf
///
/// :IonIcons Links:
/// - https://raw.githubusercontent.com/driftyco/ionicons/master/less/_ionicons-variables.less
/// - https://github.com/driftyco/ionicons/blob/master/fonts/ionicons.ttf
///
public class CustomFonts {
    
    /// Loads custom fonts imbedded in the Framework.
    public class func loadCustomFonts() {
        loadCustomFont(name: "fontawesome-webfont", withExtension: "ttf", bundle: Bundle(for: CustomFonts.self))
        loadCustomFont(name: "ionicons", withExtension: "ttf", bundle: Bundle(for: CustomFonts.self))
    }
    
    /**
    Load custom fonts with names including the file name and extension.
     
    - parameter names: An array of strings of the font file names.
    - parameter bundle:    The bundle to look for the file names in. By default this uses the main app bundle.
    */
    public class func loadCustomFonts(names: [String], bundle: Bundle = Bundle.main) {
        for fontName in names {
            let filename = fontName.components(separatedBy: ".").first
            let ext = (fontName as NSString).pathExtension
            
            if let name = filename, name.characters.count > 0 && ext.characters.count > 0 {
                loadCustomFont(name: name, withExtension: ext, bundle: bundle)
            } else {
                NSLog("ERROR: Failed to load '\(fontName)' font as the name or extension are invalid!")
            }
        }
    }
    
    /**
        Load a custom font from it's name and extention from within the bundle without having to declare it in the `Info.plist`.
     
        - parameter name:    The name of the font file name.
        - parameter ext:     The extention of the file.
        - parameter bundle:  The bundle the files are located in. By default this uses the main app bundle.
    */
    public class func loadCustomFont(name: String, withExtension ext: String, bundle: Bundle = Bundle.main) {
        
        guard let url = bundle.url(forResource: name, withExtension: ext),
            let provider = CGDataProvider(url: url as CFURL) else {
            NSLog("ERROR: Failed to get data provider for \"\(name)\" font!")
            return
        }
        
        // Fix for issue where creating a font could cause a deadlock and crash
        // Source: http://stackoverflow.com/questions/40242370/app-hangs-in-simulator#40256390
        // OpenRadar: http://www.openradar.me/18778790
#if os(OSX)
        _ = NSFont()
#else
        _ = UIFont()
#endif
        
        let font = CGFont(provider)
        var error: Unmanaged<CFError>?
        guard CTFontManagerRegisterGraphicsFont(font, &error) == true else {
            NSLog("ERROR: Failed to register \"\(name)\" font!")
            return
        }
        
        if let anError = error {
            let errorCode = CFErrorGetCode(anError.takeRetainedValue())
            if errorCode == CTFontManagerError.alreadyRegistered.rawValue {
                NSLog("Already loaded '\(name)' font!")
            } else {
                let errorDescription = CFErrorCopyDescription(anError.takeRetainedValue())
                NSLog("ERROR: Failed to load '\(name)' font with error: \(errorDescription)!")
            }
        } else {
            NSLog("Loaded '\(name)' successfully")
        }
    }
    
#if os(iOS) || os(watchOS) || os(tvOS)
    /// Loops though all the fonts families loaded onto the device and prints them to the console.
    public class func printAllFontFamilies() {
        
        for fontFamily in UIFont.familyNames {
            NSLog("\(fontFamily): \(UIFont.fontNames(forFamilyName: fontFamily))")
        }
    }
#endif
}
