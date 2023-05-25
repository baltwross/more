//
//  Helper.swift
//  More
//
//  Created by Anirudh Bandi on 6/12/18.
//  Copyright © 2018 Anirudh Bandi. All rights reserved.
//

import Foundation

import UIKit
import CoreLocation

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension String {
    static func format(phoneNumber: String, shouldRemoveLastDigit: Bool = false) -> String {
        guard !phoneNumber.isEmpty else { return "" }
        guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
        let r = NSString(string: phoneNumber).range(of: phoneNumber)
        var number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: "")
        
        if number.count > 10 {
            let tenthDigitIndex = number.index(number.startIndex, offsetBy: 10)
            number = String(number[number.startIndex..<tenthDigitIndex])
        }
        
        if shouldRemoveLastDigit {
            let end = number.index(number.startIndex, offsetBy: number.count-1)
            number = String(number[number.startIndex..<end])
        }
        
        if number.count < 7 {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "($1) $2", options: .regularExpression, range: range)
            
        } else {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: range)
        }
        
        return number
    }
    
    func firstIndex(of substring: String) -> Int? {
        var index = 0
        for char in self {
            
            if index + substring.count >= count {
                break
            }
            
            if substring.first == char {
                
                let startOfFoundCharacter = self.index(startIndex, offsetBy: index)
                let lengthOfFoundCharacter = self.index(startIndex, offsetBy: (substring.count + index))
                let range = startOfFoundCharacter..<lengthOfFoundCharacter
                
                if self[range] == substring {
                    return index
                }
            }
            index += 1
        }
        return nil
    }
}

extension String {
    
    func substring(to : Int) -> String? {
        if (to >= count) {
            return nil
        }
        let toIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[..<toIndex])
    }
    
    func substring(from : Int) -> String? {
        if (from >= count) {
            return nil
        }
        let fromIndex = self.index(self.startIndex, offsetBy: from)
        return String(self[fromIndex...])
    }
    
    func size(font: UIFont) -> CGSize {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil)
        
        return CGSize(width: ceil(boundingBox.width), height: ceil(boundingBox.height))
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func truncatedText(lineWidths: [CGFloat], withFont font: UIFont) -> String {
        
        var text = self
        var lines: [String] = []
        for lineWidth in lineWidths {
            let textContainer = NSTextContainer(size: CGSize(width: lineWidth, height: CGFloat.greatestFiniteMagnitude))
            textContainer.maximumNumberOfLines = 1
            textContainer.lineBreakMode = NSLineBreakMode.byTruncatingTail
            
            let layoutManager = NSLayoutManager()
            layoutManager.addTextContainer(textContainer)
            
            let textStorage = NSTextStorage(attributedString: NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : font]))
            
            textStorage.addLayoutManager(layoutManager)
            
            var glyphRange = NSRange()
            layoutManager.glyphRange(forCharacterRange: NSMakeRange(0, text.count), actualCharacterRange: &glyphRange)
            
            var idx = text.count - 1
            layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
                let lineFragmentTruncatedGlyphIndex = glyphRange.location
                if lineFragmentTruncatedGlyphIndex != NSNotFound {
                    idx = layoutManager.truncatedGlyphRange(inLineFragmentForGlyphAt: lineFragmentTruncatedGlyphIndex).location
                }
                stop.pointee = true
            }
            
            let line = String(text.prefix(idx))
            lines.append(line)
            
            text = text.substring(from: idx) ?? ""
            
            if text.count == 0 {
                break
            }
        }
        
        return lines.joined(separator: "")
    }
}

extension NSAttributedString {
    
    func size() -> CGSize {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return CGSize(width: ceil(boundingBox.width), height: ceil(boundingBox.height))
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
}

func dispatchOnMainThread(_ block: @escaping ()->()) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async(execute: block)
    }
}

extension Float {
    func string(_ fractionDigits:Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension Double {
    func string(_ fractionDigits:Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
    
}
