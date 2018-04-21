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
    uiLabel.attributedText = NSAttributedString(string: self.text, attributes: [NSAttributedStringKey.foregroundColor : self.color])
    uiLabel.sizeToFit()
    return uiLabel
  }
}
