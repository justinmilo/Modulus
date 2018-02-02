//
//  HandleView.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/14/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit

import AudioToolbox



//Just in case - here're examples for iPhone 7/7+.

public class ButtonView : UIView
{
  
  
  var interiorView = UIView()
  override init(frame: CGRect) {
    
    self.movingGestureRecognizer = UIPanGestureRecognizer()
    self.movingGestureRecognizer.isEnabled = false
    
    let bounds = CGRect(origin:CGPoint.zero, size: frame.size)
    let interiorFrame = bounds.insetBy(dx: bounds.width/4, dy: bounds.height/4)
    beganFrame = interiorFrame.insetBy(dx: -sizeChange, dy: -sizeChange)
    endedFrame = interiorFrame
    beganRadius = CGFloat(frame.size.width/4) + sizeChange
    endedRadius = CGFloat(frame.size.width/4)
    
    
    super.init(frame: frame)
    

    
    
    self.interiorView.frame = interiorFrame
    interiorView.layer.cornerRadius = endedRadius
    interiorView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    interiorView.layer.opacity = 0.6
    
    
    
    
    self.addSubview(interiorView)
    
    self.addGestureRecognizer(movingGestureRecognizer)
  }
  var deepPressRecognized = false
  var movingGestureRecognizer : UIGestureRecognizer
  
  public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    self.setupGesturesBased(onTrait: self.traitCollection)
  }
  
  override public func didMoveToSuperview() {
    self.setupGesturesBased(onTrait: self.traitCollection)
  }
  
  func setupGesturesBased(onTrait: UITraitCollection)
  {
    if(onTrait.forceTouchCapability == UIForceTouchCapability.available) {
      print("3d Touch Available")
      let deep = DeepPressGestureRecognizer(
        target: self,
        action: #selector(ButtonView.press(_:)),
        threshold: 0.25)
      
      self.addGestureRecognizer(deep)
    }
    else {
      print("3d Touch No!")
      
      let hold = UILongPressGestureRecognizer(target: self, action: #selector(ButtonView.press(_:)))
      self.addGestureRecognizer(hold)
      deepPressRecognized = true
    }
  }
  
  
  @objc func deepPressHandler(value: DeepPressGestureRecognizer)
  {
    if value.state == UIGestureRecognizerState.began
    {
      print("deep press begin")
      deepPressRecognized = true
    }
  }
  
  
  let sizeChange : CGFloat = 30.0
  let beganFrame : CGRect
  let endedFrame : CGRect
  let endedRadius : CGFloat
  let beganRadius : CGFloat
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var callBack : ( UIGestureRecognizer ) -> ()  = { _ in }
  @objc func press( _ gesture:UIGestureRecognizer )
  {
    print("There")
    //guard deepPressRecognized else { return }
    
    print("Not")
    callBack(gesture)
    _ = gesture.location(in: gesture.view!.superview!).x
    switch gesture.state
    {
    case .began:
      AudioServicesPlaySystemSound(1519) // Actuate `Peek` feedback (weak boom)
      //AudioServicesPlaySystemSound(1520) // Actuate `Pop` feedback (strong boom)
      
      let h = self.interiorView
      h.frame = beganFrame
      h.layer.cornerRadius = beganRadius
      h.layer.opacity = 0.5
      
      
    case .ended:
      
      let h = self.interiorView
      h.layer.cornerRadius = endedRadius
      h.frame = endedFrame
      h.layer.opacity = 1.0
      self.deepPressRecognized = false
      return
    default:
      return
    }
  }
}
