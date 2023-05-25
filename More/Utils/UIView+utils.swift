//
//  UIView+utils.swift
//  More
//
//  Created by Luko Gjenero on 19/07/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

extension UIView {

    class func snapshotView(from view: UIView, afterScreenUpdates: Bool = false) -> UIView? {
        return view.snapshotView(afterScreenUpdates: afterScreenUpdates)
    }

}
