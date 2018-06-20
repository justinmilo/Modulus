//
//  PositionedLayout.swift
//  Layout
//
//  Created by Justin Smith on 6/19/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation
import Geo

/// Layout that generates layout from childs virtual size
public struct PositionedLayout<Child> : Layout where Child : Layout
{
  var child : Child
  var aligned : (HorizontalPosition, VerticalPosition)
  var size: CGSize
  
  public init(child:Child, ofSize size: CGSize, aligned:(HorizontalPosition, VerticalPosition) ) {
    self.child = child
    self.aligned = aligned
    self.size = size
  }
  
  /// Return all of the leaf content elements contained in this layout and its descendants.
  public var contents: [Child.Content] { return child.contents }
  
  mutating public func layout(in rect: CGRect) {
    let newFrame = rect.withInsetRect(ofSize: size, hugging: aligned)
    child.layout(in: newFrame)
  }
  
  public typealias Content = Child.Content
}
