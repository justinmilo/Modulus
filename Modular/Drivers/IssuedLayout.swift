//
//  IssuedLayout.swift
//  HandlesRound1
//
//  Created by Justin Smith on 7/8/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Layout

struct IssuedLayout<Child : Layout> : Layout {
  mutating func layout(in rect: CGRect) {
    issuedRect = rect
    self.child.layout(in: issuedRect!)
  }
  
  var contents: [Child.Content] { return child.contents }
  typealias Content = Child.Content
  var issuedRect : CGRect? = nil
  var child: Child
  public init( child : Child) { self.child = child}
}
