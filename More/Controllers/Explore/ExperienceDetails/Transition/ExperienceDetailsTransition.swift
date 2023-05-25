//
//  ExperienceDetailsTransition.swift
//  More
//
//  Created by Luko Gjenero on 17/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

protocol ExperienceDetailsPresenter {
    var signalCell: ExploreCollectionViewCell? { get }
    var topSignalBar: ExploreTopBar? { get }
    var topBarSnapshot: UIImage? { get }
    var bottomPadding: CGFloat { get }
    func pause()
    func start()
}

protocol ExperienceDetailsView {
    var experience: Experience? { get }
    var photoFrame: CGRect { get }
    var overlaySnapshot: UIImage? { get }
    func prepareToPresentSignalDetails(size: CGSize) -> CGRect
    func prepareToDismissSignalDetails(duration: TimeInterval, complete: @escaping (_ frame: CGRect, _ overlaySnapshot: UIImage?) -> ())
}

class ExperienceDetailsTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let presentingDuration: TimeInterval = /* 5 // */ 0.6
    let dismissingDuration: TimeInterval = /* 5 // */ 0.8
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if presenting(using: transitionContext) == false {
            return dismissingDuration
        }
        return presentingDuration
    }
    
    func presenting(using transitionContext: UIViewControllerContextTransitioning?) -> Bool? {
        return transitionContext?.viewController(forKey: .to) is ExperienceDetailsView
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let presenting = self.presenting(using: transitionContext)
        if presenting == true {
            if let presenter = transitionContext.viewController(forKey: .from) as? ExperienceDetailsPresenter {
                presenter.pause()
                if let cell = presenter.signalCell, let topBar = presenter.topSignalBar {
                    present(using: transitionContext, cell: cell, topBar: topBar, bottomPadding: presenter.bottomPadding)
                } else {
                    fadeIn(using: transitionContext)
                }
            } else {
                fadeIn(using: transitionContext)
            }
        } else if presenting == false {
            if let presenter = transitionContext.viewController(forKey: .to) as? ExperienceDetailsPresenter {
                if let cell = presenter.signalCell, let topBar = presenter.topSignalBar {
                    dismiss(using: transitionContext, cell: cell, topBar: topBar)
                } else {
                    fadeOut(using: transitionContext)
                }
            } else {
                fadeOut(using: transitionContext)
            }
        } else {
            fadeIn(using: transitionContext)
        }
        
    }
    
    func fadeIn(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let to = transitionContext.view(forKey: .to)!
        
        to.frame = containerView.bounds
        containerView.addSubview(to)
        to.alpha = 0.0
        UIView.animate(
            withDuration: presentingDuration,
            animations: {
                to.alpha = 1.0
            },
            completion: { _ in
                containerView.isUserInteractionEnabled = true
                transitionContext.completeTransition(true)
            })
    }
    
    func fadeOut(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let to = transitionContext.view(forKey: .to)!
        let from = transitionContext.view(forKey: .from)!
        
        to.frame = containerView.bounds
        containerView.insertSubview(to, at: 0)
        UIView.animate(
            withDuration: presentingDuration,
            animations: {
                from.alpha = 0.0
            },
            completion: { _ in
                containerView.isUserInteractionEnabled = true
                transitionContext.completeTransition(true)
            })
        
    }
    
    private func present(using transitionContext: UIViewControllerContextTransitioning, cell: ExploreCollectionViewCell, topBar: ExploreTopBar, bottomPadding: CGFloat) {
        
        let containerView = transitionContext.containerView
        let to = transitionContext.viewController(forKey: .to)!
        let toProtocol = to as? ExperienceDetailsView
        
        let imageStartFrame = cell.image.convert(cell.image.bounds, to: containerView)
        var detailSize = containerView.bounds.size
        detailSize.height -= bottomPadding
        let imageEndFrame = toProtocol?.prepareToPresentSignalDetails(size: detailSize) ?? containerView.bounds
    
        let cellStartFrame = cell.convert(cell.bounds, to: containerView)
        var cellEndFrame = imageEndFrame
        cellEndFrame.origin.y -= cell.image.frame.minY
        cellEndFrame.size.height += cell.frame.height - cell.image.frame.height

        // transition view
        let transitionView = ExperienceDetailsTransitionView(frame: containerView.bounds)
        containerView.addSubview(transitionView)
        
        // views
        containerView.addSubview(to.view)
        to.view.alpha = 0
        to.view.frame = containerView.bounds
        to.view.layoutIfNeeded()
        cell.isHidden = true
        
        // setup
        transitionView.cardStartFrame = cellStartFrame
        transitionView.cardEndFrame = cellEndFrame
        transitionView.photoStartFrame = imageStartFrame
        transitionView.photoEndFrame = imageEndFrame
        var image = cell.image.image
        if !cell.video.isHidden {
            image = cell.videoSnapshot
        }
        transitionView.setup(for: cell.experience!, photo: image, overlay: toProtocol?.overlaySnapshot)
        transitionView.progress = 0
        
        // animation
        UIView.animate(
            withDuration: presentingDuration,
            delay: 0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 3,
            options: [.preferredFramesPerSecond30, .allowAnimatedContent],
            animations: {
                transitionView.progress = 1
            },
            completion: { _ in
                cell.isHidden = false
                to.view.alpha = 1
                transitionView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
    }
    
    private func dismiss(using transitionContext: UIViewControllerContextTransitioning, cell: ExploreCollectionViewCell, topBar: ExploreTopBar) {
        
        let duration = dismissingDuration - 0.2
        guard let fromProtocol = transitionContext.viewController(forKey: .from) as? ExperienceDetailsView else {
            fadeOut(using: transitionContext)
            return
        }

        fromProtocol.prepareToDismissSignalDetails(duration: 0.2) { (startFrame, overlay) in
            
            let containerView = transitionContext.containerView
            let from = transitionContext.viewController(forKey: .from)!
            let to = transitionContext.viewController(forKey: .to)!
            
            let imageStartFrame = cell.image.convert(cell.image.bounds, to: containerView)
            let imageEndFrame = startFrame
            
            let cellStartFrame = cell.convert(cell.bounds, to: containerView)
            var cellEndFrame = imageEndFrame
            cellEndFrame.origin.y -= cell.image.frame.minY
            cellEndFrame.size.height += cell.frame.height - cell.image.frame.height
            
            // transition view
            let transitionView = ExperienceDetailsTransitionView(frame: containerView.bounds)
            containerView.addSubview(transitionView)
            
            // views
            containerView.insertSubview(to.view, at: 0)
            from.view.alpha = 0
            to.view.alpha = 1
            to.view.frame = containerView.bounds
            cell.isHidden = true
            
            transitionView.cardStartFrame = cellStartFrame
            transitionView.cardEndFrame = cellEndFrame
            transitionView.photoStartFrame = imageStartFrame
            transitionView.photoEndFrame = imageEndFrame
            var image = cell.image.image
            if !cell.video.isHidden {
                image = cell.videoSnapshot
            }
            transitionView.setup(for: cell.experience!, photo: image, overlay: overlay)
            transitionView.progress = 1
            
            // animation
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 0.75,
                initialSpringVelocity: 3,
                options: [.preferredFramesPerSecond30, .beginFromCurrentState, .allowAnimatedContent],
                animations: {
                    transitionView.progress = 0
                },
                completion: { _ in
                    cell.isHidden = false
                    from.view.alpha = 1
                    transitionView.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                    if let presenter = transitionContext.viewController(forKey: .to) as? ExperienceDetailsPresenter {
                        presenter.start()
                    }
                })
        }
    }
}
