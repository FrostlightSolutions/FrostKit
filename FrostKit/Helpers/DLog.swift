//
//  DLog.swift
//  Vanir
//
//  Created by James Barrow on 2017-12-05.
//  Copyright © 2017 Frostlight Solutions AB. All rights reserved.
//

import Foundation

public func DLog(_ message: @autoclosure () -> String) {
#if DEBUG
    NSLog(message())
#endif
}
