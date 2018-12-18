//
//  Primitive+UIKit.swift
//  HandlesRound1
//
//  Created by Justin Smith on 4/19/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit

protocol UIKitRepresentable
{
  var asView : UIView { get }
}



extension Label : UIKitRepresentable {
  var asView: UIView {
    let l = UILabel()
    l.text = self.text
    l.center = self.position
    l.transform = l.transform.rotatedBy(degrees: 90.0)
    return l
  }
}

import Diagrams
import Geo

extension Line : Drawable{
  public func draw(in renderer: Renderer) {
    renderer.move(to: self.start)
    renderer.addLine(to: self.end)
  }
  public var frame: CGRect {
    return self.start + self.end
  }
}

