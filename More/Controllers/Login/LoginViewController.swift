//
//  LoginViewViewController.swift
//  More
//
//  Created by Igor Ostriz on 02/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class LoginViewController: BaseLoginViewController, UIGestureRecognizerDelegate {

    @IBOutlet private weak var splashBackground: UIImageView!
    @IBOutlet private weak var splashHeader: UIImageView!
    @IBOutlet private weak var splashLogo: UIImageView!
    @IBOutlet private weak var content: UIView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet weak var startLabel: UILabel!
    
    private var nestedNavigationController: UINavigationController? = nil
    private var showAnimation: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.alpha = 0
        splashHeader.alpha = 0
        
        setupStartLabel()
        
        for constraint in view.constraints {
            if constraint.firstAnchor == content.bottomAnchor ||
                constraint.secondAnchor == content.bottomAnchor {
                bottomContraint = constraint
                break
            }
        }
        trackKeyboardAndPushUp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard showAnimation else { return }
        showAnimation = false
        
        let scale = content.frame.minY / splashBackground.frame.height
        var bgTransform = CATransform3DMakeTranslation(0, -(splashBackground.frame.height - content.frame.minY) * 0.5, 0)
        bgTransform = CATransform3DScale(bgTransform, 1, scale, 1)
        var logoTransform = CATransform3DMakeTranslation(0, -(splashBackground.frame.height - splashLogo.frame.height) * 0.5, 0)
        logoTransform = CATransform3DScale(logoTransform, 0.6, 0.6, 1)
        
        content.layer.transform = CATransform3DMakeTranslation(0, content.frame.height + view.safeAreaInsets.bottom, 0)
        view.bringSubviewToFront(content)
        
        UIView.animate(
            withDuration: 0.4,
            animations: {
                self.content.layer.transform = CATransform3DIdentity
                self.splashBackground.layer.transform = bgTransform
                self.splashHeader.layer.transform = bgTransform
                self.splashHeader.alpha = 1
                self.splashLogo.layer.transform = logoTransform
            })
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        nestedNavigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbeddNavigation" {
            nestedNavigationController = segue.destination as? UINavigationController
            nestedNavigationController?.delegate = self
        } else if segue.identifier == "EnterCode" {
            if let vc = segue.destination as? LoginEnterCodeViewController {
                vc.login = { [weak self] in
                    self?.nextView?()
                }
            }
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        backButton.alpha = navigationController.viewControllers.count < 2 ? 0 : 1
        
        if let vc = viewController as? LoginEnterCodeViewController {
            vc.login = { [weak self] in
                self?.nextView?()
            }
        }
    }
    
    private func setupStartLabel() {
        
        let text = NSMutableAttributedString()
        
        var font = UIFont(name: "Gotham-Bold", size: 25) ?? UIFont.systemFont(ofSize: 25)
        var paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 28.0 / font.lineHeight
        
        var part = NSAttributedString(
            string: "Start With ",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 124, green: 139, blue: 155),
                         NSAttributedString.Key.font : font,
                         NSAttributedString.Key.paragraphStyle: paragraph])
        text.append(part)
        
        font = UIFont(name: "Gotham-Black", size: 26) ?? UIFont.systemFont(ofSize: 26)
        paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 26.0 / font.lineHeight
        part = NSAttributedString(
            string: "MORE",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 67, green: 74, blue: 81),
                         NSAttributedString.Key.font : font,
                         NSAttributedString.Key.kern : 1.5,
                         NSAttributedString.Key.paragraphStyle: paragraph])
        text.append(part)
        
        startLabel.attributedText = text
    }
    
}
