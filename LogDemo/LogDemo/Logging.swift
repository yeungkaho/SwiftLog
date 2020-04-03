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

@inline(__always) func SetupLoggingConsole() {
    EnableFloatingButton(true)
}

@inline(__always) func DebugLog(_ message: String) {
    Log(message, category: "Debug")
}

@inline(__always) func HelloLog(_ message: String) {
    Log(message, category: "Hello")
}

#else

/*
 * If we don't link the framework, theoretically these inline functions
 * will be optimized away by the compiler leaving no impact on final performance
 */
@inline(__always) func SetupLoggingConsole() {}

@inline(__always) func DebugLog(_ message: String) {
    #if DEBUG
    print(message)
    #endif
}
@inline(__always) func IAPLog(_ message: String) {
    #if DEBUG
    print(message)
    #endif
}


#endif
