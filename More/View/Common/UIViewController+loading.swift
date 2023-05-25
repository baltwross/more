//
//  UIViewController+loading.swift
//  More
//
//  Created by Luko Gjenero on 02/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import Lottie

private let loadingAnimationViewId = 123456789

extension UIViewController {

    private var loadingAnimationView: UIView? {
        get {
            return view.viewWithTag(loadingAnimationViewId)
        }
    }
    
    func showLoading() {
        guard loadingAnimationView == nil else { return }
        
        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlay.tag = loadingAnimationViewId
        overlay.alpha = 0
        
        var lottie: LottieAnimationView?
        if let path = Bundle.main.path(forResource: "loading", ofType: "json", inDirectory: "Animations/loading-circle") {
            let lottieView = LottieAnimationView(filePath: path)
            lottieView.contentMode = .scaleAspectFit
            lottieView.loopMode = .loop
            lottieView.translatesAutoresizingMaskIntoConstraints = false
            overlay.addSubview(lottieView)
            lottieView.centerXAnchor.constraint(equalTo: overlay.centerXAnchor).isActive = true
            lottieView.centerYAnchor.constraint(equalTo: overlay.centerYAnchor).isActive = true
            lottieView.heightAnchor.constraint(equalToConstant: 64).isActive = true
            lottieView.widthAnchor.constraint(equalToConstant: 64).isActive = true
            lottie = lottieView
        }
        
        view.addSubview(overlay)
        overlay.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak overlay] in
                overlay?.alpha = 1
            },
            completion: { [weak lottie] (_) in
                lottie?.play()
            })
    }
    
    func hideLoading() {
        guard let loading = loadingAnimationView else { return }
        
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak loading] in
                loading?.alpha = 0
            },
            completion: { [weak loading] (_) in
                loading?.removeFromSuperview()
            })
    }

}
