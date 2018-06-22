//
//  Driver.swift
//  HandlesRound1
//
//  Created by Justin Smith on 6/20/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit

protocol Driver {
  func size(for size: CGSize) -> CGSize
  
  mutating func layout(origin: CGPoint)
  mutating func layout(size: CGSize)
  mutating func bind(to uiRect: CGRect)
  
  var content : UIView { get }
}

import Geo

class ScaledDriver <Child: Driver> : Driver {
  var scale : CGFloat = 1.0
  var child : Child
  init(child: Child) {
    self.child = child
  }
  func size(for size: CGSize) -> CGSize {
    print("scale:", scale, "givenSize:", size, "Sent size", size * (1/scale), "Returned Size:", child.size(for: size * (1/scale)) * scale)
    return child.size(for: size * (1/scale)) * scale
  }
  
  func layout(origin: CGPoint) {
    child.layout(origin: origin)
  }
  
  func layout(size: CGSize) {
    child.layout(size: size)
  }
  
  func bind(to uiRect: CGRect) {
  }
  
  var content: UIView { return child.content }
}

struct LogDriver <Child: Driver> : Driver {
  var child : Child
  init(child: Child) {
    self.child = child
  }
  func size(for size: CGSize) -> CGSize {
    let newSize = child.size(for: size)
    logStart();
    print("Size", newSize, "for Size", size)
    logEnd()
    return newSize
  }
  
  mutating func layout(origin: CGPoint) {
    child.layout(origin: origin)
    logStart();
    print( "layout origin", origin)
    logEnd()
  }
  
  mutating func layout(size: CGSize) {
    child.layout(size: size)
    logStart();
    print( "layout size", size);
    logEnd()
  }
  
  func bind(to uiRect: CGRect) {
  }
  
  func logStart(){
    print("——————————————————————————")
    print("Child: \(Child.self)")
  }
  
  func logEnd()
  {
    print("——————————————————————————\n")
  }
  
  var content: UIView { return child.content }
}
