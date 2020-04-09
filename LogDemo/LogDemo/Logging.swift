//
//  Logging.swift
//  LogDemo
//
//  Created by kaho on 03/04/2020.
//  Copyright © 2020 kaho. All rights reserved.
//


//Example of using the framework

import Foundation

#if canImport(Log)
import Log
#endif


/*
 * If we don't link the framework, theoretically these inline functions
 * will be optimized away by the compiler in release settings
 * leaving no impact on final performance
 */

@inline(__always) func SetupLoggingConsole() {
    #if canImport(Log)
    EnableFloatingButton(true)
    #endif
}

@inline(__always) func ConsoleLog(_ message: String, category: String = "Default") {
    #if DEBUG
    print("[\(category)]" + message)
    #endif
    #if canImport(Log)
    Log(message, category: category)
    #endif
}

@inline(__always) func DebugLog(_ message: String) {
    ConsoleLog(message, category: "Debug")
}

@inline(__always) func HelloLog(_ message: String) {
    ConsoleLog(message, category: "Hello")
}
