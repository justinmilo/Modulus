//
//  ViewController.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/14/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit



class ViewController: UIViewController {

  let rectangle = CGRect(x: 120, y: 140, width: 140, height: 200)
  
  var handles : [UIView] = [] // Clockwise from topLeft
  let buttonSize = CGSize(44, 44)
  var outlines: [AnyLayout<UIView>] = []
  var outerBoundaryView : UIView!
    
  override func loadView() {
    let view = UIView()
    self.view = view
    view.backgroundColor = #colorLiteral(red: 0.05504439026, green: 0.06437031925, blue: 0.06856494397, alpha: 1)
    
    let border = UIView()
    self.view.addSubview(border)
    border.layer.borderWidth = 1.0
    border.layer.borderColor = UIColor.white.cgColor
    
    let b2 = UIView()
    self.view.addSubview(b2)
    b2.layer.borderWidth = 1.0
    b2.layer.borderColor = UIColor.gray.cgColor
    b2.layer.cornerRadius = buttonSize.width/4
    
    let b3 = UIView()
    self.view.addSubview(b3)
    self.view.sendSubview(toBack: b3)
    b3.backgroundColor = #colorLiteral(red: 0.1349328756, green: 0.1356815994, blue: 0.1134604588, alpha: 1)
    b3.layer.cornerRadius = buttonSize.width/4
    
    outerBoundaryView = b3
    b3.frame = view.frame.insetBy(dx: 100, dy: 100)

    
    let outside = MarginLayout(content:b2, margin: -buttonSize.width/4)
    outlines += [AnyLayout(border), AnyLayout(outside)]
    for var o in outlines { o.layout(in: rectangle)}
    
    
    // Handles
    let buttonFrames : [CGRect] = [rectangle.topLeft, rectangle.topRight, rectangle.bottomRight, rectangle.bottomLeft].map{
      let centerOffset = -(buttonSize.asVector()/2)
      return CGRect(origin: $0 + centerOffset, size: buttonSize)
    }
    
    // Set handles with side effects
    handles = buttonFrames.map {
      let v = ButtonView(frame: $0)
      self.view.addSubview(v)
      v.callBack = self.press(_:)
      return v
    }
    
  
  
  }
  
  var initialOffset = CGPoint.zero
  
  
    var point : TensionedPoint!
    
    
  
  
  @objc func press( _ gesture:UIGestureRecognizer )
    {
        let loc = gesture.location(in: gesture.view!.superview!)
        switch gesture.state
        {
        case .began:
            initialOffset = (gesture.view!.frame.origin - loc).asPoint()
        case .changed:
            
            var testFrame = view.bounds.insetBy(dx: 100, dy: 100)
            testFrame.size.width = testFrame.width - gesture.view!.frame.width
            testFrame.size.height = testFrame.height - gesture.view!.frame.height
            outerBoundaryView.frame = view.frame.insetBy(dx: 100, dy: 100)

            
            let targetFrameOrign = loc + initialOffset.asVector()
            let x = targetFrameOrign.x, y = targetFrameOrign.y
            
            let springX = TensionedPoint(x:x, y:y, anchor: targetFrameOrign)
            point = boundsLower(springX: springX, lowerBounds: testFrame.origin.x)
            point = boundsXUpper(springX: point, upperBounds: testFrame.origin.x + testFrame.size.width)
            point = boundsY(springY: point, lowerBounds: testFrame.origin.y)
            point = boundsYUpper(springY: point, upperBounds: testFrame.origin.y + testFrame.size.height)

            gesture.view?.frame.origin.x = point.x
            gesture.view?.frame.origin.y = point.y
            
            layout(gesture)
          
          //handles[nextLeft].center = CGPoint(
          
        case .ended:
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                gesture.view?.frame.origin.x = self.point.anchor.x
                gesture.view?.frame.origin.y = self.point.anchor.y
              
              self.layout(gesture)
            }
            )
        default:
            return
        }
    }
  
  fileprivate func layout(_ gesture: UIGestureRecognizer) {
    let indexOfHandle = handles.index(of: gesture.view!)!
    let opposingHandleIndex = indexOfHandle + 2 < handles.count ? indexOfHandle + 2 : indexOfHandle - 2
    let master = handles[indexOfHandle].center + handles[opposingHandleIndex].center
    
    handles[0].center = master.topLeft
    handles[1].center = master.topRight
    handles[2].center = master.bottomRight
    handles[3].center = master.bottomLeft
    
    
    for var outline in outlines {
      outline.layout(in: master)
    }
  }

}

struct TensionedPoint { var x:CGFloat, y: CGFloat, anchor: CGPoint }

// Takes a tensionedPoint (for chaining) and a lower X Bounds returns a tensionedPoint
// that is a square root of the diference
func boundsLower(springX: TensionedPoint, lowerBounds: CGFloat) -> TensionedPoint
{
  let x = springX.x
  if x < lowerBounds
  {
    let newX = pow((lowerBounds-x)*4,1/2)*2
    return TensionedPoint(
      x: lowerBounds - newX,
      y: springX.y,
      anchor: CGPoint(x:lowerBounds, y:springX.anchor.y)
    )
  }
  return springX
}

func boundsXUpper(springX: TensionedPoint, upperBounds: CGFloat) -> TensionedPoint
{
  let x = springX.x
  if x > upperBounds
  {
    let newX = pow((x-upperBounds)*4,1/2)*2
    return TensionedPoint(
      x:upperBounds + newX,
      y: springX.y,
      anchor: CGPoint(x:upperBounds, y:springX.anchor.y)
    )
  }
  return springX
}

// Changes the Y in returned TensionPoint (in both the y and anchor.y) in relation to an upper bounnds check
func boundsY(springY: TensionedPoint, lowerBounds: CGFloat) -> TensionedPoint
{
  let y = springY.y
  if y < lowerBounds
  {
    let a = pow((lowerBounds-y)*4,1/2)*2
    return TensionedPoint(
      x: springY.x,
      y:lowerBounds - a,
      anchor: CGPoint(x:springY.anchor.x, y:lowerBounds)
    )
  }
  return springY
}

func boundsYUpper(springY: TensionedPoint, upperBounds: CGFloat) -> TensionedPoint
{
  let y = springY.y
  if y > upperBounds
  {
    let a = pow((y-upperBounds)*4,1/2)*2
    return TensionedPoint(
      x: springY.x,
      y: upperBounds + a,
      anchor: CGPoint(x:springY.anchor.x, y:upperBounds)
    )
  }
  return springY
}



