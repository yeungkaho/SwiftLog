//
//  ConsoleWindow.swift
//  Log
//
//  Created by kaho on 03/04/2020.
//  Copyright © 2020 kaho. All rights reserved.
//

import Foundation

import UIKit
import CollectionKit

class ConsoleWindow: ModalView {
    
    let textView = UITextView()
    let dismissButton = UIButton()
    
    let scrollLockSwitch = UISwitch()
    
    func scrollToBottomIfNeeded(animated:Bool = false) {
        if !scrollLockSwitch.isOn, textView.bounds.height < textView.contentSize.height {
            textView.layoutManager.ensureLayout(for: textView.textContainer)
            textView.setContentOffset([0, textView.contentSize.height - textView.frame.size.height],
                                      animated: animated)
        }
    }

    static var filteringTags = Set<String>()
    
    let categoriesCollectionView = CollectionView()
    
    let copyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Copy", for: .normal)
        button.sizeToFit()
        return button
    }()
    
    var timer: Timer?
    
    override func setup() {
        layer.cornerRadius = 8
        clipsToBounds = true
        textView.backgroundColor = UIColor(hexRGB: 0x13773D)
        textView.textColor = UIColor(hexRGB: 0xFFF0A5)
        textView.isEditable = false
        textView.contentInset = [60]
        textView.font = UIFont(name: "CourierNewPS-BoldMT", size: 12)
        textView.alwaysBounceVertical = true
        
        addSubview(textView)
        
        dismissButton.setTitle("X", for: .normal)
        
        dismissButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        addSubview(dismissButton)
        refresh()
        Logger.shared.addNewLogsObserver(self) {
            [weak self] (newLog) in
            guard let self = self else { return }
            self.appendLogToBuffer(newLog)
        }
        Logger.shared.addKnownCategoriesObserver(self) { [weak self] categories in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.categoriesDataSource.data = Array(categories)
                self.categoriesCollectionView.reloadData()
            }
        }
        scrollLockSwitch.isOn = false
        addSubview(scrollLockSwitch)
        
        addSubview(categoriesCollectionView)
        setupTagsSelection()
        
        setNeedsLayout()
        
        timer = Timer(timeInterval: 0.5, repeats: true, block: {
            [weak self] (_) in
            self?.processBufferedLogs()
        })
        RunLoop.main.add(timer!, forMode: .common)
        addSubview(copyButton)
        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
    }
    
    let bufferQueue = DispatchQueue(label: "ConsoleWindow.bufferQueue", qos:.utility)
    var logBuffer = [Logger.Log]()
    private func appendLogToBuffer(_ log:Logger.Log) {
        bufferQueue.async {
            [weak self] in
            guard let self = self else { return }
            self.logBuffer.append(log)
        }
    }
    
    private func processBufferedLogs() {
        bufferQueue.async {
            [weak self] in
            guard let self = self, self.logBuffer.count > 0 else { return }
            var textToAppend = ""
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            for log in self.logBuffer {
                let shouldLog = ConsoleWindow.filteringTags.count == 0 || ConsoleWindow.filteringTags.contains(log.category)
                if shouldLog {
                    textToAppend += formatter.string(from: log.timestamp) + "\n" + log.message + "\n\n"
                }
            }
            self.logBuffer.removeAll()
            DispatchQueue.main.async {
                let textView = self.textView
                let oldText = textView.text ?? ""
                textView.text = oldText + textToAppend
                self.scrollToBottomIfNeeded()
            }
        }
    }
    private let categoriesDataSource = ArrayDataSource<String>(data:Array(Logger.shared.categories))
    private func setupTagsSelection() {
        categoriesCollectionView.showsHorizontalScrollIndicator = false
        
        let tabsLayout = FlowLayout(spacing: 8,
                                    justifyContent: .spaceAround,
                                    alignItems: .center,
                                    alignContent: .center).transposed()
        
        func updateTagLabel(label:UILabel, category:String, selected:Bool) {
            label.text = category
            label.font = selected ? UIFont(name: "CourierNewPS-BoldMT", size: 12) : UIFont(name: "CourierNewPSMT", size: 12)
            label.backgroundColor = selected ? UIColor(hexRGB: 0xFFF0A5) : UIColor.white.withAlphaComponent(0.8)
            label.textColor = selected ? UIColor(hexRGB: 0x13773D) : .darkGray
        }
        func labelGenerator(data: String, index: Int) -> UILabel {
            let label = UILabel()
            label.textAlignment = .center
            label.layer.shadowColor = UIColor.black.cgColor
            label.layer.shadowRadius = 6
            label.layer.shadowOpacity = 0.3
            return label
        }
        let viewSource = ClosureViewSource<String,UILabel>(viewGenerator: labelGenerator) {
            (label, category, i) in
            updateTagLabel(label: label, category:category, selected: ConsoleWindow.filteringTags.contains(category))
        }
        
        let tabsProvider = BasicProvider<String,UILabel>(
            dataSource: categoriesDataSource,
            viewSource: viewSource,
            sizeSource: {
                [unowned self]
                (index, data, _) in
                let rect = (data as NSString).boundingRect(with: self.categoriesCollectionView.size,
                                                                 options: [.usesLineFragmentOrigin,.usesFontLeading],
                                                                 attributes: [NSAttributedString.Key.font:UIFont(name: "CourierNewPS-BoldMT", size: 12)!],
                                                                 context: nil)
                return [rect.width + 8, self.categoriesCollectionView.height]
            },
            layout: tabsLayout,
            tapHandler: {
                [weak self]
                context in
                guard let self = self else { return }
                if ConsoleWindow.filteringTags.contains(context.data) {
                    ConsoleWindow.filteringTags.remove(context.data)
                } else {
                    ConsoleWindow.filteringTags.insert(context.data)
                }
                updateTagLabel(label: context.view, category:context.data, selected: ConsoleWindow.filteringTags.contains(context.data))
                self.refresh()
            }
        )
        categoriesCollectionView.provider = tabsProvider
    }
    
    override func layoutSubviews() {
        textView.frame = bounds
        dismissButton.sizeToFit()
        dismissButton.left = 16
        dismissButton.top = 16
        
        scrollLockSwitch.right = width - 16
        scrollLockSwitch.top = 16
        
        categoriesCollectionView.frame = [dismissButton.right + 16, 16, scrollLockSwitch.left - dismissButton.right - 32, 32]
        
        scrollToBottomIfNeeded(animated: false)
        
        copyButton.centerX = width/2
        copyButton.bottom = textView.bottom
    }

    func refresh() {
        Logger.shared.getLogs {
            [weak self] (logs) in
            guard let self = self else { return }
            self.bufferQueue.async {
                var text = ""
                
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss.SSS"
                for log in logs {
                    if ConsoleWindow.filteringTags.count == 0 || ConsoleWindow.filteringTags.contains(log.category) {
                        text += (formatter.string(from: log.timestamp) + "\n" + log.message + "\n\n")
                    }
                }
                DispatchQueue.main.async {
                    self.textView.text = text
                    self.scrollToBottomIfNeeded()
                }
            }
            
        }
    }
    
    @objc func copyTapped() {
        if let logs = textView.text {
            UIPasteboard.general.string = logs
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
    
    override func dismiss() {
        timer?.invalidate()
        timer = nil
        super.dismiss()
    }
    
}
