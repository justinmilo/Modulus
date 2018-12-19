//
//  Label.swift
//  BlackCricket
//
//  Created by Justin Smith on 12/1/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation

public struct Label : Geometry {
  public enum Rotation { case h, v }
  public var text : String
  public var position : CGPoint = CGPoint.zero
  public var rotation : Rotation = .h
  
  public init(text: String, position: CGPoint, rotation: Rotation) {
    (self.text, self.position, self.rotation) = (text, position, rotation)
  }
}
extension Label {
  public init(text: String) { self.text = text }
}



func setLabel(_ l: Label, _ s: String) -> Label {
  var l = l
  l.text = s
  return l
}

func swapRotation(_ label: Label) -> Label {
  var label = label
  label.rotation = (label.rotation == .h) ? .v : .h
  return label
}

