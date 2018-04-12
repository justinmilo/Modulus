//
//  HandlesView.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics
import UIKit

protocol Hideable {
  var isHidden: Bool { get set }
}
extension UIView : Hideable { }


// HANDLEVIEW
// A rect input machine
class HandleViewRound1: UIView {
  // Collection of functions

  
  // whole class properties
  private var stateMachine : BoundingBoxState!
  private var handles : [UIView] = [] // Clockwise from topLeft
  private let buttonSize = CGSize(44, 44)
  private var outlines: [AnyLayout<UIView>] = []
  private var hideables: [Hideable] = []
  private var outerBoundaryView : UIView!
  
  public var handler :   ( (CGRect, Position2D)->() )?
  public var completed : ( (CGRect, Position2D)->() )?
  
  public var lastMaster : CGRect
  public var outerBounds : CGRect?
  
  // Main init
  override init(frame: CGRect)
  {
    
    stateMachine = centeredEdge
    lastMaster = frame.center.asRect()
    
    // Create Background View
    
    // Create Borders ...
    let b1 = UIView()
    b1.layer.borderWidth = 1.0
    b1.layer.borderColor = UIColor.gray.cgColor
    frozen = UIView()
    b1.layer.borderWidth = 1.0
    b1.layer.borderColor = UIColor.gray.cgColor
    outlines += [AnyLayout(b1)] // Make Layouts for outlines, could be
    hideables = [b1] // collect in hideables array
    // ... End borders
    

    
    
    super.init(frame: frame)
    
    // Handles...
    // Set handles (captures self)
    handles = (0..<4).map {_ in
      let v = ButtonView(frame:  buttonSize.asRect())
      v.callBack = self.press(_:)
      return v
    }
    //...Handles
    
    
    // Order Subviews and add to view
    for v in [b1,frozen]  + handles { self.addSubview(v) }
    

  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  private var frozen : UIView
  private var point : TensionedPoint!
  private var initialOffset = CGPoint.zero // delta between touchDown center and handle center
  private var frozenBounds : CGRect?
  
  @objc func press( _ gesture:UIGestureRecognizer )
  {
    let loc = gesture.location(in: gesture.view!.superview!)
    
    switch gesture.state
    {
    // set initial offset and frozenB
    case .began:
      
      // When starting a new handle move first get offset from center of ui handle button
      initialOffset = (gesture.view!.center - loc).asPoint()
      
      
      // Create frozenBounds rectangle from newly moved point and other points
      let indexOfHandle = handles.index(of: gesture.view!)!
      let handleDefinedRect = stateMachine.redefine(self.frame.center,  indexOfHandle, handles.map{$0.center})
      frozenBounds = insetIf( handleDefinedRect, buttonSize: buttonSize)
      frozen.layout(in: frozenBounds!)
      
      // Show Border
      for var h in hideables { h.isHidden = false }

      
    case .changed:
      
      // The target origin
      let t = loc + initialOffset.asVector()
      
      // bounds rects
      let resolvedRect = boundsChecking(handles.index(of:gesture.view!)!, outerBounds!, frozenBounds!)
      
      
      // set point thats being moved
      point = t.tensionedPoint(within: resolvedRect)
      gesture.view?.center = point.projection
      
      // Create Master rectangle from newly moved point and other points
      let indexOfHandle = handles.index(of: gesture.view!)!
      let master2 = stateMachine.redefine(self.frame.center, indexOfHandle, self.handles.map{$0.center})

      
      // update all handles to correct points
      let centers = stateMachine.centers(master2)
      for t in zip(centers, handles) { t.1.center = t.0 }
      
      // layout my view's outlines
      for var outline in outlines {
        outline.layout(in: master2)
      }


      
      let positions = stateMachine.positions(indexOfHandle)
      self.handler?(master2, positions)
      
      self.lastMaster  = master2
    case .ended:
      // Show Border
      for var h in hideables { h.isHidden = true }

      UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
        gesture.view?.center = self.point.anchor
        
        // Create Master rectangle from gesture
        let indexOfHandle = self.handles.index(of: gesture.view!)!
        let master2 = self.stateMachine.redefine(self.frame.center, indexOfHandle, self.handles.map{ $0.center })
      
        // update all handles to correct points
        let centers = self.stateMachine.centers(master2)
        for t in zip(centers, self.handles) { t.1.center = t.0 }
        
        let positions = self.stateMachine.positions(indexOfHandle)
        self.handler?(master2, positions)
        self.completed?(master2, positions)
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
  
  
  
  
}
