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

// Create rect from a "last changed" index assuming counter clockwise set of edge points // ADAPATER for interface
func mirrorDefinedRect(mirroredAt position: CGPoint, from index: Int, in points:[CGPoint]) -> CGRect {
  var points = points
  // mirror the current index around mirror position and store as opposite
  points[index |> opposite] = points[index] |> mirrorOrtho(from: position)
  
  let zeroRects = points.map{$0.asRect()}
  let remaining = zeroRects.dropFirst()
  return remaining.reduce(zeroRects.first!) { return $0.union( $1 ) }
}

func opposite(i : Int )-> Int
{
  let sides = 4
  return i + 2 < sides ?
    i + 2 : i - 2
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


struct BoundingBoxState {
  var centers: (CGRect) -> [CGPoint]
  let redefine : (Int, [CGPoint]) -> CGRect
  let positions: (Int) -> (VerticalPosition,HorizontalPosition)
}


let cornerState = BoundingBoxState(
  centers: corners(in:),
  redefine: masterRect(from:in:),
  positions: {
    switch $0 {
    case 0: return (.top, .left)
    case 1: return (.top, .right)
    case 2: return (.bottom, .right)
    case 3: return (.bottom, .left)
    default: fatalError()
    }
}
)
    
let edgeState = BoundingBoxState(
  centers: edges(in:),
  redefine: centerDefinedRect(from:in:),
  positions: edgePositions)

func edgePositions( i: Int) -> (VerticalPosition, HorizontalPosition)
{
  switch i {
  case 0: return (.top, .center)
  case 1: return (.center, .right)
  case 2: return (.bottom, .center)
  case 3: return (.center, .left)
  default: fatalError()
  }
}

let centeredEdge : (CGPoint) -> BoundingBoxState = {point in return BoundingBoxState(
  centers: edges(in:),
  redefine: point |> curry(mirrorDefinedRect),
  positions: edgePositions)
}


// HANDLEVIEW
// A rect input machine
class HandleViewRound1: UIView {
  // Collection of functions
    enum State {
      case corner
      case edge
      case centeredEdge
    }
  
  // whole class properties
  var stateMachine : BoundingBoxState!
  var handles : [UIView] = [] // Clockwise from topLeft
  var point : TensionedPoint!
  let buttonSize = CGSize(44, 44)
  var handler : ( CGRect, (VerticalPosition,HorizontalPosition))->() = { _,_ in }
  var completed : (CGRect,(VerticalPosition,HorizontalPosition))->() = { _, _ in }
  var outlines: [AnyLayout<UIView>] = []
  var hideables: [Hideable] = []
  var outerBoundaryView : UIView!
  public var lastMaster : CGRect

  
  convenience init(frame: CGRect, state: State, handler: @escaping (CGRect,
    (VerticalPosition,HorizontalPosition))->() )
  {
    self.init(frame: frame, state: state)
    self.handler = handler
  }
  
  // Main init
    init(frame: CGRect, state: State )
  {
    let rectangle = CGRect(x: 120, y: 140, width: 200, height: 200)
    self.lastMaster = rectangle
    
    switch state {
    case .corner:
      stateMachine = cornerState
    case .edge:
      stateMachine = edgeState
    case .centeredEdge:
      //self.safeAreaLayoutGuide.centerXAnchor
      stateMachine = centeredEdge(frame.center)
    }
    
    super.init(frame: frame)
    
    outerBounds = self.bounds.insetBy(dx: 20, dy: 20)
    
    
    // Handles...
    let buttonCenters : [CGPoint] = stateMachine.centers( rectangle)
    
    // Set handles
    handles = buttonCenters.map {
      let v = ButtonView(frame:  buttonSize.asRect())
      v.center = $0
      v.callBack = self.press(_:)
      return v
    }
    //...Handles
    
    // Create Background View
    
    // Create Borders ...
    let b1 = UIView()
    b1.layer.borderWidth = 1.0
    b1.layer.borderColor = UIColor.gray.cgColor
    
    // Make Layouts for outlines
    outlines += [AnyLayout(b1)]
    hideables = [b1]
    for var o in outlines { o.layout(in: rectangle)}
    //for var h in hideables { h.isHidden = true }
    // ... End borders
    

    // Order Subviews and add to view
    for v in [b1]  + handles { self.addSubview(v) }
    

  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  

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
      
      // When starting a new handle move first get offset from center of ui handle button
      initialOffset = (gesture.view!.center - loc).asPoint()
      
      
      // Create Master rectangle from newly moved point and other points
      let indexOfHandle = handles.index(of: gesture.view!)!
      let m1 = stateMachine.redefine(indexOfHandle, handles.map{$0.center})
      
      
      frozenBounds = insetIf( m1)
      
      // Show Border
      for var h in hideables { h.isHidden = false }

      
    case .changed:
      
      // The target origin
      let t = loc + initialOffset.asVector()
      
      // bounds rects
      let me = boundsChecking(handles.index(of:gesture.view!)!, outerBounds, frozenBounds)
      
      
      // set point thats being moved
      point = t.tensionedPoint(within: me)
      gesture.view?.center = point.projection
      
      // Create Master rectangle from newly moved point and other points
      let indexOfHandle = handles.index(of: gesture.view!)!
      let master2 = stateMachine.redefine(indexOfHandle, self.handles.map{$0.center})

      
      // update all handles to correct points
      let centers = stateMachine.centers(master2)
      for t in zip(centers, handles) { t.1.center = t.0 }
      
      // layout my view's outlines
      for var outline in outlines {
        outline.layout(in: master2)
      }


      
      let positions = stateMachine.positions(indexOfHandle)
      self.handler(master2, positions)
      
      self.lastMaster  = master2
    case .ended:
      // Show Border
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
      
      
      // layout my view's outlines
      for var outline in self.outlines {
        outline.layout(in: master)
      }
      
       self.lastMaster  = master
      
      
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
      

      me = outerBoundaryRect.bottomLeft + frozenBounds.topRight

    default:
      fatalError()
    }
    return me
  }
  
}
