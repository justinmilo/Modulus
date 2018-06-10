//
//  Primitive+UIKit.swift
//  HandlesRound1
//
//  Created by Justin Smith on 4/19/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import SpriteKit
import Singalong
import Geo


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


func zurry<B>(_ g: ()->B ) -> B
{
  return g()
}
func flip<A, C>(_ f: @escaping (A) -> () -> C) -> () -> (A) -> C {
  return { { a in f(a)() } }
}

let asVector = zurry(flip(CGPoint.asVector))
let negated = zurry(flip(CGVector.negated))
let asNegatedVector = asVector >>> negated

func moveNode(by vectorP: CGVector) -> (SKNode) -> Void
{
  return {  $0.position = $0.position + vectorP }
}
