//
//  Utils.swift
//  Log
//
//  Created by kaho on 03/04/2020.
//  Copyright © 2020 kaho. All rights reserved.
//

import Foundation
import UIKit

internal extension CGRect{
    
    var x: CGFloat {
        get { return minX }
        set { origin.x = newValue }
    }
    
    var y: CGFloat {
        get { return minY }
        set { origin.y = newValue }
    }
    
    var centerX: CGFloat {
        get { return midX }
        set { origin.x = newValue - width/2 }
    }
    
    var centerY: CGFloat {
        get { return midY }
        set { origin.y = newValue - height/2 }
    }
    
    var end: CGPoint {
        get {
            return CGPoint(x: x + width, y: y + height)
        }
        set {
            width = (newValue.x - x) >= 0 ? (newValue.x - x) : 0
            height = (newValue.y - y) >= 0 ? (newValue.y - y) : 0
        }
    }
    
    var width: CGFloat {
        get { return size.width }
        set { size.width = newValue }
    }
    
    var height: CGFloat {
        get { return size.height }
        set { size.height = newValue }
    }
    
    var left: CGFloat {
        get { return minX }
        set { x = newValue }
    }
    
    var right: CGFloat {
        get { return maxX}
        set { x = newValue - width}
    }
    
    var top: CGFloat {
        get { return minY }
        set { y = newValue }
    }
    
    var bottom: CGFloat {
        get { return maxY }
        set { y = newValue - height }
    }
    
    //Corner points
    //TODO: setters
    var topLeft: CGPoint {
        get { CGPoint(left, top)  }
    }
    
    var topRight: CGPoint {
        get { CGPoint(right, top) }
    }
    
    var bottomLeft: CGPoint {
        get { CGPoint(left, bottom) }
    }
    
    var bottomRight: CGPoint {
        get { CGPoint(right, bottom) }
    }
    
}


internal extension UIView {
    
    var x: CGFloat {
        get { return frame.x }
        set { self.frame.x = newValue }
    }
    
    var y: CGFloat {
        get { return frame.y }
        set { self.frame.y = newValue }
    }
    
    var centerX: CGFloat {
        get { return frame.centerX }
        set { frame.centerX = newValue }
    }
    
    var centerY: CGFloat {
        get { return frame.centerY }
        set { frame.centerY = newValue }
    }
    
    var end: CGPoint {
        get { return frame.end }
        set { frame.end = newValue }
    }
    
    var size: CGSize {
        get { return frame.size }
        set { frame.size = newValue }
    }
    
    var width: CGFloat {
        get { return frame.width }
        set { frame.width = newValue }
    }
    
    var height: CGFloat {
        get { return frame.height }
        set { frame.height = newValue }
    }
    
    var left: CGFloat {
        get { return x }
        set { x = newValue }
    }
    
    var right: CGFloat {
        get { return frame.right}
        set { x = newValue - width}
    }
    
    var top: CGFloat {
        get { return y }
        set { y = newValue }
    }
    
    var bottom: CGFloat {
        get { return frame.bottom }
        set { y = newValue - height }
    }
    
}


internal extension CGFloat {
    func clamp(_ a: CGFloat, _ b: CGFloat) -> CGFloat {
        return self < a ? a : (self > b ? b : self)
    }
}

internal extension CGPoint {
    init(_ x:CGFloat,_ y:CGFloat) {
        self.init(x:x,y:y)
    }
    func translate(_ dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: self.x+dx, y: self.y+dy)
    }
    
    func transform(_ t: CGAffineTransform) -> CGPoint {
        return self.applying(t)
    }
    
    func distance(_ b: CGPoint) -> CGFloat {
        return sqrt(pow(self.x-b.x, 2)+pow(self.y-b.y, 2))
    }
}
func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}
func += (left: inout CGPoint, right: CGPoint) {
    left.x += right.x
    left.y += right.y
}
func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}
func /(left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x/right, y: left.y/right)
}
func *(left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x*right, y: left.y*right)
}
func *(left: CGFloat, right: CGPoint) -> CGPoint {
    return right * left
}
func *(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x*right.x, y: left.y*right.y)
}
prefix func -(point: CGPoint) -> CGPoint {
    return CGPoint.zero - point
}
func /(left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width/right, height: left.height/right)
}
func *(left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width*right, height: left.height*right)
}
func *(left: CGFloat, right: CGSize) -> CGSize {
    return CGSize(width: right.width*left, height: right.height*left)
}
func -(left: CGPoint, right: CGSize) -> CGPoint {
    return CGPoint(x: left.x - right.width, y: left.y - right.height)
}

func *(left: CGPoint, right: CGSize) -> CGPoint {
    return CGPoint(x: left.x * right.width, y: left.y * right.height)
}

