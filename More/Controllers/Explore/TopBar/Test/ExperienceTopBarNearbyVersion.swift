//
//  ExperienceTopBarNearbyVersion.swift
//  More
//
//  Created by Luko Gjenero on 27/01/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

// MARK: - colors

private let peakColors: [CGColor] = [
    UIColor(red: 255, green: 11, blue: 133).cgColor,
    UIColor(red: 255, green: 126, blue: 0).cgColor,
]

private let middleColors: [CGColor] = [
    UIColor(red: 178, green: 156, blue: 255).cgColor,
    UIColor(red: 124, green: 188, blue: 255).cgColor,
]

private let offColors: [CGColor] = [
    UIColor.blueGrey.cgColor,
    UIColor.blueGrey.cgColor,
]

// MARK: - UI

@IBDesignable
class ExperienceTopBarNearbyVersion: LoadableView {

    @IBOutlet weak var walking: UIView!
    @IBOutlet weak var label: HorizontalGradientLabel!
    @IBOutlet weak var walkLabel: UILabel!
    
    override func setupNib() {
        super.setupNib()
        label.gradientColors = offColors
        
        NotificationCenter.default.addObserver(self, selector: #selector(toForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        label.text = "36 people"
        walking.isHidden = false
        walkLabel.text = "are exploring near you"
    }
    
    func setup() {
        let count = max(4, ExperienceTopBarNearbyVersionLogic.getNearbyPeopleCount())
        let bucket = ExperienceTopBarNearbyVersionLogic.bucket(for: count)
        
        walking.clearAnimations()
        switch bucket {
        case .peak:
            label.gradientColors = peakColors
            walking.addFireAnimation()
        case .middle:
            label.gradientColors = middleColors
            walking.addPurpleWalkingAnimation()
        default:
            label.gradientColors = offColors
            walking.addWalkingAnimation()
        }
        
        label.text = "\(Formatting.formatPeople(count)) people"
        walkLabel.text = "are exploring near you"
        walking.lottieView?.play()
    }
    
    @objc private func toForeground() {
        walking.lottieView?.play()
    }
}

// MARK: - icons/animations

private extension UIView {
    
    func clearAnimations() {
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    func addFireAnimation() {
        
        let image = UIImageView(image: UIImage(named: "nearby-on-fire"))
        image.contentMode = .center
        image.backgroundColor = .clear
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -2).isActive = true
        image.widthAnchor.constraint(equalToConstant: 15).isActive = true
        image.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
}

// MARK: - Logic

fileprivate class ExperienceTopBarNearbyVersionLogic {
    
    static let mondaySchedule: [Int]    = [1, 2, 2, 2, 2, 2, 2, 1, 1, 2, 2, 1, 0, 1, 2, 2, 2, 1, 0, 0, 0, 1, 1, 1]
    static let tuesdaySchedule: [Int]   = [1, 2, 2, 2, 2, 2, 2, 1, 1, 2, 2, 1, 0, 1, 2, 2, 2, 1, 0, 0, 0, 1, 1, 1]
    static let wednesdaySchedule: [Int] = [1, 2, 2, 2, 2, 2, 2, 1, 1, 2, 2, 1, 0, 1, 2, 2, 2, 1, 0, 0, 0, 1, 1, 1]
    static let thursdaySchedule: [Int]  = [1, 2, 2, 2, 2, 2, 2, 1, 1, 2, 2, 1, 0, 1, 2, 2, 2, 1, 0, 0, 0, 0, 0, 1]
    static let fridaySchedule: [Int]    = [1, 1, 2, 2, 2, 2, 2, 1, 1, 2, 2, 1, 0, 0, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0]
    static let saturdaySchedule: [Int]  = [0, 0, 1, 1, 2, 2, 2, 2, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0]
    static let sundaySchedule: [Int]    = [0, 0, 0, 1, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 2, 2, 2]
    
    static let peak: (Int, Int)   = (601, 1391)
    static let midlle: (Int, Int) = (381, 600)
    static let off: (Int, Int)    = (28, 380)

    static var lastCount: Int = -1
    static var lastCountTime: TimeInterval = 0
    
    enum Bucket: Int {
        case off = 2
        case middle = 1
        case peak = 0
    }
    
    class func getNearbyPeopleCount() -> Int {
        let now = Date()
        
        // if the change is within 5 mins just oscilate
        if now.timeIntervalSince1970 < lastCountTime + 300 {
            let diff = Int(arc4random_uniform(11)) - 5
            lastCount += diff
            lastCountTime = now.timeIntervalSince1970
            return lastCount
        }

        let schedule = [
            sundaySchedule,
            mondaySchedule,
            tuesdaySchedule,
            wednesdaySchedule,
            thursdaySchedule,
            fridaySchedule,
            saturdaySchedule
        ]
        
        // weekdays start with 1 = Sunday
        let index = Calendar.current.component(.weekday, from: now) - 1
        let todaySchedule = schedule[index]
        let hour = Calendar.current.component(.hour, from: now)
        let phase = todaySchedule[hour]
        
        switch phase {
        case 0:
            lastCount = peak.0 + Int(arc4random_uniform(UInt32(peak.1 - peak.0)))
        case 1:
            lastCount = midlle.0 + Int(arc4random_uniform(UInt32(midlle.1 - midlle.0)))
        default:
            lastCount = off.0 + Int(arc4random_uniform(UInt32(off.1 - off.0)))
        }
        lastCountTime = now.timeIntervalSince1970
        
        return lastCount
    }
    
    class func bucket(for count: Int) -> Bucket {
        if count > 600 {
            return .peak
        }
        if count > 380 {
            return .middle
        }
        return .off
    }
}
