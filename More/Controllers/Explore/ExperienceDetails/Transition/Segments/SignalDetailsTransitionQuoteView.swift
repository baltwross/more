//
//  SignalDetailsTransitionQuoteView.swift
//  More
//
//  Created by Luko Gjenero on 18/07/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class SignalDetailsTransitionQuoteView: LoadableView {

    @IBOutlet private weak var typeLabel: HorizontalGradientLabel!
    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var textView: UILabel!
    
    class private func size(type: String, title: String?, text: String, in size: CGSize) -> CGSize {
        
        var height = CGFloat(93)
        
        // type
        let font = UIFont(name: "Gotham-Black", size: 9) ?? UIFont.systemFont(ofSize: 9)
        height += type.uppercased().height(withConstrainedWidth: 1024, font: font)
        
        // title & text
        if let title = title {
            var font = UIFont(name: "Gotham-Black", size: 25) ?? UIFont.systemFont(ofSize: 25)
            height += title.height(withConstrainedWidth: size.width - 56, font: font)
            font = UIFont(name: "Avenir-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
            height += title.height(withConstrainedWidth: size.width - 56, font: font)
        } else {
            let font = UIFont(name: "Gotham-Black", size: 16) ?? UIFont.systemFont(ofSize: 16)
            height += text.height(withConstrainedWidth: size.width - 56, font: font)
        }
        
        return CGSize(width: size.width, height: height)
    }
    
    private func setup(type: SignalType, title: String?, text: String) {
        
        typeLabel.gradientColors = [type.gradient.0.cgColor, type.gradient.1.cgColor]
        typeLabel.text = type.rawValue.uppercased()
        
        if let title = title {
            titleView.font = UIFont(name: "Gotham-Black", size: 25)
            titleView.text = title
            textView.text = text
        } else {
            titleView.font = UIFont(name: "Gotham-Black", size: 16)
            titleView.text = text
            textView.text = ""
        }
    }
    
    func setup(for experience: Experience) {
        setup(type: experience.type, title: experience.title, text: experience.text)
    }
    
}
