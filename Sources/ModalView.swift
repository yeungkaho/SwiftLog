//
//  ModalView.swift
//  Log
//
//  Created by kaho on 03/04/2020.
//  Copyright © 2020 kaho. All rights reserved.
//

import Foundation
import UIKit


typealias ModalViewLevel = UIWindow.Level

@objc enum ModalViewInAnimation: Int {
    case fromCenter
    case opacity
    case none
}

@objc enum modalViewOutAnimation: Int {
    case none
    case opacity
}

class ModalView: UIView {
    
    @objc var dismissesWhenBackgroundTapped = true
    @objc var inAnimation: ModalViewInAnimation = .fromCenter
    @objc var outAnimation: modalViewOutAnimation = .none
    @objc var animationDuration = 0.125
    @objc var centered: Bool
    @objc var backgroundViewBackgroundColor = UIColor.black.withAlphaComponent(0.5) {
        didSet {
            backgroundView.backgroundColor = backgroundViewBackgroundColor
        }
    }
    
    @objc func show() {
        ModalViewContainer.prepareToShow(self, level: level)
    }
    
    @objc func dismiss() {
        isUserInteractionEnabled = false
        switch outAnimation {
        case .none:
            backgroundView.removeFromSuperview()
            ModalViewContainer.cleanUpAfterHiding(self)
        case .opacity:
            UIView.animate(withDuration: animationDuration, delay: 0.0625, animations: {
                self.alpha = 0
                self.backgroundView.alpha = 0
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                self.backgroundView.removeFromSuperview()
                ModalViewContainer.cleanUpAfterHiding(self)
            }
        }
    }
    
    private convenience init() {
        self.init(frame: UIScreen.main.bounds, level: .alert)
    }
    
    convenience override init(frame: CGRect) {
        self.init(frame: frame, level: .statusBar)
    }
    
    init(frame: CGRect, level:ModalViewLevel, centered: Bool = true) {
        
        self.level = level
        self.centered = centered
        backgroundView = UIView()
        
        super.init(frame: frame)
        setup()
        backgroundView.backgroundColor = backgroundViewBackgroundColor
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        backgroundView.isUserInteractionEnabled = true
        backgroundView.addGestureRecognizer(tap)
        
    }
    
    @objc func backgroundTapped() {
        if dismissesWhenBackgroundTapped {
            self.dismiss()
        }
    }
    
    func scalingAnimation() {
        UIView.animate(withDuration: animationDuration, animations: {
            self.transform = .identity
        }) {
            _ in
            self.transform = .identity
            self.inAnimationDidComplete()
        }
    }
    
    func opacityAnimation() {
        UIView.animate(withDuration: animationDuration, animations: {
            self.backgroundView.alpha = 1
            self.alpha = 1
        }, completion: {
            _ in
            self.inAnimationDidComplete()
        })
    }
    
    internal func prepareForInAnimation() {
        switch inAnimation {
        case .fromCenter:
            transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        case .opacity:
            alpha = 0
            backgroundView.alpha = 0
        default:
            break
        }
    }
    
    internal func _show() {
        guard let sv = superview else {
            //something wrong happened
            return
        }
        backgroundView.frame = sv.bounds
        sv.insertSubview(backgroundView, belowSubview: self)
        let finalPoint = CGPoint(x: sv.frame.width/2, y: sv.frame.height/2)
        
        if centered {
            center = finalPoint
        }
        switch inAnimation {
        case .fromCenter:
            scalingAnimation()
        case .opacity:
            opacityAnimation()
        case .none:
            inAnimationDidComplete()
            break
        }
        additionalInAnimations()
    }
    
    internal func inAnimationDidComplete() {
        // override if needed
    }
    internal func additionalInAnimations() {
        //override if needed
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let backgroundView: UIView
    let level: ModalViewLevel
    
    
    func setup() {
        fatalError("setup() has not been implemented")
    }
    
}


fileprivate class ModalViewContainer: UIView {
    
    typealias WindowContainerPair = (window:UIWindow, container:ModalViewContainer)
    
    static var containerWindowsDict = [ModalViewLevel:WindowContainerPair]()
    
    class func container(for level:ModalViewLevel) -> ModalViewContainer {
        if let pair = self.containerWindowsDict[level] {
            return pair.container
        }
        let modalViewContainer = ModalViewContainer(frame: UIScreen.main.bounds)
        
        let window = ModalWindow(frame: UIScreen.main.bounds)
        window.windowLevel = level
        window.isHidden = false
        window.addSubview(modalViewContainer)
        self.containerWindowsDict[level] = (window,modalViewContainer)
        
        return modalViewContainer
    }
    
    class func releaseContainer(for level:ModalViewLevel) {
        if let pair = self.containerWindowsDict[level] {
            pair.container.removeFromSuperview()
            self.containerWindowsDict.removeValue(forKey: level)
        }
    }
    
    class func prepareToShow(_ modalView:ModalView, level:ModalViewLevel) {
        let show = {
            let container = self.container(for: level)
            modalView.isHidden = true
            container.addSubview(modalView)
            if #available(iOS 13.0, *) {
                if let currentWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    container.window?.windowScene = currentWindowScene
                }
            }
        }
        if Thread.isMainThread {
            show()
        } else {
            DispatchQueue.main.sync {
                show()
            }
        }
    }
    class func cleanUpAfterHiding(_ modalView:ModalView) {
        let cleanUp = {
            let level = modalView.level
            let container = self.container(for: level)
            modalView.removeFromSuperview()
            if container.subviews.count == 0 {
                self.releaseContainer(for: level)
            }
        }
        if Thread.isMainThread {
            cleanUp()
        } else {
            DispatchQueue.main.sync {
                cleanUp()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        showModalView()
    }
    
    func showModalView() {
        for subview in subviews {
            if subview is ModalView {
                if subview.isHidden {
                    if let modalView = subview as? ModalView {
                        modalView.isHidden = false
                        modalView.prepareForInAnimation()
                        modalView._show()
                    }
                    subview.isHidden = false
                }
            }
        }
    }
    
}


fileprivate func RotationAngle(for orientation:UIInterfaceOrientation) -> CGFloat {
    var toRotate: CGFloat = 0
    switch orientation {
    case .landscapeLeft:
        toRotate = -.pi / 2
    case .landscapeRight:
        toRotate = .pi / 2
    case .portraitUpsideDown:
        toRotate = .pi
    default:
        break
    }
    return toRotate
}

fileprivate class ModalWindow: UIWindow {
    override init(frame: CGRect) {
        super.init(frame: frame)
        transform = .init(rotationAngle: RotationAngle(for: UIApplication.shared.statusBarOrientation))
        OrientationManager.shared.addOrientationObserver(self) {
            [weak self] (orientation) in
            guard let self = self else { return }
            let toRotate = RotationAngle(for: orientation)
            UIView.animate(withDuration: 0.8, animations: {
                self.transform = .init(rotationAngle: toRotate)
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if let view = hitTest(touch.location(in: self), with: event), view == self{

                self.isHidden = true
                for kv in ModalViewContainer.containerWindowsDict {
                    if kv.value.window == self {
                        ModalViewContainer.containerWindowsDict.removeValue(forKey: kv.key)
                        return
                    }
                }
            }
        }
        
    }
}

class OrientationManager: NSObject {
    
    static let shared = OrientationManager()
    
    private var orientationObservers = [UUID : (UIInterfaceOrientation) -> Void]()
    
    var notificationToken: NSObjectProtocol?
    private override init() {
        super.init()
        notificationToken = NotificationCenter.default.addObserver(forName: UIApplication.didChangeStatusBarOrientationNotification,
                                               object: nil,
                                               queue: .main) {
                                                [weak self] _ in
                                                self?.newOrientationObserved(UIApplication.shared.statusBarOrientation)
                                                
        }
    }
    
    deinit {
        if let notificationToken = notificationToken {
            NotificationCenter.default.removeObserver(notificationToken)
        }
    }
    
    private func newOrientationObserved(_ orientation:UIInterfaceOrientation) {
        for observation in orientationObservers {
            observation.value(orientation)
        }
    }
    
    public func addOrientationObserver (
        _ observer: AnyObject,
        closure: @escaping (UIInterfaceOrientation) -> Void) {
        var id: UUID!
        while id == nil {
            let newID = UUID()
            if orientationObservers[newID] == nil {
                id = newID
            }
        }
        orientationObservers[id] = {
            [weak self, weak observer] newOrientation in
            if observer == nil {
                self?.orientationObservers.removeValue(forKey: id)
                return
            }
            closure(newOrientation)
        }
        return
    }
}
