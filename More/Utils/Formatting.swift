//
//  Formatting.swift
//  More
//
//  Created by Luko Gjenero on 10/01/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

class Formatting {
    
    class func formatFeetAway(_ feet: Double) -> String {
        
        var text = "?"
        let format = NumberFormatter()
        format.groupingSeparator = ","
        format.decimalSeparator = "."
        format.numberStyle = .decimal
        format.usesGroupingSeparator = true
        if feet <= 5000 {
            format.maximumFractionDigits = 0
            text = format.string(from: NSNumber(value: feet)) ?? "?"
            text += " ft"
        } else {
            format.maximumFractionDigits = 2
            format.minimumFractionDigits = 2
            text = format.string(for: feet.feetToMeters().metersToMiles()) ?? "?"
            text += " mi"
        }
        return text
    }
    
    class func formatPeople(_ people: Int) -> String {
        
        var text = "?"
        let format = NumberFormatter()
        format.groupingSeparator = ","
        format.numberStyle = .decimal
        format.usesGroupingSeparator = true
        text = format.string(for: people) ?? "?"
        return text
    }
    
    class func formatLikesAndShares(_ number: Int, asShortWithDecimals decimals: Int, threshold: Int) -> String {
        let s: Int = (number < 0) ? -1 : (number > 0) ? 1 : 0
        let sign: String = s == -1 ? "-" : ""
        let mutableNumber = abs(number)
        if mutableNumber < max(1000, threshold) {
            return "\(sign)\(mutableNumber)"
        }
        let exp = Int(log(Double(mutableNumber)) / log(1000))
        let units = ["k", "M", "G", "T", "P", "E"]
        var decimalsMutable = decimals
        if decimalsMutable < 0 {
            decimalsMutable = 0
        }
        let format = "%@%.\(decimalsMutable)f%@"
        return String(format: format, sign, Double(mutableNumber) / pow(1000, Double(exp)), units[exp - 1])
    }

}
