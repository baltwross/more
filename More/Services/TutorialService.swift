//
//  TutorialService.swift
//  More
//
//  Created by Luko Gjenero on 24/05/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

class TutorialService {
    
    enum Tutorial: String {
        case firstCard    // show first time a card is shown
        case secondCard   // show on the second card shown
        case join         // show first time card is expanded
        case timer        // show first time timer is shown for your post
        case people       // show first time you see the people joined bar
        case active       // after the others first time you see the top bar with active people counter
        
        func text() -> NSAttributedString {
            switch self {
            case .firstCard:
                return Helper.text(parts: [
                    Helper.TextPart(text: "These cards are called ", font: Helper.normalFont, color: Helper.normalColor),
                    Helper.TextPart(text: "Times", font: Helper.boldFont, color: Helper.boldColor),
                    Helper.TextPart(text: ". Swipe left on a card to see another.", font: Helper.normalFont, color: Helper.normalColor)
                ])
            case .secondCard:
                return Helper.text(parts: [
                    Helper.TextPart(text: "Times", font: Helper.boldFont, color: Helper.boldColor),
                    Helper.TextPart(text: " are activities you can do on More. Tap on it to see how.", font: Helper.normalFont, color: Helper.normalColor)
                ])
            case .join:
                return Helper.text(parts: [
                    Helper.TextPart(text: "If you want to do this activity right now, tap ", font: Helper.normalFont, color: Helper.normalColor),
                    Helper.TextPart(text: "Join", font: Helper.boldFont, color: Helper.boldColor),
                    Helper.TextPart(text: ".", font: Helper.normalFont, color: Helper.normalColor)
                ])
            case .timer:
                return Helper.text(parts: [
                    Helper.TextPart(text: "For the next 60 minutes, people can see your post and join you.", font: Helper.normalFont, color: Helper.normalColor)
                ])
            case .people:
                return Helper.text(parts: [
                    Helper.TextPart(text: "The people you see here are about to start this activity. You can join them!", font: Helper.normalFont, color: Helper.normalColor)
                ])
            case .active:
                return Helper.text(parts: [
                    Helper.TextPart(text: "This is how many people are on More ", font: Helper.normalFont, color: Helper.normalColor),
                    Helper.TextPart(text: "right now", font: Helper.boldFont, color: Helper.boldColor),
                    Helper.TextPart(text: " who are looking for something to do.", font: Helper.normalFont, color: Helper.normalColor)
                ])
            }
        }
        
        func storageKey() -> String {
            return "com.startwithmore.tutorials.\(self.rawValue)"
        }
    }
    
    static let shared = TutorialService()
    
    func shouldShow(tutorial: Tutorial) -> Bool {
        guard ConfigService.shared.showTutorials else { return false }
        guard !alreadyShown(tutorial: tutorial) else { return false }
        
        switch tutorial {
        case .firstCard:
            ()
        case .secondCard:
            return alreadyShown(tutorial: .firstCard)
        case .join:
            // TODO: - check if this needs a condition
            return alreadyShown(tutorial: .secondCard)
        case .timer:
            ()
        case .people:
            return alreadyShown(tutorial: .secondCard)
        case .active:
            return alreadyShown(tutorial: .secondCard)
        }
        
        return true
    }
    
    func alreadyShown(tutorial: Tutorial) -> Bool {
        return UserDefaults.standard.bool(forKey: tutorial.storageKey())
    }
    
    func setAsShown(tutorial: Tutorial) {
        return UserDefaults.standard.set(true, forKey: tutorial.storageKey())
    }
    
    func currentlyShowing(tutorial: Tutorial) -> Bool {
        return currentTooltip != nil && currentTutorial == tutorial
    }
    
    // MARK: UI
    
    private weak var currentTooltip: TooltipView?
    private var currentTutorial: Tutorial?
    
