//
//  RippleEffect.swift
//  MoodChart
//
//  Created by Ankur Sharma on 31/05/19.
//  Copyright © 2019 com.ankur. All rights reserved.
//

import UIKit

class RippleEffect{
  
  func addRippleEffect(to referenceView: UIView, completion:@escaping ()-> Void) {
    /*! Creates a circular path around the view*/
    let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: referenceView.bounds.size.width, height: referenceView.bounds.size.height))
    /*! Position where the shape layer should be */
    let shapePosition = CGPoint(x: referenceView.bounds.size.width / 2.0, y: referenceView.bounds.size.height / 2.0)
    let rippleShape = CAShapeLayer()
    rippleShape.bounds = CGRect(x: 0, y: 0, width: referenceView.bounds.size.width, height: referenceView.bounds.size.height)
    rippleShape.path = path.cgPath
    rippleShape.fillColor = UIColor.white.cgColor
    rippleShape.strokeColor = UIColor.white.cgColor
    rippleShape.position = shapePosition
    rippleShape.opacity = 0
    
    /*! Add the ripple layer as the sublayer of the reference view */
    referenceView.layer.addSublayer(rippleShape)
    /*! Create scale animation of the ripples */
    let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
    scaleAnim.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
    scaleAnim.toValue = NSValue(caTransform3D: CATransform3DMakeScale(2, 2, 1))
    /*! Create animation for opacity of the ripples */
    let opacityAnim = CABasicAnimation(keyPath: "opacity")
    opacityAnim.fromValue = 1
    opacityAnim.toValue = nil
    /*! Group the opacity and scale animations */
    let animation = CAAnimationGroup()
    animation.animations = [scaleAnim, opacityAnim]
    animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
    animation.duration = CFTimeInterval(0.7)
    animation.repeatCount = 1
    animation.isRemovedOnCompletion = true
    rippleShape.add(animation, forKey: "rippleEffect")
    
    DispatchQueue.main.asyncAfter(deadline: .now() +  0.4, execute: completion)
  }
  
}

