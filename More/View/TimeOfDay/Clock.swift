//
//  Clock.swift
//  SwiftClock
//
//  Created by Joseph Daniels on 01/09/16.
//  Copyright © 2016 Joseph Daniels. All rights reserved.
//

import Foundation
import UIKit

@objc public  protocol TenClockDelegate {
    @objc optional func timesUpdateStarted(_ clock:TenClock) -> ()
    @objc optional func timesUpdated(_ clock:TenClock, startDate:Date,  endDate:Date) -> ()
    @objc optional func timesUpdateStopped(_ clock:TenClock, startDate:Date,  endDate:Date) -> ()
}

func medStepFunction(_ val: CGFloat, stepSize:CGFloat) -> CGFloat{
    let dStepSize = Double(stepSize)
    let dval  = Double(val)
    let nsf = floor(dval/dStepSize)
    let rest = dval - dStepSize * nsf
    return CGFloat(rest > dStepSize / 2 ? dStepSize * (nsf + 1) : dStepSize * nsf)
    
}

@IBDesignable
open class TenClock : UIControl {
    
    open var delegate:TenClockDelegate?
    //overall inset. Controls all sizes.
    @IBInspectable var insetAmount: CGFloat = 18
    var internalShift: CGFloat = 5;
    var pathWidth:CGFloat = 36
    
    let gradientLayer = CAGradientLayer()
    let trackLayer = CAShapeLayer()
    let pathLayer = CAShapeLayer()
    let headLayer = CAShapeLayer()
    let tailLayer = CAShapeLayer()
    let topHeadLayer = CAShapeLayer()
    let topTailLayer = CAShapeLayer()
    let numeralsLayer = CALayer()
    let titleTextLayer = CATextLayer()
    let overallPathLayer = CALayer()
    let twoPi = CGFloat(2 * Double.pi)
    let fourPi = CGFloat(4 * Double.pi)
    var headAngle: CGFloat = 0 {
        didSet{
            if (headAngle > fourPi + CGFloat(Double.pi)) {
                headAngle -= fourPi
            }
            if (headAngle <  CGFloat(Double.pi)) {
                headAngle += fourPi
            }
        }
    }
    var tailAngle: CGFloat = 0.7 * CGFloat(Double.pi) {
        didSet{
            if (tailAngle  > headAngle + fourPi) {
                tailAngle -= fourPi
            } else if (tailAngle  < headAngle) {
                tailAngle += fourPi
            }
        }
    }
    
    open var shouldMoveHead = true
    open var shouldMoveTail = true
    
    open var numeralsColor: UIColor? = UIColor.blueGrey
    open var centerTextColor: UIColor? = UIColor.charcoalGrey
    
