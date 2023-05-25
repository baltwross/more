//
//  EnRouteCancelMesasgeView.swift
//  More
//
//  Created by Luko Gjenero on 09/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class EnRouteCancelMesasgeView: LoadableView {
    
    @IBOutlet private weak var panel: UIView!
    @IBOutlet private weak var topBarContainer: UIView!
    @IBOutlet private weak var topBar: ChatViewLeftHeader!
    @IBOutlet private weak var walking: UIView!
    @IBOutlet private weak var distance: UILabel!
    @IBOutlet private weak var emptyView: EnRouteCancelMesasgeEmptyView!
    @IBOutlet private weak var input: MessagingInputBar!
    @IBOutlet weak var bottomPadding: NSLayoutConstraint!
    
    private var time: ExperienceTime?
    
    var back: (()->())?
    var profile: (()->())?
    var done: ((_ text: String)->())?
    
    override func setupNib() {
        super.setupNib()
        
        panel.enableShadow(color: .black)
        
        topBar.backTap = { [weak self] in
            self?.back?()
        }
        
        topBar.profileTap = { [weak self] in
            self?.profile?()
        }
        
        input.sendTap = { [weak self] text in
            self?.sendMessage(text)
        }
        
        walking.addWalkingAnimation()
        walking.lottieView?.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: 12.0, height: 12.0))
        
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
    
    // MARK: - ui
    
    private func sendMessage(_ text: String?) {
        guard let profile = ProfileService.shared.profile else { return }
        guard let time = time else { return }
        
        if let text = text {
            done?(text)
        }
    }
    
    // MARK: - public methods
    
    func setup(for time: ExperienceTime) {
        self.time = time
        
        topBar.setup(for: time.post.creator)
        emptyView.setup(for: time.post.creator)
        
        distance.text = "..."
        loadDistance(from: time.post.creator)
    }
    
    private func loadDistance(from user: ShortUser) {
        guard let myId = ProfileService.shared.profile?.getId() else { return }
        GeoService.shared.getDistance(from: myId, to: user.id) { [weak self] (distance) in
            self?.distance.text = "\(Formatting.formatFeetAway(distance.metersToFeet())) away"
        }
    }
}

@IBDesignable
class EnRouteCancelMesasgeEmptyView: UIView {
    
    private let title: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.backgroundColor = .clear
        title.textColor = .silver
        title.font = UIFont(name: "Avenir-Heavy", size: 25)
        title.text = "Cancel Time"
        return title
    }()
    
    private let subTitle: UILabel = {
        let subTitle = UILabel()
        subTitle.translatesAutoresizingMaskIntoConstraints = false
        subTitle.backgroundColor = .clear
        subTitle.textColor = UIColor.charcoalGrey.withAlphaComponent(0.4)
        subTitle.font = UIFont(name: "Avenir-Medium", size: 14)
        subTitle.text = "Please give Gemma a heads up about why you had to cancel."
        subTitle.numberOfLines = 0
        return subTitle
    }()
    
    private let container: UIView = {
       let container = UIView()
       container.translatesAutoresizingMaskIntoConstraints = false
       container.backgroundColor = .clear
       return container
    }()
    
    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        
        addSubview(container)
        container.addSubview(title)
        container.addSubview(subTitle)
        
        container.topAnchor.constraint(equalTo: topAnchor, constant: 35).isActive = true
        container.leftAnchor.constraint(equalTo: leftAnchor, constant: 25).isActive = true
        container.rightAnchor.constraint(equalTo: rightAnchor, constant: -25).isActive = true
        container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35).isActive = true
        
        title.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
        title.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true

        subTitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4).isActive = true
        subTitle.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
        subTitle.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
        subTitle.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        
        layoutIfNeeded()
    }
    
    func setup(for user: ShortUser) {
        subTitle.text = "Please give \(user.name) a heads up about why you had to cancel."
    }
}
