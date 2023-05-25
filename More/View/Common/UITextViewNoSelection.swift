//
//  UITextViewNoSelection.swift
//  More
//
//  Created by Luko Gjenero on 27/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class UITextViewNoSelection: UITextViewNoPadding {

    override public var selectedTextRange: UITextRange? {
        get {
            return nil
        }
        set { }
    }
}
