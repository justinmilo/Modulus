//
//  CGRect+Inset.swift
//  HandlesRound1
//
//  Created by Justin Smith on 5/26/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics
import Geo

// Fixme graphics shouldent depending on POSITION

extension CGRect {
  public func withInsetRect(ofSize size: CGSize, hugging walls: (VerticalPosition, HorizontalPosition) ) -> CGRect
  {
    
    let rect = self
    let c = size
    
    let x : CGFloat
    switch walls.1 {
    case .left:
      x = rect.origin.x
    case .center:
      x = rect.origin.x + (rect.width - c.width) / 2
    case .right:
      x = rect.origin.x + rect.width - c.width
    }
    
    let y : CGFloat
    switch walls.0 {
    case .top:
      y = rect.origin.y
    case .center:
      y = rect.origin.y + (rect.height - c.height) / 2
    case .bottom:
      y = rect.origin.y + rect.height - c.height
    }
    
    let newFrame = CGRect(x: x, y: y, width: size.width, height: size.height)
    
    
    return newFrame
    
  }
  
  public func minimumSquare(hugging positions: (VerticalPosition, HorizontalPosition) ) -> CGRect
  {
    let rect = self
    let squareRect = CGRect(x:0,y:0,width:50,height:50).filling(to: rect)
    var offsetX : CGFloat = 0.0, offsetY : CGFloat = 0.0
    switch positions.1 {
    case .left:
      break
    case .center:
      offsetX = rect.width / 2 - squareRect.width / 2
    case .right:
      offsetX = rect.width - squareRect.width
    }
    switch positions.0 {
    case .top:
      break
    case .center:
      offsetY = rect.height / 2 - squareRect.height / 2
    case .bottom:
      offsetY = rect.height - squareRect.height
    }
    let movedRect = squareRect.offsetBy(dx: offsetX, dy: offsetY)
    
    return movedRect
  }
}
