//
//  UIImage+utils.swift
//  More
//
//  Created by Luko Gjenero on 15/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

extension UIImage {

    class func onePixelImage(color: UIColor) -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast
        let context = CGContext(data: nil, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clear(CGRect(x: 0, y: 0, width: 1, height: 1))
        context.setBlendMode(.clear)
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        
        let cgImage = context.makeImage()
        let image = UIImage.init(cgImage: cgImage!)
        return image
    }
    
    class func gradientImage(size: CGSize, start: CGPoint, end: CGPoint, startColor: UIColor, endColor: UIColor) -> UIImage? {
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        let colors = [startColor.cgColor, endColor.cgColor]
        let colorLocations: [CGFloat] = [0, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)!
        context!.drawLinearGradient(gradient,
                                    start: start,
                                    end: end,
                                    options: [])
        
        let cgImage = context!.makeImage()
        let image = UIImage.init(cgImage: cgImage!)
        return image
        
    }
    
    func imageWithAlignmentRectInsets(_ insets: UIEdgeInsets) -> UIImage? {
        
        let width = size.width + insets.left + insets.right
        let height = size.height + insets.top + insets.bottom
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, UIScreen.main.scale)
        
        draw(in: CGRect(x: insets.left, y: insets.top, width: size.width, height: size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    class func snapshotImage(from view: UIView, afterScreenUpdates: Bool = false) -> UIImage? {
        
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { _ in view.drawHierarchy(in: view.bounds, afterScreenUpdates: true) }
        
        return image
    }
    
    func resizedImage(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(origin: .zero, size: size))
        let resizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
}

// MARK: - placeholders

extension UIImage {
    
    class func profilePlaceholder() -> UIImage? {
        let width = UIScreen.main.bounds.width
        return gradientImage(size: CGSize(width: width, height: width), start: .zero, end: CGPoint(x: width, y: width), startColor: UIColor(rgb: 0xdadde3), endColor: UIColor(rgb: 0xa7adb7))
    }
    
    class func signalPlaceholder() -> UIImage? {
        return onePixelImage(color: UIColor(rgb: 0xdadde3))
    }
    
    class func imageSearchPlaceholder() -> UIImage? {
        return onePixelImage(color: UIColor(rgb: 0xf1f2f4))
    }
    
    class func signalCreateThumbPlaceholder() -> UIImage? {
        return onePixelImage(color: UIColor(rgb: 0xf1f2f4))
    }
    
    class func expandedSignalPlaceholder() -> UIImage? {
        let width = UIScreen.main.bounds.width
        return gradientImage(size: CGSize(width: width, height: width), start: .zero, end: CGPoint(x: 0, y: width), startColor: UIColor(rgb: 0xa7adb7), endColor: UIColor(rgb: 0xdadde3))
    }
    
    class func profileThumbPlaceholder() -> UIImage? {
        return onePixelImage(color: UIColor(rgb: 0xdadde3))
    }
}
