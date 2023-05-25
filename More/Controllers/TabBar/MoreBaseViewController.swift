//
//  MoreBaseViewController.swift
//  More
//
//  Created by Luko Gjenero on 15/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class MoreBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = false
    }
    
    // MARK: - navigation bar content
    
    private weak var leftButton: UIButton?
    private weak var rightButton: UIButton?
    
    var leftTap: (()->())?
    var rightTap: (()->())?
    
    func setLeftIcon(_ icon: UIImage, selected: UIImage? = nil) {
        let leftButton = UIButton(type: .custom)
        leftButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        leftButton.setImage(icon, for: .normal)
        leftButton.setImage(selected, for: .selected)
        leftButton.addTarget(self, action: #selector(leftTouch(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        self.leftButton = leftButton
    }
    
    func setRightIcon(_ icon: UIImage, selected: UIImage? = nil) {
        let rightButton = UIButton(type: .custom)
        rightButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        rightButton.setImage(icon, for: .normal)
        rightButton.setImage(selected, for: .selected)
        rightButton.addTarget(self, action: #selector(rightTouch(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        self.rightButton = rightButton
    }
    
    func setLeftContent(_ content: UIView) {
        content.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(leftTouch(_:)))
        tap.cancelsTouchesInView = true
        content.addGestureRecognizer(tap)
        
        let button = UIBarButtonItem(customView: content)
        navigationItem.leftBarButtonItem = button
    }
    
    var leftContent: UIView? {
        return navigationItem.leftBarButtonItem?.customView
    }
    
    func setRightContent(_ content: UIView) {
        content.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(rightTouch(_:)))
        tap.cancelsTouchesInView = true
        content.addGestureRecognizer(tap)
        
        let button = UIBarButtonItem(customView: content)
        navigationItem.rightBarButtonItem = button
    }
    
    var rightContent: UIView? {
        return navigationItem.leftBarButtonItem?.customView
    }
    
    func removeLeft() {
        navigationItem.leftBarButtonItem = nil
        leftTap = nil
    }
    
    func removeRight() {
        navigationItem.rightBarButtonItem = nil
        rightTap = nil
    }
    
    func setTitle(_ title: String) {
        navigationItem.title = title
    }
    
    var leftSelected: Bool {
        get {
            return leftButton?.isSelected ?? false
        }
        set {
            leftButton?.isSelected = newValue
        }
    }
    
    var rightSelected: Bool {
        get {
            return rightButton?.isSelected ?? false
        }
        set {
            rightButton?.isSelected = newValue
        }
    }
    
    @IBAction private func leftTouch(_ sender: Any) {
        leftTap?()
    }
    
    @IBAction private func rightTouch(_ sender: Any) {
        rightTap?()
    }
    
}
