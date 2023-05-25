//
//  UnderlineTabBar.swift
//  More
//
//  Created by Luko Gjenero on 04/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

private let underlineHeight: CGFloat = 3

@IBDesignable
class UnderlineTabBar: UIView {

    struct Item {
        let id: Int
        let title: String
    }
    
    var items: [Item] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var itemSelected: ((_ item: Item)->())?
    
    @IBInspectable var selectedColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var color: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var underlineSelectedColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var underlineColor: UIColor = .clear {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var font: UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var _selectedIndex: Int = 0
    @IBInspectable var selectedIndex: Int {
        get {
            return _selectedIndex
        }
        set {
            if newValue >= 0 && newValue < items.count {
                _selectedIndex = newValue
                drawingLayer.selectedIndex = CGFloat(_selectedIndex)
            }
        }
    }
    
    private lazy var drawingLayer: UnderlineTabBarLayer = {
        let layer = UnderlineTabBarLayer(parentTabBar: self)
        layer.frame = bounds
        layer.parentTabBar = self
        layer.contentsScale = UIScreen.main.scale
        return layer
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
 
    func setup() {
        layer.addSublayer(drawingLayer)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapDetected)))
    }
    
    @objc private func tapDetected(_ tap: UITapGestureRecognizer) {
        guard tap.state == .recognized else { return }
        guard items.count > 0 else { return }
        
        let width = bounds.width / CGFloat(items.count)
        
        let newIndex = Int(tap.location(in: self).x / width)
        if newIndex != selectedIndex {
            selectedIndex = newIndex
            itemSelected?(items[selectedIndex])
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawingLayer.frame = bounds
        setNeedsDisplay()
    }
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        drawingLayer.setNeedsDisplay()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        items = [
            Item(id: 1, title: "Item 1"),
            Item(id: 2, title: "Item 2")
        ]
    }

}

class UnderlineTabBarLayer: CALayer {
    
    @NSManaged var selectedIndex: CGFloat
    @NSManaged var parentTabBar: UnderlineTabBar!
    
    init(parentTabBar: UnderlineTabBar) {
        super.init()
        self.parentTabBar = parentTabBar
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == #keyPath(selectedIndex) {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    override func action(forKey key: String) -> CAAction?  {
        if key == #keyPath(selectedIndex) {
            let animation = CABasicAnimation(keyPath: key)
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            animation.fromValue = self.presentation()?.selectedIndex
            return animation
        }
        return super.action(forKey: key)
    }
    
    override func draw(in ctx: CGContext) {
        guard parentTabBar.items.count > 0 else { return }
        
        // draw underline
        drawUnderline(parentTabBar, in: ctx)
        
        // draw labels
        drawLabels(parentTabBar, in: ctx)
    }
    
    private func drawUnderline(_ parentTabBar: UnderlineTabBar, in ctx: CGContext) {
        
        // normal
        drawNormalUnderLine(parentTabBar, in: ctx)
        
        // selected
        drawSelectedUnderline(parentTabBar, in: ctx)
    }
    
    private func drawNormalUnderLine(_ parentTabBar: UnderlineTabBar, in ctx: CGContext) {
        
        var underLineRect = bounds
        underLineRect.origin.y = underLineRect.size.height - underlineHeight
        underLineRect.size.height = underlineHeight
        let underline = UIBezierPath(rect: underLineRect)
        ctx.setFillColor(parentTabBar.underlineColor.cgColor)
        ctx.addPath(underline.cgPath)
        ctx.fillPath()
    }
    
    private func drawSelectedUnderline(_ parentTabBar: UnderlineTabBar, in ctx: CGContext) {
        
        let width = bounds.width / CGFloat(parentTabBar.items.count)
        let underLineRect = CGRect(x: selectedIndex * width,
                                   y: bounds.height - underlineHeight,
                                   width: width,
                                   height: underlineHeight)
        
        let underline = UIBezierPath(rect: underLineRect)
        ctx.setFillColor(parentTabBar.underlineSelectedColor.cgColor)
        ctx.addPath(underline.cgPath)
        ctx.fillPath()
    }
    
    private func drawLabels(_ parentTabBar: UnderlineTabBar, in ctx: CGContext) {
        
        let width = bounds.width / CGFloat(parentTabBar.items.count)
        
        for (idx, item) in parentTabBar.items.enumerated() {
            let rect = CGRect(x: CGFloat(idx) * width,
                              y: 0,
                              width: width,
                              height: bounds.height - underlineHeight)
            let attributes = labelAttributes(parentTabBar, selected: idx == Int(round(selectedIndex)))
            draw(label: item.title, attributes: attributes, rect: rect, in: ctx)
        }
    }
    
    private func draw(label: String, attributes: [NSAttributedString.Key: Any], rect: CGRect, in ctx: CGContext) {
        UIGraphicsPushContext(ctx)
        ctx.saveGState()
        var labelRect = CGRect()
        labelRect.size = label.size(withAttributes: attributes)
        labelRect.size.width = ceil(labelRect.size.width)
        labelRect.size.height = ceil(labelRect.size.height)
        labelRect.origin.x = CGFloat(floorf(Float(rect.origin.x + (rect.size.width - labelRect.size.width) * 0.5)))
        labelRect.origin.y = CGFloat(floorf(Float(rect.origin.y + (rect.size.height - labelRect.size.height) * 0.5)))
        label.draw(in: labelRect, withAttributes: attributes)
        ctx.restoreGState()
        UIGraphicsPopContext()
    }
    
    private func labelAttributes(_ tabBar: UnderlineTabBar, selected: Bool) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[.font] = tabBar.font
        if selected {
            attributes[.foregroundColor] = tabBar.selectedColor
        } else {
            attributes[.foregroundColor] = tabBar.color
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        attributes[.paragraphStyle] = paragraphStyle
        
        return attributes
    }

}
