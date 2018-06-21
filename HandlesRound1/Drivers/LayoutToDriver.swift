//
//  LayoutToDriver.swift
//  HandlesRound1
//
//  Created by Justin Smith on 6/20/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit
import Layout

struct LayoutToDriver : Layout
{
  typealias Content = UIView
  
  var child: ViewDriver
  var prevOrigin: CGPoint
  var prevSize: CGSize
  
  public init( child: ViewDriver){
    self.child = child
    self.prevSize = CGSize.zero
    self.prevOrigin = CGPoint.zero
  }
  mutating func layout(in rect: CGRect) {
    if prevOrigin != rect.origin {
      child.layout(origin: rect.origin)
    }
    if prevSize != rect.size {
      child.layout(size: rect.size)
    }
    prevOrigin = rect.origin
    prevSize = rect.size
  }
  
  var contents: [UIView] { return [self.child.content] }
}
