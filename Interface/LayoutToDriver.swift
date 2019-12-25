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

/// Layout that generates layout from childs virtual size
public struct PositionedRect
{
  public var aligned : (HorizontalPosition, VerticalPosition)
  public var container: CGSize
  
  var origin : Changed<CGPoint>
  var size : Changed<CGSize>

  public init(ofSize size: CGSize, aligned:(HorizontalPosition, VerticalPosition), initialRect: CGRect ) {
    self.aligned = aligned
    self.container = size
    self.size = Changed(initialRect.size)
    self.origin = Changed(initialRect.origin)
  }
  mutating public func layout(in rect: CGRect) {
    let newFrame = rect.withInsetRect(ofSize: container, hugging: aligned)
    origin.update(newFrame.origin)
    size.update(newFrame.size)
  }
}


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

struct Changed<A: Equatable> {
  private(set) var changed : A?
  var value: A { return previous }
  mutating func update(_ val: A) {
    if previous != val
    { changed = val }
    else { changed = nil }
    previous = val
  }
  private var previous: A
  init(_ value: A) {
    previous = value
  }
}
