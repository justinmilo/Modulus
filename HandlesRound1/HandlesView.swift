//
//  HandlesView.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics




// Pure functions

func corners(in rect: CGRect) -> [CGPoint]
{
  return  [rect.topLeft,
           rect.topRight,
           rect.bottomRight,
           rect.bottomLeft]
}

func edges(in rect: CGRect) -> [CGPoint]
{
  return  [rect.topCenter,
           rect.centerRight,
           rect.bottomCenter,
           rect.centerLeft]
}


// return edges from top left clockwise
func corners(of rect: CGRect)-> [CGPoint]
{
  return [rect.topLeft, rect.topRight, rect.bottomRight, rect.bottomLeft]
}
// return edges from top center clockwise
func edgeCenters(of rect: CGRect)->[CGPoint]
{
  return [rect.topCenter, rect.centerRight, rect.bottomCenter, rect.centerLeft]
}


// Create rect from a index that indicates master point of ref (if points dont make a rect naturally) and it's opposite corner given a counter clockwise set of corner points
func masterRect(from index: Int, in points:[CGPoint]) -> CGRect {
  
  let opposingIndex = index + 2 < points.count ? index + 2 : index - 2
  return points[index] + points[opposingIndex]
}
// Create rect from a "last changed" index assuming counter clockwise set of edge points // ADAPATER for interface
func centerDefinedRect(from index: Int, in points:[CGPoint]) -> CGRect {
  return centerDefinedRect(from: points)
}

func centerDefinedRect(from points:[CGPoint]) -> CGRect {
  let points = points.map{$0.asRect()}
  let remaining = points.dropFirst()
  return remaining.reduce(points.first!, { (res:CGRect, point:CGRect ) -> CGRect in
    return res.union( point )
  })
}

protocol Hideable {
  var isHidden: Bool { get set }
}

extension UIView : Hideable { }

import UIKit


// HANDLEVIEW
// A rect input machine
class HandleViewRound1: UIView {
  // Collection of functions
  struct StateFactory{
    enum State {
      case corner
      case edge
    }
    // Set immutable functions based on state enum
    init (state: State)
    {
      switch state {
      case .corner:
        self.centers = corners(in:)
        self.redefine = masterRect(from:in:)
        self.positions = {
          switch $0 {
          case 0: return (.top, .left)
          case 1: return (.top, .right)
          case 2: return (.bottom, .right)
          case 3: return (.bottom, .left)
          default: fatalError()
          }
        }
      case .edge:
        self.centers = edges(in:)
        self.redefine = centerDefinedRect(from:in:)
        self.positions = {
          switch $0 {
          case 0: return (.top, .center)
          case 1: return (.center, .right)
          case 2: return (.bottom, .center)
          case 3: return (.center, .left)
          default: fatalError()
          }
        }
      }
    }
    // State based functions : Assignment Based
    let centers : (CGRect) -> [CGPoint]
    let redefine : (Int, [CGPoint]) -> CGRect
    let positions: (Int) -> (VerticalPosition,HorizontalPosition)
  }
  
  // whole class properties
  var stateMachine : StateFactory!
  var handles : [UIView] = [] // Clockwise from topLeft
  var point : TensionedPoint!
  let buttonSize = CGSize(44, 44)
  var handler : ( CGRect, (VerticalPosition,HorizontalPosition))->() = { _,_ in }
  var completed : (CGRect,(VerticalPosition,HorizontalPosition))->() = { _, _ in }
  var outlines: [AnyLayout<UIView>] = []
  var hideables: [Hideable] = []
  var outerBoundaryView : UIView!


  
  convenience init(frame: CGRect, state: StateFactory.State, handler: @escaping (CGRect,
    (VerticalPosition,HorizontalPosition))->() )
  {
    self.init(frame: frame, state: state)
    self.handler = handler
  }
  