    func show(tutorial: Tutorial, anchor: CGPoint, container: UIView, above: Bool) {
        
        currentTooltip?.removeFromSuperview()
        
        var width = container.frame.width * 0.6
        let edgePadding: CGFloat = 24
        
        let tooltip = TooltipView()
        tooltip.translatesAutoresizingMaskIntoConstraints = false
        tooltip.attributedText = tutorial.text()
        
        container.addSubview(tooltip)
        
        if anchor.x < 30 {
            if anchor.y < container.frame.height * 0.3 {
                tooltip.position = .leftTop
                tooltip.topAnchor.constraint(equalTo: container.topAnchor, constant: anchor.y - edgePadding).isActive = true
            } else if anchor.y < container.frame.height * 0.7 {
                tooltip.position = .left
                tooltip.centerYAnchor.constraint(equalTo: container.topAnchor, constant: anchor.y).isActive = true
            } else {
                tooltip.position = .leftBottom
                tooltip.bottomAnchor.constraint(equalTo: container.topAnchor, constant: anchor.y + edgePadding).isActive = true
            }
            tooltip.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: anchor.x + 16).isActive = true
            width = container.frame.width * 0.4
        } else if anchor.x <  container.frame.width - 30 {
        
            if anchor.x < container.frame.width * 0.3 {
                if above {
                    tooltip.position = .bottomLeft
                    tooltip.bottomAnchor.constraint(equalTo: container.topAnchor, constant: anchor.y - 16).isActive = true
                } else {
                    tooltip.position = .topLeft
                    tooltip.topAnchor.constraint(equalTo: container.topAnchor, constant: anchor.y + 16).isActive = true
                }
                tooltip.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: anchor.x - edgePadding).isActive = true
            } else if anchor.x < container.frame.width * 0.7 {
                if above {
                    tooltip.position = .bottom
                    tooltip.bottomAnchor.constraint(equalTo: container.topAnchor, constant: anchor.y - 16).isActive = true
                } else {
                    tooltip.position = .top
                    tooltip.topAnchor.constraint(equalTo: container.topAnchor, constant: anchor.y + 16).isActive = true
                }
                tooltip.centerXAnchor.constraint(equalTo: container.leadingAnchor, constant: anchor.x).isActive = true
            } else {
                if above {
                    tooltip.position = .bottomRight
                    tooltip.bottomAnchor.constraint(equalTo: container.topAnchor, constant: anchor.y - 16).isActive = true
                } else {
                    tooltip.position = .topRight
                    tooltip.topAnchor.constraint(equalTo: container.topAnchor, constant: anchor.y + 16).isActive = true
                }
                tooltip.trailingAnchor.constraint(equalTo: container.leadingAnchor, constant: anchor.x + edgePadding).isActive = true
            }
        } else {
            if anchor.y < container.frame.height * 0.3 {
                tooltip.position = .rightTop
                tooltip.topAnchor.constraint(equalTo: container.topAnchor, constant: anchor.y - edgePadding).isActive = true
            } else if anchor.y < container.frame.height * 0.7 {
                tooltip.position = .right
                tooltip.centerYAnchor.constraint(equalTo: container.topAnchor, constant: anchor.y).isActive = true
            } else {
                tooltip.position = .rightBottom
                tooltip.bottomAnchor.constraint(equalTo: container.topAnchor, constant: anchor.y + edgePadding).isActive = true
            }
            tooltip.trailingAnchor.constraint(equalTo: container.leadingAnchor, constant: anchor.x - 16).isActive = true
            width = container.frame.width * 0.4
        }
        
        tooltip.widthAnchor.constraint(equalToConstant: width).isActive = true
        
        // animate
        tooltip.alpha = 0
        UIView.animate(withDuration: 0.5) { [weak tooltip] in
            tooltip?.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak tooltip] in
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    tooltip?.alpha = 0
                },
                completion: { _ in
                    tooltip?.removeFromSuperview()
                })
        }
        
        currentTooltip = tooltip
        currentTutorial = tutorial
        setAsShown(tutorial: tutorial)
    }
    
    // MARK: - DEBUG
    
    func clearTutorials() {
        UserDefaults.standard.removeObject(forKey: Tutorial.firstCard.storageKey())
        UserDefaults.standard.removeObject(forKey: Tutorial.secondCard.storageKey())
        UserDefaults.standard.removeObject(forKey: Tutorial.join.storageKey())
        UserDefaults.standard.removeObject(forKey: Tutorial.timer.storageKey())
        UserDefaults.standard.removeObject(forKey: Tutorial.people.storageKey())
        UserDefaults.standard.removeObject(forKey: Tutorial.active.storageKey())
    }
    
}

extension TutorialService {
    
    private class Helper {
        
        static let normalFont = UIFont(name: "Avenir-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        static let boldFont = UIFont(name: "Avenir-Black", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .black)
        static let normalColor = UIColor.whiteThree
        static let boldColor = UIColor.cornflower
        
        struct TextPart {
            let text: String
            let font: UIFont
            let color: UIColor
            
            func attirubutedString() -> NSAttributedString {
                return NSAttributedString(
                    string: text,
                    attributes: [
                        .font: font,
                        .foregroundColor: color,
                    ]
                )
            }
        }
        
        class func text(parts: [TextPart]) -> NSAttributedString {
            let mutas = NSMutableAttributedString()
            parts.forEach { mutas.append($0.attirubutedString()) }
            return mutas
        }
    }
}
