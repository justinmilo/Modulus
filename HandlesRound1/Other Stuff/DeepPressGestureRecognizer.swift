//
//  DeepPressGestureRecognizer.swift
//  DeepPressGestureRecognizer
//
//  Created by SIMON_NON_ADMIN on 03/10/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//
//  Thanks to Alaric Cole - bridging header replaced by proper import :)

/// Modfified by Justin Smith



import AudioToolbox
import UIKit.UIGestureRecognizerSubclass

// MARK: GestureRecognizer
class DeepPressGestureRecognizer: UIGestureRecognizer
{
  var vibrateOnDeepPress = false
  let threshold: CGFloat
  
  private var deepPressed: Bool = false
  
  required init(target: AnyObject?, action: Selector, threshold: CGFloat)
  {
    self.threshold = threshold
    
    super.init(target: target, action: action)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent)
  {
    if let touch = touches.first
    {
      handleTouch(touch: touch)
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent)
  {
    if let touch = touches.first
    {
      handleTouch(touch: touch)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent)
  {
    super.touchesEnded(touches, with: event)
    
    state = deepPressed ? UIGestureRecognizerState.ended : UIGestureRecognizerState.failed
    
    deepPressed = false
  }
  
  private func handleTouch(touch: UITouch)
  {
    guard let _ = view, touch.force != 0 && touch.maximumPossibleForce != 0 else
    {
      return
    }
    
    if !deepPressed && (touch.force / touch.maximumPossibleForce) >= threshold
    {
      
      state = UIGestureRecognizerState.began
      
      if vibrateOnDeepPress
      {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
      }
      
      deepPressed = true
    }
    else if deepPressed && (touch.force / touch.maximumPossibleForce) < 0.01
    {
      state = UIGestureRecognizerState.ended
      
      deepPressed = false
    }
  }
}

// MARK: DeepPressable protocol extension
protocol DeepPressable
{
  var gestureRecognizers: [UIGestureRecognizer]? {get set}
  
  func addGestureRecognizer(gestureRecognizer: UIGestureRecognizer)
  func removeGestureRecognizer(gestureRecognizer: UIGestureRecognizer)
  
  func setDeepPressAction(target: AnyObject, action: Selector)
  func removeDeepPressAction()
}

extension DeepPressable
{
  func setDeepPressAction(target: AnyObject, action: Selector)
  {
    let deepPressGestureRecognizer = DeepPressGestureRecognizer(target: target, action: action, threshold: 0.75)
    
    self.addGestureRecognizer(gestureRecognizer: deepPressGestureRecognizer)
  }
  
  func removeDeepPressAction()
  {
    guard let gestureRecognizers = gestureRecognizers else
    {
      return
    }
    
    for recogniser in gestureRecognizers where recogniser is DeepPressGestureRecognizer
    {
      removeGestureRecognizer(gestureRecognizer: recogniser)
    }
  }
}

