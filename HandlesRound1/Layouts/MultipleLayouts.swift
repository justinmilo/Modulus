//
//  MultipleLayouts.swift
//  Deploy
//
//  Created by Justin Smith on 7/12/17.
//  Copyright © 2017 Justin Smith. All rights reserved.
//

import CoreGraphics

public struct MultipleLayout<Child : Layout> : Layout{
  
  public init(multipleLayouts: [Child])
  {
    self.children = multipleLayouts
  }
  
  public var children : [Child]
  public typealias Content = Child.Content
  
  
  public var contents: [Child.Content]
  {
    return  children.flatMap{ $0.contents }
  }
  public mutating func layout(in rect:CGRect)
  {
    for var c in children{
      c.layout(in: rect)
    }
  }
}
