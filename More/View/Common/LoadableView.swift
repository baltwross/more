//
//  LoadableView.swift
//

import Foundation
import UIKit

public protocol NibLoadableProtocol: NSObjectProtocol {
    
    var nibContainerView: UIView { get }
    
    func loadNib() -> UIView?
    
    func setupNib()
    
    var nibName: String { get }
}

extension UIView {
    
    open var nibContainerView: UIView {
        return self
    }
}

@IBDesignable
open class LoadableView: UIView, NibLoadableProtocol {
    
    public var nibName: String {
        return String(describing: type(of: self))
    }
    
    public func loadNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        return view
    }
    
    internal func setupView(_ view: UIView?, inContainer container: UIView) {
        if let view = view {
            view.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(view)
            view.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
            view.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
            
//            view.setContentHuggingPriority(.defaultHigh, for: .vertical)
//            view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//            view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
//            view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupNib()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNib()
    }
    
    open func setupNib() {
        setupView(loadNib(), inContainer: nibContainerView)
    }
}
