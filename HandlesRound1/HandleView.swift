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


func is3dTouchAvailable(traitCollection: UITraitCollection) -> Bool {
  return traitCollection.forceTouchCapability == UIForceTouchCapability.available
}


class ButtonView : UIView
{
  

    var interiorView = UIView()
    override init(frame: CGRect) {
      
      self.movingGestureRecognizer = UIPanGestureRecognizer()
      self.movingGestureRecognizer.isEnabled = false

        super.init(frame: frame)
        
      
        
        self.interiorView.frame = bounds.insetBy(dx: bounds.width/4, dy: bounds.height/4)
        interiorView.layer.cornerRadius = CGFloat(frame.size.width/4)
        interiorView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        interiorView.layer.opacity = 0.6
        
        self.addSubview(interiorView)
      
      self.addGestureRecognizer(movingGestureRecognizer)
      let hold = UILongPressGestureRecognizer(target: self, action: #selector(ButtonView.press(_:)))

    }
  var deepPressRecognized = false
  var movingGestureRecognizer : UIGestureRecognizer
  
  override func didMoveToSuperview() {
    
    if(is3dTouchAvailable(traitCollection: self.traitCollection)) {
      let deep = DeepPressGestureRecognizer(
        target: self,
        action: #selector(ButtonView.press(_:)),
        threshold: 0.25)
      
      self.addGestureRecognizer(deep)
    }
    else {
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
    required init?(coder aDecoder: NSCoder) {
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
            h.frame = h.frame.insetBy(dx: -sizeChange, dy: -sizeChange)
            h.layer.cornerRadius = h.layer.cornerRadius + sizeChange
            h.layer.opacity = 0.5
          
            
        case .ended:
            
            let h = self.interiorView
            h.layer.cornerRadius = h.layer.cornerRadius - sizeChange
            h.frame = h.frame.insetBy(dx: sizeChange, dy: sizeChange)
            h.layer.opacity = 1.0
            self.deepPressRecognized = false
            return
        default:
            return
        }
    }
}
