//
//  FloatingButton.swift
//  Log
//
//  Created by kaho on 03/04/2020.
//  Copyright © 2020 kaho. All rights reserved.
//

import Foundation
import UIKit

class FloatingButtonWindow: UIWindow {
    
    var buttonTapHandler: (() -> Void)?
    
    var button: UIButton? {
        didSet {
            if let button = button {
                button.addTarget(self, action: #selector(consoleButtonTapped), for: .touchUpInside)
                button.isUserInteractionEnabled = true
                let pan = UIPanGestureRecognizer(target: self, action: #selector(buttonDragged(_:)))
                button.addGestureRecognizer(pan)
                rootViewController?.view.addSubview(button)
            }
        }
    }
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        self.rootViewController = UIViewController()
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let button = button else { return false }
        let buttonPoint = convert(point, to: button)
        return button.point(inside: buttonPoint, with: event)
    }
        
    @objc private func consoleButtonTapped() {
        ///summon console window
        buttonTapHandler?()
    }
    
    @objc private func buttonDragged(_ sender:UIPanGestureRecognizer) {
        guard let consoleButton = button else {return}
        let windowSize = frame.size
        let tranlation = sender.translation(in: consoleButton)
        let buttonFrame = consoleButton.frame
        let newFrame = buttonFrame.applying(CGAffineTransform(translationX: tranlation.x, y: tranlation.y))
        consoleButton.frame = newFrame
        sender.setTranslation(.zero, in: consoleButton)
        
        switch sender.state {
        case .began:
            //            consoleButton.isEnabled = false
            break
        case .changed:
            break
        default:
            var outOfBounds = false
            var correctedFrame = newFrame
            
            if newFrame.origin.x < 0 {
                outOfBounds = true
                correctedFrame.origin.x = 0
            } else if newFrame.maxX > windowSize.width {
                outOfBounds = true
                correctedFrame.origin.x = windowSize.width - correctedFrame.size.width
            }
            
            let safeArea: UIEdgeInsets
            if #available(iOS 11.0, *) {
                safeArea = safeAreaInsets
            } else {
                safeArea = .zero
            }
            
            if newFrame.origin.y < safeArea.top {
                outOfBounds = true
                correctedFrame.origin.y = safeArea.top
            } else if newFrame.maxY > windowSize.height - safeArea.bottom {
                outOfBounds = true
                correctedFrame.origin.y = windowSize.height - safeArea.bottom - correctedFrame.size.height
            }
            if outOfBounds {
                UIView.animate(withDuration: 0.2) {
                    consoleButton.frame = correctedFrame
                }
            }
        }
    }
    
}
