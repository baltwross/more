//
//  EnRouteCancelledViewController.swift
//  More
//
//  Created by Luko Gjenero on 14/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class EnRouteCancelledViewController: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageView: MessagingTableView!
    @IBOutlet private weak var messageViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var button: UIButton!
    
    var doneTap: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyView = EmptyView()
        
        setupForEnterFromBelow()
    }
    
    func setup(for time: ExperienceTime) {
        
//        titleLabel.text = "\(time.otherPerson().name) Had to Cancel"
//
//        var height = CGFloat(80)
//        if let message = time.otherCancelMessage(){
//
//            let model  = MessageViewModel(
//                message: Message(
//                    id: "xxx",
//                    createdAt: time.endedAt ?? Date(),
//                    sender: time.otherPerson(),
//                    type: .text,
//                    text: message,
//                    deliveredAt: nil,
//                    readAt: nil))
//
//            messageView.setup(for: [model])
//            height = messageView.rect(forSection: 0).height + messageView.contentInset.top + messageView.contentInset.bottom
//        }
//
//        messageViewHeight.constant = height
//        view.layoutIfNeeded()
//        checkEmptyView()
    }

    override func viewDidLayoutSubviews() {
        var height = CGFloat(80)
        if messageView.numberOfRows(inSection: 0) > 0 {
            height = messageView.rect(forSection: 0).height + messageView.contentInset.top + messageView.contentInset.bottom
        }
        messageViewHeight.constant = height
        view.layoutIfNeeded()
    }
    
    private var isFirst = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isFirst else { return }
        isFirst = false
        
        var height = CGFloat(80)
        if messageView.numberOfRows(inSection: 0) > 0 {
            height = messageView.rect(forSection: 0).height + messageView.contentInset.top + messageView.contentInset.bottom
        }
        messageViewHeight.constant = height
        view.layoutIfNeeded()
        
        enterFromBelow()
    }

    
    @IBAction private func buttonTouch(_ sender: Any) {
        exitFromBelow { [weak self] in
            self?.doneTap?()
        }
    }
    
    // MARK: - empty view
    
    private class EmptyView: UIView {
        
        private let label: UILabel = {
            let label = UILabel()
            label.font = UIFont(name: "Avenir-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
            label.textColor = UIColor(red: 124, green: 139, blue: 155)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.text = "Your Time has been cancelled. We apologize for the inconvenience."
            return label
        }()
        
        convenience init() {
            self.init(frame: .zero)
            self.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(label)
            label.topAnchor.constraint(equalTo: topAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24).isActive = true
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 24).isActive = true
        }
    }
    
    private var emptyView: EmptyView? {
        didSet {
            checkEmptyView()
        }
    }
    
    private func checkEmptyView() {
        guard let emptyView = emptyView else { return }
        
        if messageView.numberOfRows(inSection: 0) == 0 {
            guard emptyView.superview == nil else { return }
            
            emptyView.translatesAutoresizingMaskIntoConstraints = false
            emptyView.setContentHuggingPriority(.defaultLow, for: .vertical)
            emptyView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            view.insertSubview(emptyView, aboveSubview: messageView)
            emptyView.leftAnchor.constraint(equalTo: messageView.leftAnchor).isActive = true
            emptyView.rightAnchor.constraint(equalTo: messageView.rightAnchor).isActive = true
            emptyView.bottomAnchor.constraint(equalTo: messageView.bottomAnchor).isActive = true
            emptyView.topAnchor.constraint(equalTo: messageView.topAnchor).isActive = true
            emptyView.setNeedsLayout()
        } else {
            emptyView.removeFromSuperview()
        }
    }
    
}
