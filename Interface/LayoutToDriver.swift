//
//  LayoutToDriver.swift
//  HandlesRound1
//
//  Created by Justin Smith on 6/20/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit
import Layout

import Layout
import Geo




public struct PointIndex2 : Equatable {
  public let xI, yI : Int
  public init( xI: Int, yI: Int) {
    (self.xI, self.yI) = (xI, yI)
  }
}

public struct Edge2<Content> where Content : Codable {
  public var content : Content
  public var p1 : PointIndex2
  public var p2 : PointIndex2
  
  public init( content: Content, p1: PointIndex2, p2: PointIndex2 ) {
    self.content = content
    self.p1 = p1
    self.p2 = p2
  }
}

public struct Changed<A: Equatable> {
  private(set) var changed : A?
  var value: A { return previous }
  mutating func update(_ val: A) {
    // Update changed
    if previous != val { changed = val }
    else { changed = nil }
    // Update previous
    previous = val
  }
  private var previous: A
  init(_ value: A) {
    previous = value
    changed = value
  }
}