func *(left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: right.width*left.width, height: right.height*left.height)
}


func *(left: CGRect, right: CGRect) -> CGRect {
    return CGRect(left.x * right.x,
                  left.y * right.y,
                  left.width * right.width,
                  left.height * right.height)
}

func *(left: CGRect, right: CGSize) -> CGRect {
    return CGRect(left.x * right.width,
                  left.y * right.height,
                  left.width * right.width,
                  left.height * right.height)
}


prefix func -(inset: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsets(top: -inset.top, left: -inset.left, bottom: -inset.bottom, right: -inset.right)
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    var bounds: CGRect {
        return CGRect(origin: .zero, size: size)
    }
    init(center: CGPoint, size: CGSize) {
        self.init(origin: center - size / 2, size: size)
    }
    init(_ origin:CGPoint,_ size:CGSize) {
        self.init(origin:origin,size:size)
    }
    init(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat) {
        self.init(x:x,y:y,width:width,height:height)
    }
}



extension CGSize{
    init(_ width:CGFloat,_ height:CGFloat) {
        self.init(width:width,height:height)
    }
}

extension CGVector {
    init(_ dx:CGFloat,_ dy:CGFloat) {
        self.init(dx:dx,dy:dy)
    }
}

#if os(iOS)

extension UIEdgeInsets {
    init(_ top:CGFloat,_ left:CGFloat,_ bottom:CGFloat,_ right:CGFloat) {
        self.init(top:top,left:left,bottom:bottom,right:right)
    }
}

#endif

internal extension UIColor {
    
    typealias Hex32 = UInt32
    /**
     - parameters:
        - hexRGBA: 0xRRGGBBAA
     */
    
    convenience init(hexRGBA:Hex32) {
        self.init(red: CGFloat((hexRGBA >> 24) % 256) / 255.0,
                  green: CGFloat((hexRGBA >> 16) % 256) / 255.0,
                  blue: CGFloat((hexRGBA >> 8) % 256) / 255.0,
                  alpha: CGFloat(hexRGBA % 256) / 255.0)
    }
    
    /**
     - parameters:
     - hexARGB: 0xAARRGGBB
     */
    
    convenience init(hexARGB:Hex32) {
        self.init(red: CGFloat((hexARGB >> 16) % 256) / 255.0,
                  green: CGFloat((hexARGB >> 8) % 256) / 255.0,
                  blue: CGFloat(hexARGB % 256) / 255.0,
                  alpha: CGFloat((hexARGB >> 24) % 256) / 255.0)
    }
    
    /**
     - description
        use this initializer when needed color's alpha is 1, for example
        - UIColor(hexRGB:0x89ABCD) is the same as UIColor(hexRGBA:0x89ABCDFF)
     
     - parameters
        - hexRGB: 0xRRGGBB
     
     */
    convenience init(hexRGB:Hex32) {
        self.init(hexRGBA: hexRGB<<8 + 0xff)
    }
    
    /**
     - description
        use this initializer when needed color's alpha is 1.
     */
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(r: r, g: g, b: b, a: 1.0)
    }
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    
    static func randomColor() -> UIColor {
        return UIColor(r: CGFloat(arc4random_uniform(255)), g: CGFloat(arc4random_uniform(255))
            , b: CGFloat(arc4random_uniform(255)))
    }
    
    convenience init?(rgbaString:String) {
        let hexString = rgbaString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner            = Scanner(string: rgbaString)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        if !scanner.scanHexInt32(&color) {
            return nil
        }
        let mask = 0x000000FF
        let r = Int(color >> 24) & mask
        let g = Int(color >> 16) & mask
        let b = Int(color >> 8) & mask
        let a = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        let alpha = CGFloat(a) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    convenience init?(rgbString:String) {
        let hexString = rgbString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner            = Scanner(string: rgbString)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        if !scanner.scanHexInt32(&color) {
            return nil
        }
        let mask = 0xFF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    var rgbaHex: Hex32 {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = UInt32(fRed * 255.0)
            let iGreen = UInt32(fGreen * 255.0)
            let iBlue = UInt32(fBlue * 255.0)
            let iAlpha = UInt32(fAlpha * 255.0)
            let rgba:UInt32 = (iRed << 24) + (iGreen << 16) + (iBlue << 8) + iAlpha
            return rgba
        } else {
            // Could not extract RGBA components:
            return 0
        }
    }
    
    var luminance: CGFloat {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: nil) {
            //fomular: Y=0.2126R+0.7152G+0.0722B
            return fRed * 0.2126 + fGreen * 0.7152 + fBlue * 0.0722
        } else {
            // Could not extract RGBA components:
            return 0
        }
    }
}
