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
  func layout(origin: CGPoint)
  mutating func layout(size: CGSize)
  mutating func bind(to uiRect: CGRect)
  var content : UIView { get }
}
