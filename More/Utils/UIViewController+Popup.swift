//
//  UIViewController+Popup.swift
//  More
//
//  Created by Luko Gjenero on 05/05/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

private let popupTag = 1234321

extension UIViewController {
       
    func present(popup: UIView, insets: UIEdgeInsets = UIEdgeInsets(top: 150, left: 25, bottom: -1, right: 25)) {
        
        let popupView = UIView()
        popupView.translatesAutoresizingMaskIntoConstraints = false
        popupView.backgroundColor = UIColor.charcoalGrey.withAlphaComponent(0.4)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        popupView.addGestureRecognizer(tap)
        
        popupView.addSubview(popup)
        popup.topAnchor.constraint(equalTo: popupView.topAnchor, constant: insets.top).isActive = true
        popup.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: insets.left).isActive = true
        popup.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -insets.right).isActive = true
        if insets.bottom != -1 {
            popup.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -insets.bottom).isActive = true
        }
        
        view.addSubview(popupView)
        popupView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        popupView.tag = popupTag
        popupView.alpha = 0
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak popupView] in
                popupView?.alpha = 1
            },
            completion: { _ in
                // nop
            })
    }
    
    @objc func dismissPopup() {
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.view.viewWithTag(popupTag)?.alpha = 0
            },
            completion: { [weak self] _ in
                self?.view.viewWithTag(popupTag)?.removeFromSuperview()
            })
    }
    
}