  // Main init
    init(frame: CGRect, state: StateFactory.State )
  {
    stateMachine = StateFactory(state: state)
    super.init(frame: frame)
    
    // Handles...
    let rectangle = CGRect(x: 120, y: 140, width: 200, height: 200)
    let buttonCenters : [CGPoint] = stateMachine.centers( rectangle)
    
    // Set handles with side effects
    handles = buttonCenters.map {
      let v = ButtonView(frame:  buttonSize.asRect())
      v.center = $0
      v.callBack = self.press(_:)
      return v
    }
    //...Handles
    
    // Create Background View
    
    handleBoundary = [UIView(), UIView(), UIView()]
    handleBoundary[1].backgroundColor = #colorLiteral(red: 0.7808889747, green: 0.8120988011, blue: 0.9180557132, alpha: 0.04869058104)
    handleBoundary[0].backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 0.0459672095)
    handleBoundary[2].backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 0.05251430462)
    for v in handleBoundary { v.isHidden = true }
    
    // Create Borders ...
    let b1 = UIView()
    b1.layer.borderWidth = 1.0
    b1.layer.borderColor = UIColor.gray.cgColor

    
    // Make Layouts for outlines
    outlines += [AnyLayout(b1)]
    hideables = [b1]
    for var o in outlines { o.layout(in: rectangle)}
    for var h in hideables { h.isHidden = true }
    // ... End borders
    

    // Order Subviews and add to view
    for v in [b1] + handleBoundary + handles { self.addSubview(v) }
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  var handleBoundary : [UIView] = []
  var initialOffset = CGPoint.zero // delta between touchDown center and handle center
  var frozenBounds = CGRect.zero
  var outerBounds = CGRect.zero
  
  @objc func press( _ gesture:UIGestureRecognizer )
  {
    let loc = gesture.location(in: gesture.view!.superview!)
    
    switch gesture.state
    {
    // set initial offset and frozenB
    case .began:
      
      initialOffset = (gesture.view!.center - loc).asPoint()
      let m1 = stateMachine.redefine(handles.index(of:gesture.view!)!, handles.map{ $0.center })
      frozenBounds = insetIf( m1)
      outerBounds = self.bounds.insetBy(dx: 20, dy: 20)
      for var h in hideables { h.isHidden = false }

      
    case .changed:
      
      // The target origin
      let t = loc + initialOffset.asVector()
      
      // bounds rects
      let me = boundsChecking(handles.index(of:gesture.view!)!, outerBounds, frozenBounds)
      
      // viewing bounds for handles
      handleBoundary[0].frame = frozenBounds
      handleBoundary[1].frame = outerBounds
      handleBoundary[2].frame = me
      
      // set point thats being moved
      point = t.tensionedPoint(within: me)
      gesture.view?.center = point.projection
      
      // Create Master rectangle from newly moved point and other points
      let indexOfHandle = handles.index(of: gesture.view!)!
      let master2 = stateMachine.redefine(indexOfHandle, self.handles.map{$0.center})//masterRect(from: indexOfHandle, in: handles.map{ $0.center })
      
      // update all handles to correct points
      let centers = stateMachine.centers(master2)
      for t in zip(centers, handles) { t.1.center = t.0 }
      
      // layout my view's outlines
      for var outline in outlines {
        outline.layout(in: master2)
      }


      
      let positions = stateMachine.positions(indexOfHandle)
      self.handler(master2, positions)
      
    case .ended:
      for var h in hideables { h.isHidden = true }

      UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
        gesture.view?.center = self.point.anchor
        
        // Create Master rectangle from gesture
        let indexOfHandle = self.handles.index(of: gesture.view!)!
        let master2 = self.stateMachine.redefine(indexOfHandle, self.handles.map{ $0.center })
        
        // update all handles to correct points
        let centers = self.stateMachine.centers(master2)
        for t in zip(centers, self.handles) { t.1.center = t.0 }
        
        let positions = self.stateMachine.positions(indexOfHandle)
        self.handler(master2, positions)
        self.completed(master2, positions)
        
      }, completion: { _ in
        
//        // Create Master rectangle from gesture
//        let indexOfHandle = self.handles.index(of: gesture.view!)!
//        let master2 = self.stateMachine.redefine(indexOfHandle, self.handles.map{ $0.center })
//        self.completed(master2)
      })
    //
    default:
      return
    }
  }
  
  func set(master: CGRect)
  {
    UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
      
      // update all handles to correct points
      let centers = self.stateMachine.centers(master)
      for t in zip(centers, self.handles) { t.1.center = t.0 }
      
    })
  }
  
  // pure3
  
  func insetIf(_ m1: CGRect)->CGRect {
    let sizeW : CGFloat = (buttonSize.width*2 <= m1.size.width) ? buttonSize.width : 0.0
    let sizeH : CGFloat = (buttonSize.height*2 <= m1.size.height) ? buttonSize.height : 0.0
    return m1.insetBy(dx: sizeW, dy: sizeH)
  }
  
  func boundsChecking(_ index: Int, _ outerBoundaryRect: CGRect, _ frozenBounds: CGRect)->CGRect {
    let me : CGRect
    switch index {
    case 0:
      me = outerBoundaryRect.topLeft + frozenBounds.bottomRight
    case 1:
      me = outerBoundaryRect.topRight + frozenBounds.bottomLeft
    case 2:
      me = outerBoundaryRect.bottomRight + frozenBounds.topLeft
    case 3:
      print("lightGreeen ", frozenBounds)
      print("outer ", outerBoundaryRect )
      print(outerBoundaryRect.bottomLeft, frozenBounds.topRight )
      me = outerBoundaryRect.bottomLeft + frozenBounds.topRight
      print("lightBlue/bounds ", me)
    default:
      fatalError()
    }
    return me
  }
  
}
