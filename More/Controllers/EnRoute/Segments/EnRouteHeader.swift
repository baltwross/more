//
//  EnRouteHeader.swift
//  More
//
//  Created by Luko Gjenero on 14/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import SDWebImage

@IBDesignable
class EnRouteHeader: LoadableView {

    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var message: UIButton!
    @IBOutlet private weak var messageBadge: UILabel!
    @IBOutlet private weak var call: UIButton!
    @IBOutlet private weak var avatar: UIImageView!
    @IBOutlet private weak var bulbView: UIImageView!
    @IBOutlet private weak var profile: UIButton!
    
    var profileTap: (()->())?
    var messageTap: (()->())?
    var callTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        messageBadge.isHidden = true
        messageBadge.layer.cornerRadius = 10.5
        messageBadge.layer.masksToBounds = true
        
        enableShadow(color: .black)
        
        message.enableShadow(color: .black, path: UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 37, height: 37)).cgPath)
        call.enableShadow(color: .black, path: UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 37, height: 37)).cgPath)
    }
    
    /*
    override func layoutSubviews() {
        super.layoutSubviews()
        enableShadow(color: .black, path: UIBezierPath(rect: bounds).cgPath)
    }
    */
    
    func setup(for time: Time) {
        setupTitle(for: time)
        avatar.sd_progressive_setImage(with: URL(string: time.otherPerson().avatar), placeholderImage: UIImage.profileThumbPlaceholder())
    }
    
    func setupForMessages(highlight: Bool, count: Int) {
        message.isSelected = highlight
        messageBadge.isHidden = count <= 0
        messageBadge.text = "\(count)"
    }
    
    func setupTitle(for time: Time) {
        
        let text = NSMutableAttributedString()
        
        var font = UIFont(name: "Gotham-Black", size: 11) ?? UIFont.systemFont(ofSize: 11)
        var part = NSAttributedString(
            string: "\(time.otherPerson().name)",
            attributes: [NSAttributedString.Key.foregroundColor : Colors.lightBlueHighlight,
                         NSAttributedString.Key.kern : 2,
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        let partText = time.otherState() == .arrived ? " has arrived" : " is en route"
        font = UIFont(name: "Avenir-Heavy", size: 11) ?? UIFont.systemFont(ofSize: 11)
        part = NSAttributedString(
            string: partText,
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.white,
                         NSAttributedString.Key.kern : 0.5,
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        titleView.attributedText = text
    }
    
    @IBAction private func messageTouch(_ sender: Any) {
        messageTap?()
    }
    
    @IBAction private func callTouch(_ sender: Any) {
        callTap?()
    }
    
    @IBAction private func profileTouch(_ sender: Any) {
        profileTap?()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var inside = super.point(inside: point, with: event)
        if !inside {
            inside = profile.point(inside: convert(point, to: profile), with: event)
        }
        return inside
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var hit = super.hitTest(point, with: event)
        var selfView: UIView = self
        if self.subviews.count == 1 {
            selfView = self.subviews.first!
        }   
        if hit == self || hit == selfView {
            hit = profile.hitTest(convert(point, to: profile), with: event)
        }
        return hit
    }
}
