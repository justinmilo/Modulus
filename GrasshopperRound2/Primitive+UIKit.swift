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

extension ColoredLabel : UIKitRepresentable
{
  var asView: UIView {
    let uiLabel = UILabel(frame: self.position.asRect() )
    uiLabel.attributedText = NSAttributedString(string: self.text, attributes: [NSAttributedString.Key.foregroundColor : self.color])
    uiLabel.sizeToFit()
    return uiLabel
  }
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
  func draw(in renderer: Renderer) {
    renderer.move(to: self.start)
    renderer.addLine(to: self.end)
  }
  var frame: CGRect {
    return self.start + self.end
  }
}

