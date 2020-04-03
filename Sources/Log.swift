//
//  Log.swift
//  Log
//
//  Created by kaho on 03/04/2020.
//  Copyright © 2020 kaho. All rights reserved.
//

import Foundation

//Only public APIs

public func Log(_ message: String, category: String?) {
    Logger.shared.log(message, category: category)
}

public func EnableFloatingButton(_ enabled: Bool) {
    Logger.shared.setFloatingButtonShowing(enabled)
}
