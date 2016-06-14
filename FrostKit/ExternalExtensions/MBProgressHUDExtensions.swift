//
//  MBProgressHUDExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 09/02/2015.
//  Copyright (c) 2015 Forstlight Solutions. All rights reserved.
//

import UIKit

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
