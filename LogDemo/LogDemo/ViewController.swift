//
//  ViewController.swift
//  LogDemo
//
//  Created by kaho on 03/04/2020.
//  Copyright © 2020 kaho. All rights reserved.
//

import UIKit
class ViewController: UIViewController {

    var window: UIWindow?
    
    var hellos = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DebugLog("This is a debug log.")
        
        DebugLog("Another one")
        let newwindow = UIWindow(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        newwindow.backgroundColor = .red
        newwindow.makeKeyAndVisible()
        hello()
    }
    
    func hello() {
        //recursively log hellos
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.hellos += 1
            HelloLog("hello \(self.hellos)")
            self.hello()
        }
    }
}

