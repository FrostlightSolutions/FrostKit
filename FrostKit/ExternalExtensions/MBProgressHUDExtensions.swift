//
//  MBProgressHUDExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 09/02/2015.
//  Copyright © 2015 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

@available(iOS, deprecated: 13.0, message: "MBProgressHUD no longer uses windows to present HUDs. This class will be removed in v2.0.0 of FrostKit.")
extension MBProgressHUD {
    
    public class func progressHUDinMainWindow() -> MBProgressHUD {
        let hud: MBProgressHUD
        var window: UIWindow?
        if let mainWindow = UIApplication.sharedApplication().delegate?.window {
            window = mainWindow
            hud = MBProgressHUD(window: mainWindow)
        } else {
            hud = MBProgressHUD()
        }
        
        hud.mode = .Text
        hud.animationType = .Fade
        hud.removeFromSuperViewOnHide = true
        window?.addSubview(hud)
        
        return hud
    }
}
