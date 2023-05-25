//
//  EnRouteDestinationView.swift
//  More
//
//  Created by Luko Gjenero on 20/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import Mapbox

@IBDesignable
class EnRouteDestinationView: LoadableView {

    @IBOutlet private weak var time: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var thickSeparator: UIView!
    @IBOutlet private weak var directionsTop: UILabel!
    @IBOutlet private weak var directionsBottom: UILabel!
    @IBOutlet private weak var leftPadding: NSLayoutConstraint!
    @IBOutlet private weak var button: UIButton!
    
    private var maxWidth: CGFloat = 240
    
    override func setupNib() {
        super.setupNib()
        
        thickSeparator.layer.cornerRadius = 2
        collapseAnimation()
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dragContent(sender:)))
        button.addGestureRecognizer(pan)
    }
    
    @IBAction func buttonTouch(_ sender: Any) {
        if leftPadding.constant >= maxWidth {
            collapse()
        } else {
            expand()
        }
    }
    
    func setup(time: TimeInterval, distance: CLLocationDistance, instructions: String) {
        self.time.text = "\(Int(time.toMinutes()))"
        
        // for now not displaying distance
        // directionsTop.text = "\(Int(distance.metersToFeet())) ft"
        
        directionsTop.text = "Meet at"
        directionsBottom.text = instructions
        
        var width = CGFloat(40)
        let constraintRect = CGSize(width: 200, height: CGFloat.greatestFiniteMagnitude)
        
        if let text = directionsTop.text, let font = directionsTop.font {
            let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil)
            let directionsWidth = 40 + min(200, ceil(boundingBox.width))
            if width < directionsWidth {
                width = directionsWidth
            }
        }
        
        if let text = directionsBottom.text, let font = directionsBottom.font {
            let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil)
            let directionsWidth = 40 + min(200, ceil(boundingBox.width))
            if width < directionsWidth {
                width = directionsWidth
            }
        }
        
        maxWidth = width
        if leftPadding.constant > 20 {
            leftPadding.constant = maxWidth
            superview?.layoutIfNeeded()
        }
    }
    
    // MARK: - animations
    
    func collapse(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.collapseAnimation()
                self?.superview?.layoutIfNeeded()
            }
        } else {
            collapseAnimation()
        }
    }
    
    private func collapseAnimation() {
        leftPadding.constant = 20
        separatarTrasform(0)
        
        
        // thinSeparator.alpha = 0
        // thickSeparator.alpha = 1
    }
    
    func expand(animated: Bool = true) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.expandAnimation()
            self?.superview?.layoutIfNeeded()
        }
    }
    
    private func expandAnimation() {
        leftPadding.constant = maxWidth
        separatarTrasform(1)
        
        // thinSeparator.alpha = 1
        // thickSeparator.alpha = 0
    }
    
    private func separatarTrasform(_ progress: CGFloat) {
        
        if progress <= 0 {
            thickSeparator.layer.transform = CATransform3DIdentity
            return
        }
        
        let clampedProgress = min(progress, 1)
        
        let scaleX = 1 - 0.75 * clampedProgress
        let scaleY = bounds.height / (bounds.height - 36 * clampedProgress)
        let translateX = -11 * clampedProgress
        
        var transform = CATransform3DMakeScale(scaleX, scaleY, 1)
        transform = CATransform3DTranslate(transform, translateX, 0, 0)
        thickSeparator.layer.transform = transform
    }
    
    
    // MARK: - drag
    
    private var dragStart: CGPoint = .zero
    private var widthStart: CGFloat = 0
    
    @objc private func dragContent(sender: UIPanGestureRecognizer) {
        
        guard layer.animationKeys() == nil else { return }
        
        let point = sender.location(in: self)
        let offset = point.x - dragStart.x 
        switch sender.state {
        case .began:
            dragStart = point
            widthStart = leftPadding.constant
        case .changed:
            moveTop(to: offset + widthStart)
        case .cancelled, .ended, .failed:
            settleTop(to: offset + widthStart)
        default: ()
        }
    }
    
    private func moveTop(to offset: CGFloat) {
        let clampedWidth = min(maxWidth, max(20, offset))
        leftPadding.constant = clampedWidth
        
        let progress = (clampedWidth - 20) / (maxWidth - 20)
        separatarTrasform(progress)
        
        superview?.layoutIfNeeded()
    }
    
    private func settleTop(to offset: CGFloat) {
        let left = abs(offset - 20)
        let right = abs(maxWidth - offset)
        
        if left < right {
            collapse()
        } else {
            expand()
        }
    }
}
