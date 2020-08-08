//
//  Logger.swift
//  Log
//
//  Created by kaho on 03/04/2020.
//  Copyright © 2020 kaho. All rights reserved.
//

import Foundation
import UIKit


class ObservationToken {
    private let cancellationClosure: () -> Void
    init(cancellationClosure: @escaping () -> Void) {
        self.cancellationClosure = cancellationClosure
    }
    func cancel() {
        cancellationClosure()
    }
}


public class Logger {
    public struct Log {
        let timestamp: Date
        let message: String
        let category: String
    }
    
    static let shared = Logger()
    
    var categories = Set<String>()
    
    private var logs = [Log]()
    
    private let backgroundQueue = DispatchQueue(label: "Logger.BackgroundQueue")
        
    public func log(_ message:String, category: String?) {
        let category = category ?? "Default"
        backgroundQueue.async {
            [unowned self] in
            let logItem = Log(timestamp:Date(), message: message, category: category)
            self.logs.append(logItem)
            if !self.categories.contains(category) {
                self.categories.insert(category)
                self.knownCategoriesUpdateObservations.values.forEach {
                    closure in
                    closure(self.categories)
                }
            }
            self.newLogsObservations.values.forEach {
                closure in
                closure(logItem)
            }
        }
    }
    
    public func getLogs(resultHandler: @escaping ([Log]) -> Void) {
        backgroundQueue.async {
            [unowned self] in
            resultHandler(self.logs)
        }
    }
    weak var currentShowingWindow: ConsoleWindow?
    
    func setFloatingButtonShowing(_ showing: Bool) {
        floatingButtonWindow.isHidden = !showing
        if #available(iOS 13.0, *) {
            if let currentWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                floatingButtonWindow.windowScene = currentWindowScene
            }
        }
    }
    
    private init() {
        initializeFloatingButtonWindow()
        setFloatingButtonShowing(true)
    }
        
    private var newLogsObservations = [UUID : (Log) -> Void]()
    @discardableResult
    func addNewLogsObserver(
        _ observer: AnyObject,
        closure: @escaping (Log) -> Void) -> ObservationToken {
        return backgroundQueue.sync {
            [unowned self, weak observer] in
            let id = UUID()
            newLogsObservations[id] = {
                (item) in
                if observer == nil {
                    self.newLogsObservations.removeValue(forKey: id)
                    return
                }
                closure(item)
            }
            return ObservationToken { [weak self] in
                self?.newLogsObservations.removeValue(forKey: id)
            }
        }
    }
    
    private var knownCategoriesUpdateObservations = [UUID : (Set<String>) -> Void]()
    @discardableResult
    func addKnownCategoriesObserver(_ observer: AnyObject, closure: @escaping (Set<String>) -> Void)  -> ObservationToken {
        return backgroundQueue.sync {
            [unowned self, weak observer] in
            let id = UUID()
            newLogsObservations[id] = {
                (item) in
                if observer == nil {
                    self.knownCategoriesUpdateObservations.removeValue(forKey: id)
                    return
                }
                closure(self.categories)
            }
            return ObservationToken { [weak self] in
                self?.newLogsObservations.removeValue(forKey: id)
            }
        }
    }
    
    
    let floatingButtonWindow: UIWindow = FloatingButtonWindow()
    
    private let consoleButton: UIButton = {
        let button = UIButton()
        let diameter:CGFloat = 44
        button.frame.size = CGSize(width: diameter, height: diameter)
        button.layer.cornerRadius = diameter / 2
        button.setTitle("Logs", for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return button
    }()
    
    private func initializeFloatingButtonWindow() {
        let floatingButtonWindow = self.floatingButtonWindow as! FloatingButtonWindow
        floatingButtonWindow.windowLevel = .statusBar + 1
        floatingButtonWindow.button = self.consoleButton
        floatingButtonWindow.buttonTapHandler = {
            if let current = self.currentShowingWindow {
                current.dismiss()
            } else {
                let consoleModalView = ConsoleWindow(frame: CGRect(0,
                                                                   0,
                                                                   UIScreen.main.bounds.size.width - 32,
                                                                   UIScreen.main.bounds.size.height * 0.8))
                consoleModalView.show()
                self.currentShowingWindow = consoleModalView
            }
        }
        
        consoleButton.frame.origin.y = floatingButtonWindow.frame.size.height / 2
    }
    
}
