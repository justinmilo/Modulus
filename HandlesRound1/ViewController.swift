//
//  ViewController.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/14/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit



class ViewController: UIViewController {

  let rectangle = CGRect(x: 120, y: 140, width: 200, height: 200)
  
  var handles : [UIView] = [] // Clockwise from topLeft
  let buttonSize = CGSize(44, 44)
  var outlines: [AnyLayout<UIView>] = []
  var outerBoundaryView : UIView!
  private var twoDView : Sprite2DGraph!
  var initialOffset = CGPoint.zero
  var point : TensionedPoint!
    
  override func loadView() {
    
    view = UIView()
    view.backgroundColor = #colorLiteral(red: 0.05504439026, green: 0.06437031925, blue: 0.06856494397, alpha: 1)
    
    // Create Borders ...
    let b1 = UIView()
    b1.layer.borderWidth = 1.0
    b1.layer.borderColor = UIColor.white.cgColor
    let b2 = UIView()
    b2.layer.borderWidth = 1.0
    b2.layer.borderColor = UIColor.gray.cgColor
    b2.layer.cornerRadius = buttonSize.width/4
    
       // Make Layouts for outlines
    let outside = MarginLayout(content:b2, margin: -buttonSize.width/4)
    outlines += [AnyLayout(b1), AnyLayout(outside)]
    for var o in outlines { o.layout(in: rectangle)}
    // ... End borders
    
    // Create Background View
    outerBoundaryView = UIView()
    outerBoundaryView.backgroundColor = #colorLiteral(red: 0.7808889747, green: 0.8120988011, blue: 0.9180557132, alpha: 0.1101177377)
    outerBoundaryView.layer.cornerRadius = buttonSize.width/4
    outerBoundaryView.frame = view.frame.insetBy(dx: 100, dy: 100)
    
    // Handles...
    let buttonFrames : [CGRect] = [rectangle.topLeft, rectangle.topRight, rectangle.bottomRight, rectangle.bottomLeft].map{
      let centerOffset = -(buttonSize.asVector()/2)
      return CGRect(origin: $0 + centerOffset, size: buttonSize)
    }
    
    // Set handles with side effects
    handles = buttonFrames.map {
      let v = ButtonView(frame: $0)
      v.callBack = self.press(_:)
      return v
    }
    //...Handles
    
    // Create sprite graph
    twoDView = Sprite2DGraph(model: Model2D(origin: rectangle.origin, dx: rectangle.width, dy: rectangle.height, col: 2, rows: 2))
    
    // Order Subviews and add to view
    for v in [outerBoundaryView!, twoDView, b2, b1] + handles { view.addSubview(v) }
    
    
  }
  
  
  
  
  
  
  @objc func press( _ gesture:UIGestureRecognizer )
    {
        let loc = gesture.location(in: gesture.view!.superview!)
        switch gesture.state
        {
        case .began:
            initialOffset = (gesture.view!.frame.origin - loc).asPoint()
        case .changed:
          
          // Setup the
            var testFrame = view.bounds.insetBy(dx: 10, dy: 10)
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
    // Create Master rectangle from gesture
    let indexOfHandle = handles.index(of: gesture.view!)!
    let opposingHandleIndex = indexOfHandle + 2 < handles.count ? indexOfHandle + 2 : indexOfHandle - 2
    let master = handles[indexOfHandle].center + handles[opposingHandleIndex].center
    
    // set handles
    handles[0].center = master.topLeft
    handles[1].center = master.topRight
    handles[2].center = master.bottomRight
    handles[3].center = master.bottomLeft
    
    // layout my view's outlines
    for var outline in outlines {
      outline.layout(in: master)
    }
    
    // Scale
    let scaleFactor : CGFloat = 3.0
    let scaledMaster = master * scaleFactor
    
    // Find appropriate model
    let x111 = twoMeterModel(targetSize: scaledMaster.size)
    let counts = x111 |> twoMeterModelCounts
    let grid = PlanModel(x: Grid(x111.x), y: Grid(x111.y))
      //twoMeterModel(targetSize: scaledMaster.size)
    
    // "layout" my subview grid, witha model2d
    let col = counts.x, rows = counts.y
    let dx : CGFloat = 200, dy : CGFloat = 200
    // create model
    let m = Model2D(origin: master.origin, dx: dx, dy: dy, col: col, rows: rows)
    self.twoDView.scale = 1/scaleFactor
    self.twoDView.model = NonuniformModel2D(origin: m.origin, rowSizes: grid.y, colSizes: grid.x)
    
  }

  override var shouldAutorotate: Bool {
    return true
  }
}



