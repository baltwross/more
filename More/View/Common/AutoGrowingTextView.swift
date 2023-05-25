//
//  AutoGrowingTextView.swift
//  More
//
//  Created by Luko Gjenero on 24/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class AutoGrowingTextView: PlaceholderTextView {

    weak var heightConstraint: NSLayoutConstraint?
    weak var minHeightConstraint: NSLayoutConstraint?
    weak var maxHeightConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        associateConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(autogrowing_textChanged), name: UITextView.textDidChangeNotification, object: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func associateConstraints() {
        for constraint in self.constraints {
            if constraint.firstAttribute == NSLayoutConstraint.Attribute.height {
                if constraint.relation == NSLayoutConstraint.Relation.equal {
                    self.heightConstraint = constraint
                } else if constraint.relation == NSLayoutConstraint.Relation.lessThanOrEqual {
                    self.maxHeightConstraint = constraint
                } else if constraint.relation == NSLayoutConstraint.Relation.greaterThanOrEqual {
                    self.minHeightConstraint = constraint
                }
            }
        }
    }
    
    // MARK: - text
    
    override var text: String! {
        didSet {
            self.autogrowing_textChanged()
        }
    }
    
    @objc private func autogrowing_textChanged() {
        guard heightConstraint != nil else { return }
        
        if self.handleLayoutWithAutoLayouts() {
            // UIView.animate(withDuration: 0.2, animations: {
                self.layoutIfNeeded()
            // })
        }
    }
    
    // MARK: lay-out
    
    fileprivate func handleLayoutWithAutoLayouts() -> Bool  {
        var sizeThatShouldFitTheContent = CGSize.zero
        if let text = text, text.count > 0 {
            sizeThatShouldFitTheContent = sizeThatFits(CGSize(width: frame.width, height: 0))
        } else {
            sizeThatShouldFitTheContent = placeholderLabel.sizeThatFits(CGSize(width: frame.width, height: 0))
        }
        if let minHeightConstraint = minHeightConstraint {
            sizeThatShouldFitTheContent.height = max(sizeThatShouldFitTheContent.height, minHeightConstraint.constant)
        }
        if let maxHeightConstraint = maxHeightConstraint {
            isScrollEnabled = sizeThatShouldFitTheContent.height > maxHeightConstraint.constant
            sizeThatShouldFitTheContent.height = min(sizeThatShouldFitTheContent.height, maxHeightConstraint.constant)
        }
        if let heightConstraint = self.heightConstraint {
            if abs(heightConstraint.constant - sizeThatShouldFitTheContent.height) > 1e-15 {
                heightConstraint.constant = sizeThatShouldFitTheContent.height
                return true
            }
        }
        return false
    }
    
}
