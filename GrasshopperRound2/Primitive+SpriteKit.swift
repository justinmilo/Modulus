//
//  Primitive+UIKit.swift
//  HandlesRound1
//
//  Created by Justin Smith on 4/19/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import SpriteKit

protocol SKRepresentable
{
  var asNode : SKNode { get }
}

extension ColoredLabel : SKRepresentable
{
  var asNode: SKNode {
    let colr_trans = curry(changeFontColor)(self.color)
    let newNode = createLableNode(self.asLabel)
    newNode |> colr_trans
    return newNode
  }
}
