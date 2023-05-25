//
//  UIViewController+Alerts.swift
//  More
//
//  Created by Luko Gjenero on 25/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import SwiftMessages

extension UIViewController {

    func errorAlert(text: String) {
        testAndDismissAlert(text: text, color: UIColor(red: 164, green: 2, blue: 5))
    }
    
    func warningAlert(text: String) {
        testAndDismissAlert(text: text, color: UIColor(red: 97, green: 145, blue: 255))
    }
    
    private func testAndDismissAlert(text: String, color: UIColor) {
        let view: AlertTextAndDismissMessageView = try! SwiftMessages.viewFromNib()
        SwiftMessages.defaultConfig.presentationContext = .window(windowLevel: .normal)
        view.configureTheme(backgroundColor: color, foregroundColor: .clear)
        view.button?.backgroundColor = .clear
        view.backgroundColor = color
        
        view.content.setup(message: text)
        view.buttonTapHandler = { _ in
            SwiftMessages.hide()
        }
        
        SwiftMessages.show(view: view)
    }

}
