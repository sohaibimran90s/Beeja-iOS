//
//  CircularSlider.swift
//  CircularSlider
//
//  Created by Akram on 23/02/19.
//  Copyright © 2019 Akram. All rights reserved.
//

import UIKit

protocol CircularSliderDelegate: AnyObject {
    
    func circularSlider(_ circularSlider: CircularSlider, angleDidChanged newAngle: Double) -> Void
    func circularSlider(slidingDidEnd circularSlider: CircularSlider) -> Void
}

@IBDesignable class CircularSlider: UIView {

    private var thumbImageView: UIImageView?
    private var backGround: UIImageView?
    private var touchIndicator: UIImageView?
    private weak var sliderDelegate: CircularSliderDelegate?
    private var thumbCenter: CGPoint?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // this is crucial when constraints are used in superviews
    }
    
    private func initializeView() {
        let backgroundImage = UIImageView(frame: .zero)
        self.addSubview(backgroundImage)
        self.backGround = backgroundImage

        var frame = self.frame
        frame.size.height = frame.size.height / 2.5
        frame.size.width = frame.size.width / 2.5
        let touchIndicator = UIImageView(frame: frame)
        self.addSubview(touchIndicator)
        //touchIndicator.image = UIImage(named: "hand")
        touchIndicator.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        self.touchIndicator = touchIndicator
        
        let thumbView = UIImageView(frame: .zero)
        self.addSubview(thumbView)
        self.thumbImageView = thumbView
        self.thumbCenter = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        self.thumbImageView?.isHidden = true
        
        self.thumbImageView?.frame = CGRect(x: 0, y: 0, width: self.thumbRadius*2, height: self.thumbRadius*2)

        self.updateBackgroundImage()
    }
    
    private func consideredRadius() -> Double {
        return (self.bounds.size.height < self.bounds.size.width) ? Double(self.bounds.size.height / 2) : Double(self.bounds.size.width / 2)
    }
    
    private func pathRadius() -> Double {
        return self.consideredRadius() - self.thumbRadius
    }
    
    private func findIntersectionOfCircleWithLineFromCenter(to point: CGPoint) -> CGPoint? {
        let transformedPoint = CGPoint(x: point.x - self.bounds.size.width/2, y: self.bounds.size.height/2 - point.y)
        var y: Double!
        var x: Double!
        if transformedPoint.x == 0 {
            x = 0
            if point.y < self.bounds.size.height / 2 {
                y = self.pathRadius()
            } else {
                y = -self.pathRadius()
            }
        } else {
            var m: Double!
            if transformedPoint.x == 0 {
                m = Double(transformedPoint.y / transformedPoint.x)
            } else {
                m = Double(transformedPoint.y / transformedPoint.x)
            }
            let A = Double(m*m + 1)
            let B = Double(-2)
            let C = self.pathRadius() * self.pathRadius() * -1
            if point.x < self.bounds.size.width/2 {
                x = (B - sqrt(B*B - 4*A*C))/(2*A)
            } else {
                x = (B + sqrt(B*B - 4*A*C))/(2*A)
            }
            y = m*x
        }
        let actualPoint = CGPoint(x: x + Double(self.bounds.size.width/2),
                                  y: Double(self.bounds.size.height/2) - y)
        return actualPoint
    }
    
    func updateThumb(with animation:Bool) {
        self.thumbImageView?.image = self.thumbIcon
        if animation {
            self.thumbImageView?.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.2) {
                self.thumbImageView?.center = self.thumbCenter!
            }
        } else {
            self.thumbImageView?.center = self.thumbCenter!
        }
    }
    
    private func updateBackgroundImage() {
        var frame = self.bounds
        let radius = self.consideredRadius() - self.thumbRadius/2
        frame.size.width = CGFloat(radius) * 2
        frame.size.height = CGFloat(radius) * 2
        self.backGround?.frame = frame
        self.backGround?.center = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
    }
    
    private func currentAngle() -> Double {
        let transformedPoint = CGPoint(x: (self.thumbCenter?.x)! - self.bounds.size.width/2, y: self.bounds.size.height/2 - (self.thumbCenter?.y)!)
        if transformedPoint.x == 0 {
            if transformedPoint.y > 0 {
                return Double.pi/2
            } else {
                return  3*Double.pi/2
            }
        } else if transformedPoint.y == 0 {
            if transformedPoint.x > 0 {
                return 0
            } else {
                return Double.pi
            }
        } else {
            if transformedPoint.x > 0 && transformedPoint.y > 0 {
                // 1st quadrant
                return atan(Double(transformedPoint.y / transformedPoint.x))
            } else if transformedPoint.x > 0 && transformedPoint.y < 0 {
                // 4th quadrant
                return Double.pi * 2 + atan(Double(transformedPoint.y / transformedPoint.x))
            } else if transformedPoint.x < 0 && transformedPoint.y < 0 {
                // 3rd quadrant
                return atan(Double(transformedPoint.y / transformedPoint.x)) + Double.pi
            } else if transformedPoint.x < 0 && transformedPoint.y > 0 {
                // 2nd quadrant
                return Double.pi + atan(Double(transformedPoint.y / transformedPoint.x))
            }
        }
        return 0
    }
    
    public func angleInDegrees() -> Double {
        let angle = self.currentAngle()
        return (angle*180)/Double.pi
    }
    
    func updateAngle() {
        if self.sliderDelegate != nil {
            let angle = self.angleInDegrees()
            print("angleInDegrees.... \(angle)")
            self.sliderDelegate?.circularSlider(self, angleDidChanged: angle)
        }
    }
    
    @IBInspectable var thumbIcon: UIImage? {
        didSet {
            self.thumbCenter = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
            self.updateThumb(with: false)
        }
    }
    
    @IBInspectable var backGroundImage: UIImage? {
        didSet {
            self.updateBackgroundImage()
            self.backGround?.image = backGroundImage
        }
    }
    
    @IBInspectable var thumbRadius: Double = 20.0 {
        didSet {
            self.thumbImageView?.frame = CGRect(x: 0, y: 0, width: self.thumbRadius*2, height: self.thumbRadius*2)
            self.updateThumb(with: false)
        }
    }

    @IBOutlet
    public var delegate: AnyObject? {
        get { return self.sliderDelegate }
        set { self.sliderDelegate = newValue as? CircularSliderDelegate }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            self.thumbCenter = self.findIntersectionOfCircleWithLineFromCenter(to: touch.location(in: self))
            self.setTouchIndicator(true)
            self.updateThumb(with: true)
            self.updateAngle()
        }
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            self.thumbCenter = self.findIntersectionOfCircleWithLineFromCenter(to: touch.location(in: self))
            self.updateThumb(with: true)
            self.updateAngle()
        }
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            self.thumbCenter = self.findIntersectionOfCircleWithLineFromCenter(to: touch.location(in: self))
            self.updateThumb(with: true)
            self.updateAngle()
        }
        super.touchesEnded(touches, with: event)
        self.sliderDelegate?.circularSlider(slidingDidEnd: self)
    }

    func setTouchIndicator(_ hidden: Bool) -> Void {
        if hidden {
            self.thumbImageView?.isHidden = false
            self.touchIndicator?.isHidden = true
        } else {
            self.thumbImageView?.isHidden = true
            self.touchIndicator?.isHidden = false
            self.thumbCenter = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
        }
    }
    
}