    open var numeralsFont: UIFont = UIFont(name: "DIN-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18)
    open var centerHourFont: UIFont = UIFont(name: "DIN-Bold", size: 32) ?? UIFont.systemFont(ofSize: 32)
    open var centerHourLabelFont: UIFont = UIFont(name: "DIN-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18)
    
    open var trackColor: UIColor = UIColor(red: 237, green: 240, blue: 244)
    open var gradientColors: [UIColor] = [
        .periwinkle, UIColor(red: 48, green: 183, blue: 255), .brightSkyBlue, UIColor(red: 3, green: 255, blue: 191)
    ]
    
    /// Disable scrol on closest superview for duration of a valid touch.
    var disableSuperviewScroll = false
    
    open var headBackgroundColor: UIColor = .whiteTwo
    open var tailBackgroundColor: UIColor = .whiteTwo
    
    @objc open var disabled:Bool = false {
        didSet{
            update()
        }
    }
    
    @objc open var grayscale:Bool = false {
        didSet{
            update()
        }
    }
    
    open var buttonInset:CGFloat = 2
    func disabledFormattedColor(_ color: UIColor, alpha: CGFloat = 1) -> UIColor {
        return (disabled || grayscale) ? color.greyscaled(alpha) : color
    }
    
    var trackWidth:CGFloat { return pathWidth }
    func proj(_ theta:Angle) -> CGPoint{
        let center = self.layer.center
        return CGPoint(x: center.x + trackRadius * cos(theta) ,
                       y: center.y - trackRadius * sin(theta) )
    }
    
    var headPoint: CGPoint {
        return proj(headAngle)
    }
    
    var tailPoint: CGPoint {
        return proj(tailAngle)
    }
    
    lazy internal var calendar = Calendar(identifier:Calendar.Identifier.gregorian)
    func toDate(_ val:CGFloat)-> Date {
        return calendar.date(byAdding: Calendar.Component.minute , value: Int(val), to: Date().startOfDay as Date)!
    }
    
    open var startDate: Date {
        get{ return angleToTime(tailAngle) }
        set{ tailAngle = timeToAngle(newValue) }
    }
    
    open var endDate: Date {
        get{ return angleToTime(headAngle) }
        set{ headAngle = timeToAngle(newValue) }
    }
    
    var internalRadius: CGFloat {
        return internalInset.height
    }
    var inset: CGRect {
        return self.layer.bounds.insetBy(dx: insetAmount, dy: insetAmount)
    }
    var internalInset: CGRect {
        let reInsetAmount = trackWidth / 2 + internalShift
        return self.inset.insetBy(dx: reInsetAmount, dy: reInsetAmount)
    }
    var numeralInset: CGRect {
        let reInsetAmount = trackWidth / 2 + internalShift + internalShift
        return self.inset.insetBy(dx: reInsetAmount, dy: reInsetAmount)
    }
    var titleTextInset: CGRect {
        let reInsetAmount = trackWidth.checked / 2 + 4 * internalShift
        return (self.inset).insetBy(dx: reInsetAmount, dy: reInsetAmount)
    }
    var trackRadius: CGFloat { return inset.height / 2 }
    var buttonRadius: CGFloat { return pathWidth / 2 }
    var iButtonRadius: CGFloat { return buttonRadius - buttonInset }
    var strokeColor: UIColor {
        get {
            return UIColor(cgColor: trackLayer.strokeColor!)
        }
        set(strokeColor) {
            trackLayer.strokeColor = strokeColor.cgColor
            pathLayer.strokeColor = strokeColor.cgColor
        }
    }
    
    // input a date, output: 0 to 4pi
    func timeToAngle(_ date: Date) -> Angle {
        let units : Set<Calendar.Component> = [.hour, .minute]
        let components = self.calendar.dateComponents(units, from: date)
        let min = Double(  60 * components.hour! + components.minute! )
        
        return medStepFunction(CGFloat(Double.pi / 2 - ( min / (12 * 60)) * 2 * Double.pi), stepSize: CGFloat( 2 * Double.pi / (12 * 60 / 5)))
    }
    
    // input an angle, output: 0 to 4pi
    func angleToTime(_ angle: Angle) -> Date{
        let dAngle = Double(angle)
        let min = CGFloat(((Double.pi / 2 - dAngle) / (2 * Double.pi)) * (12 * 60))
        let startOfToday = Calendar.current.startOfDay(for: Date())
        return self.calendar.date(byAdding: .minute, value: Int(medStepFunction(min, stepSize: 5/* minute steps*/)), to: startOfToday)!
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        update()
    }
    
    open func update() {
        let mm = min(self.layer.bounds.size.height, self.layer.bounds.size.width)
        CATransaction.begin()
        self.layer.size = CGSize(width: mm, height: mm)
        
        strokeColor = trackColor
        overallPathLayer.occupation = layer.occupation
        gradientLayer.occupation = layer.occupation
        
        trackLayer.occupation = (inset.size, layer.center)
        
        pathLayer.occupation = (inset.size, overallPathLayer.center)
        numeralsLayer.occupation = (numeralInset.size, layer.center)
        
        trackLayer.fillColor = UIColor.clear.cgColor
        pathLayer.fillColor = UIColor.clear.cgColor
        
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        updateGradientLayer()
        updateTrackLayerPath()
        updatePathLayerPath()
        updateHeadTailLayers()
        updateWatchFaceNumerals()
        updateWatchFaceTitle()
        CATransaction.commit()
    }
    
    func updateGradientLayer() {
        gradientLayer.colors = gradientColors
            .map { disabledFormattedColor($0) }
            .map { $0.cgColor }
        gradientLayer.mask = overallPathLayer
        gradientLayer.startPoint = CGPoint(x:0, y:0)
    }
    
    func updateTrackLayerPath() {
        let circle = UIBezierPath(
            ovalIn: CGRect(
                origin:CGPoint(x: 0, y: 00),
                size: CGSize(width:trackLayer.size.width, height: trackLayer.size.width)))
        trackLayer.lineWidth = pathWidth
        trackLayer.path = circle.cgPath
    }
    
    override open func layoutSubviews() {
        update()
    }
    
    func updatePathLayerPath() {
        let arcCenter = pathLayer.center
        pathLayer.fillColor = UIColor.clear.cgColor
        pathLayer.lineWidth = pathWidth
        pathLayer.path = UIBezierPath(
            arcCenter: arcCenter,
            radius: trackRadius,
            startAngle: twoPi - ((tailAngle - headAngle) >= twoPi ? tailAngle - twoPi : tailAngle),
            endAngle: twoPi - headAngle,
            clockwise: true).cgPath
    }
    
    func updateHeadTailLayers() {
        let size = CGSize(width: 2 * buttonRadius, height: 2 * buttonRadius)
        let iSize = CGSize(width: 2 * iButtonRadius, height: 2 * iButtonRadius)
        let circle = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: 0, y:0), size: size)).cgPath
        let iCircle = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: 0, y:0), size: iSize)).cgPath
        tailLayer.path = circle
        headLayer.path = circle
        tailLayer.size = size
        headLayer.size = size
        tailLayer.position = tailPoint
        headLayer.position = headPoint
        topTailLayer.position = tailPoint
        topHeadLayer.position = headPoint
        headLayer.fillColor = UIColor.yellow.cgColor
        tailLayer.fillColor = UIColor.green.cgColor
        topTailLayer.path = iCircle
        topHeadLayer.path = iCircle
        topTailLayer.size = iSize
        topHeadLayer.size = iSize
        topHeadLayer.fillColor = disabledFormattedColor(headBackgroundColor).cgColor
        topTailLayer.fillColor = disabledFormattedColor(tailBackgroundColor).cgColor
        topHeadLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        topTailLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
    }
    
    func updateWatchFaceNumerals() {
        numeralsLayer.sublayers?.forEach {  $0.removeFromSuperlayer() }
        
        let startPos = CGPoint(x: numeralsLayer.bounds.midX, y: 15)
        let origin = numeralsLayer.center
        let step = (2 * Double.pi) / 4
        let textColor = disabledFormattedColor(numeralsColor ?? tintColor, alpha: 1.5)
        for i in (1 ... 4) {
            let text = NSAttributedString(
                string: "\(i * 3)",
                attributes: [.font : numeralsFont, .foregroundColor: textColor])
            let l = CATextLayer()
            l.bounds.size = text.size()
            l.alignmentMode = CATextLayerAlignmentMode.center
            l.contentsScale = UIScreen.main.scale
            l.string = text
            l.position = CGVector(from:origin, to:startPos).rotate( CGFloat(Double(i) * step)).add(origin.vector).point.checked
            numeralsLayer.addSublayer(l)
        }
    }
    
    func updateWatchFaceTitle() {
        
        var fiveMinIncrements = Int( ((tailAngle - headAngle) / twoPi) * 12 /*hrs*/ * 12 /*5min increments*/ )
        if fiveMinIncrements < 0 {
            print("tenClock:Err: is negative")
            fiveMinIncrements += (24 * (60/5))
        }
        
        let hours = fiveMinIncrements / 12
        let mins = (fiveMinIncrements % 12) * 5
        
        let text = NSMutableAttributedString()
        let textColor = disabledFormattedColor(centerTextColor ?? tintColor, alpha: 1.5)
        var part = NSAttributedString(
            string: "\(hours)",
            attributes: [.font : centerHourFont, .foregroundColor: textColor])
        text.append(part)
        
        part = NSAttributedString(
            string: "H",
            attributes: [.font : centerHourLabelFont, .foregroundColor: textColor])
        text.append(part)
        
        if mins > 0 {
            part = NSAttributedString(
                string: " \(mins)",
                attributes: [.font : centerHourFont, .foregroundColor: textColor])
            text.append(part)
            
            part = NSAttributedString(
                string: "M",
                attributes: [.font : centerHourLabelFont, .foregroundColor: textColor])
            text.append(part)
        }
        
        titleTextLayer.bounds.size = text.size()
        titleTextLayer.alignmentMode = CATextLayerAlignmentMode.center
        titleTextLayer.contentsScale = UIScreen.main.scale
        
        titleTextLayer.string = text
        titleTextLayer.position = gradientLayer.center
    }
    
    func createSublayers() {
        layer.addSublayer(numeralsLayer)
        layer.addSublayer(trackLayer)
        
        overallPathLayer.addSublayer(pathLayer)
        overallPathLayer.addSublayer(headLayer)
        overallPathLayer.addSublayer(tailLayer)
        overallPathLayer.addSublayer(titleTextLayer)
        layer.addSublayer(overallPathLayer)
        layer.addSublayer(gradientLayer)
        gradientLayer.addSublayer(topHeadLayer)
        gradientLayer.addSublayer(topTailLayer)
        update()
        strokeColor = disabledFormattedColor(tintColor)
    }
    
    override public init(frame: CGRect) {
        super.init(frame:frame)
        isExclusiveTouch = true
        createSublayers()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        isExclusiveTouch = true
        createSublayers()
    }
    
    var pointMover:((CGPoint) ->())?
    
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        
        guard !disabled  else {
            pointMover = nil
            return false
        }
        
        let pointOfTouch = touch.location(in: self)
        guard let layer = self.overallPathLayer.hitTest( pointOfTouch ) else { return false }
        
        var prev = pointOfTouch
        let pointerMoverProducer: (@escaping (CGPoint) -> Angle, @escaping (Angle)->()) -> (CGPoint) -> () = { g, s in
            return { p in
                let c = self.layer.center
                let computedP = CGPoint(x: p.x, y: self.layer.bounds.height - p.y)
                let v1 = CGVector(from: c, to: computedP)
                let v2 = CGVector(angle:g( p ))
                
                s(clockDescretization(CGVector.signedTheta(v1, vec2: v2)))
                self.update()
            }
        }
        
        switch(layer){
        case headLayer:
            if (shouldMoveHead) {
                pointMover = pointerMoverProducer({ _ in self.headAngle}, {self.headAngle += $0; self.tailAngle += 0})
            } else {
                pointMover = nil
            }
        case tailLayer:
            if (shouldMoveTail) {
                pointMover = pointerMoverProducer({_ in self.tailAngle}, {self.headAngle += 0;self.tailAngle += $0})
            } else {
                pointMover = nil
            }
        case pathLayer:
            if (shouldMoveHead) {
                pointMover = pointerMoverProducer({ pt in
                    let x = CGVector(from: self.bounds.center,
                                     to:CGPoint(x: prev.x, y: self.layer.bounds.height - prev.y)).theta;
                    prev = pt;
                    return x
                }, {self.headAngle += $0; self.tailAngle += $0 })
            } else {
                pointMover = nil
            }
        default: break
        }
        
        delegate?.timesUpdateStarted?(self)
        return true
    }

    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        
        guard let pointMover = pointMover else { return false }
        pointMover(touch.location(in: self))
        delegate?.timesUpdated?(self, startDate: self.startDate, endDate: endDate)
        return true
    }

    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        
        pointMover = nil
        delegate?.timesUpdateStopped?(self, startDate: self.startDate, endDate: endDate)
    }

    override open func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        
        pointMover = nil
        delegate?.timesUpdateStopped?(self, startDate: self.startDate, endDate: endDate)
    }
}
