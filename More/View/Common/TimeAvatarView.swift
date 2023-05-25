//
//  TimeAvatarView.swift
//  More
//
//  Created by Luko Gjenero on 04/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import SDWebImage

@IBDesignable
class TimeAvatarView: LoadableView {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var imageLeading: NSLayoutConstraint!
    @IBOutlet private weak var imageTop: NSLayoutConstraint!

    private lazy var ring: TimerAvatarLayer = {
        let ring = TimerAvatarLayer()
        ring.shouldRasterize = true
        ring.contentsScale = UIScreen.main.scale
        ring.rasterizationScale = UIScreen.main.scale
        return ring
    }()
    
    
    var type: SignalType = .boozy {
        didSet {
            ring.gradientImage = type.progressImage
        }
    }
    
    var ringSize: CGFloat = 5 {
        didSet {
            ring.progressWidth = ringSize - 1
            setupPadding(to: ringSize + imagePadding)
        }
    }
    
    var imagePadding: CGFloat = 2 {
        didSet {
            setupPadding(to: ringSize + imagePadding)
        }
    }
    
    var progress: CGFloat {
        get {
            return ring.progress
        }
        set {
            timer?.invalidate()
            ring.progress = newValue
        }
    }
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.sd_cancelCurrentImageLoad_progressive()
            imageView.image = newValue
        }
    }
    
    var imageUrl: String = "" {
        didSet {
            if let url = URL(string: imageUrl) {
                imageView.sd_progressive_setImage(with: url, placeholderImage: UIImage.profileThumbPlaceholder())
            } else {
                imageView.sd_cancelCurrentImageLoad_progressive()
            }
        }
    }
    
    var progressBackgroundColor: UIColor {
        get {
            return ring.progressBackgroundColor
        }
        set {
            ring.progressBackgroundColor = newValue
        }
    }
    
    var outlineColor: UIColor {
        get {
            return ring.innerColor
        }
        set {
            ring.innerColor = newValue
        }
    }
    
    override func setupNib() {
        super.setupNib()
        
        layer.addSublayer(ring)
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor(red: 179, green: 179, blue: 179).cgColor
        imageView.layer.borderWidth = 0.5
        
        setupPadding(to: ringSize + imagePadding)
    }
    
    private func setupPadding(to padding: CGFloat) {
        imageLeading?.constant = padding
        imageTop?.constant = padding
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.layer.cornerRadius = bounds.width * 0.5 - imageLeading.constant
        
        ring.frame = bounds
        ring.setNeedsDisplay()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()        
        progress = 0.6
    }
    
    // MARK: - animate progress
    
    private var start: Date?
    private var end: Date?
    private weak var timer: Timer?
    
    func setupRunningProgress(start: Date, end: Date) {
        
        timer?.invalidate()
        self.start = start
        self.end = end
        
        updateProgress()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
            self?.updateProgress()
        })
    }
    
    private func updateProgress() {
        if let start = start, let end = end {
            var progress = CGFloat(end.timeIntervalSinceNow / end.timeIntervalSince(start))
            progress = min(1, max(0, progress))
            ring.progress = progress
            if progress <= 0 {
                timer?.invalidate()
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }

}

class TimerAvatarLayer: CALayer {
    
    @NSManaged var progress: CGFloat
    
    @NSManaged var innerColor: UIColor
    @NSManaged var innerWidth: CGFloat
    @NSManaged var progressWidth: CGFloat
    @NSManaged var progressBackgroundColor: UIColor
    @NSManaged var gradientImage: UIImage
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        setup()
    }
        
    override init() {
        super.init()
        setup()
    }
    
    private func setup() {
        
        progress = 0
        innerColor = UIColor(red: 192, green: 195, blue: 201)
        innerWidth = 1
        progressWidth = 4
        progressBackgroundColor = UIColor(red: 218, green: 221, blue: 226)
        gradientImage = SignalType.boozy.progressImage
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == #keyPath(progress) {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    /*
    override func action(forKey key: String) -> CAAction?  {
        if key == #keyPath(progress) {
            let animation = CABasicAnimation(keyPath: key)
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.fromValue = self.presentation()?.progress
            return animation
        }
        return super.action(forKey: key)
    }
    */
    
    override func draw(in ctx: CGContext) {
        drawInnerLine(in: ctx)
        drawProgressBackground(in: ctx)
        drawProgress(in: ctx)
    }
    
    var centerRect: CGRect {
        guard bounds.width > 0 && bounds.height > 0 else { return .zero }
        
        var rect = bounds
        let offset = abs(rect.width - rect.height)
        if rect.width > rect.height {
            rect.origin.x = offset * 0.5
            rect.size.width -= offset
        } else if rect.width < rect.height {
            rect.origin.y = offset * 0.5
            rect.size.height -= offset
        }
        return rect
    }
    
    private func drawInnerLine(in ctx: CGContext) {
        let rect = centerRect.insetBy(dx: progressWidth + innerWidth * 0.5, dy: progressWidth + innerWidth * 0.5)
        
        guard rect.width > 0 else { return }
        
        let innerLine = UIBezierPath(ovalIn: rect)
        ctx.setLineWidth(innerWidth)
        ctx.setStrokeColor(innerColor.cgColor)
        ctx.addPath(innerLine.cgPath)
        ctx.strokePath()
    }
    
    private func drawProgressBackground(in ctx: CGContext) {
        let rect = centerRect.insetBy(dx: progressWidth * 0.5, dy: progressWidth * 0.5)
        
        guard rect.width > 0 else { return }
        
        let background = UIBezierPath(ovalIn: rect)
        ctx.setLineWidth(progressWidth)
        ctx.setStrokeColor(progressBackgroundColor.cgColor)
        ctx.addPath(background.cgPath)
        ctx.strokePath()
    }
    
    private func drawProgress(in ctx: CGContext) {
        let rect = centerRect
        
        guard rect.width > 0 else { return }
        guard progress > 0 else { return }
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = (rect.width - progressWidth) * 0.5
        
        ctx.saveGState()
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addArc(withCenter: center, radius: radius, startAngle: CGFloat(-90).toRadians(), endAngle: CGFloat(-90 + 360 * progress).toRadians(), clockwise: true)
        
        ctx.setLineWidth(progressWidth)
        ctx.setLineCap(.round)
        ctx.addPath(path.cgPath)
        ctx.replacePathWithStrokedPath()
        ctx.clip()
        
        if let cgImage = gradientImage.cgImage {
            ctx.draw(cgImage, in: rect)
        }
        
        ctx.restoreGState()
    }
}
