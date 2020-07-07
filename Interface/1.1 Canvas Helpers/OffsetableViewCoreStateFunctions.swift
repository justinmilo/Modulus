//
//  OffsetableViewCoreStateFunctions.swift
//  Canvas
//
//  Created by Justin Smith  on 12/8/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation
import Singalong
import OffsetableCore
import Geo
import UIKit

extension CGFloat {
  public func format(f: String) -> String {
    return String(format: "%\(f)f", self)
  }
}


public enum InteractionState {
  case open
  case frozen(incrementAmount : CGVector, edge: SelectionEdge)
  case dragging(incrementAmount : CGVector, edge: SelectionEdge)
  case zooming(previousScale: CGFloat, interimScale : CGFloat)

  var frozen: (incrementAmount : CGVector, edge: SelectionEdge)? {
    get {
      guard case let .frozen(value) = self else { return nil }
      return value
    }
    set {
      guard case .frozen = self, let newValue = newValue else { return }
      self = .frozen(incrementAmount: newValue.incrementAmount, edge: newValue.edge)
    }
  }
  
  var dragging: (incrementAmount : CGVector, edge: SelectionEdge)? {
    get {
      guard case let .dragging(value) = self else { return nil }
      return value
    }
    set {
      guard case .dragging = self, let newValue = newValue else { return }
      self = .dragging(incrementAmount: newValue.incrementAmount, edge: newValue.edge)
    }
  }
  
  var zooming: (previousScale: CGFloat, interimScale : CGFloat)? {
    get {
      guard case let .zooming(value) = self else { return nil }
      return value
    }
    set {
      guard case .zooming = self, let newValue = newValue else { return }
      self = .zooming(previousScale: newValue.previousScale, interimScale: newValue.interimScale)
    }
  }
}

public enum SelectionEdge {
  case top, left, bottom, right
}

//MARK: - Pure Functions
func _clipToInsetsWithPadding(xUnits: O1, yUnits: O1, insets : UIEdgeInsets, padding: CGFloat) -> S2D {
  let yUnitsClipped = clipSeperate(yUnits, insets.top + padding, insets.bottom + padding) |> S3.init
  let xUnitsClipped = clipSeperate(xUnits, insets.left + padding, insets.right + padding) |> S3.init
  
  return (xUnitsClipped |> S2.init, yUnitsClipped |> S2.init) |> zipS2
  
}
func _changeSize (s2: S2D, change: InteractionState, incrementAmount: CGVector) -> S2D {

  var new2 = s2
  switch change {
  case let .dragging(incrementAmount: _, edge: edge):
    switch edge {
    case .top, .left:
      // setting size temporarily resets offset, so set offset last
      new2.master.size += incrementAmount
      new2.size += incrementAmount // Size must be set before offset
      new2.offset += incrementAmount/2
    case .bottom,.right:
      // setting size temporarily resets offset
      new2.master.size += -incrementAmount
      new2.size += -incrementAmount // Size must be set before offset
      new2.offset += -incrementAmount/2
    }
    
  case let .frozen(incrementAmount: _, edge: edge):
    switch edge {
    case .top, .left:
      new2.master.size += -incrementAmount
      new2.size += -incrementAmount
      new2.offset += CGVector.zero
    case .bottom, .right:
      new2.master.size += incrementAmount
      new2.size += incrementAmount
      new2.offset += incrementAmount
      
    }
  case .open,
       .zooming:
    fatalError("can't acll _changeSize with these values")
  }
  
  return new2
    
}



func changeSize(changeType: InteractionState,
                incrementAmount vector:CGVector,
                interiorFrame newSelect: CGRect,
                offset contentOffset: CGPoint,
                size contentSize: CGSize) -> S2D {
let myS2D =  S2D(offset: contentOffset, size: contentSize, master: newSelect)
let changedS2d = _changeSize(s2: myS2D, change: changeType, incrementAmount: vector)
return changedS2d
//return [Effect{ callback in callback(.clipAndAssign(changedS2d, portSize: pb, zoomSize: zoomSize))
}
  
func clipAndAssign(s2D: S2D,
                  portSize sVframeSize: CGSize,
                  zoomScale: CGFloat,
                  clippingInsets: UIEdgeInsets
) -> (twoDSize:CGSize, twoDOffset: CGPoint, selection: CGRect) {
let padding : CGFloat = 40;
//                                               scrollView.zoomScale
let xUnitsScaled =  s2D |> s2DtoS2XDim >>> s2Scaled(scale: zoomScale)
let yUnitsScaled =  s2D |> s2DtoS2YDim >>> s2Scaled(scale: zoomScale)

let twoD = _clipToInsetsWithPadding(
  xUnits: O1(bounds: sVframeSize.width, s2: xUnitsScaled),
  yUnits: O1(bounds: sVframeSize.height, s2: yUnitsScaled),
  insets: clippingInsets,
  padding: padding)

  return (twoDSize:twoD.size, twoDOffset: twoD.offset, selection: twoD.master)
// return state.scale * zoomScale
// Notifications
}

let clipScrollableBoundaries = S2D.init // + clipAndAssign


func addBorder(view: UIView, width: CGFloat, color: UIColor) {
  view.layer.borderColor = color.cgColor
  view.layer.borderWidth = width
}

func fromScrollContentToViewCord(scroll: CGRect, contentOffset: CGPoint) -> CGRect {
  return scroll.offsetBy(dx: -contentOffset.x, dy: -contentOffset.y)
}
func fromViewCordToScrollContent(scroll: CGRect, contentOffset: CGPoint) -> CGRect {
  return scroll.offsetBy(dx: contentOffset.x, dy: contentOffset.y)
}


extension UIView {
  func scaleSubviews (by scale: CGFloat) {
    self.subviews.forEach{
      view in
      view.frame = view.frame.scaled(by:scale)
      view.scaleSubviews(by: scale)
    }
  }
}
