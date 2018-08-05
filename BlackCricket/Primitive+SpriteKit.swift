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


public protocol SKRepresentable
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


func flip<A, C>(_ f: @escaping (A) -> () -> C)
  -> () -> (A) -> C {
  return { { a in f(a)() } }
}


let asVector = zurry(flip(CGPoint.asVector))
let negated = zurry(flip(CGVector.negated))
let asNegatedVector = asVector >>> negated

func moveNode(by vectorP: CGVector) -> (SKNode) -> Void
{
  return {  $0.position = $0.position + vectorP }
}


extension Oval : SKRepresentable
{
  var asNode: SKNode {
    return createOval(self)
  }
}
extension Label : SKRepresentable
{
  public var asNode: SKNode {
    return createLableNode(self)
  }
}
extension Line : SKRepresentable
{
  public var asNode: SKNode {
    return createLineShapeNode(self)
  }
}
extension StrokedLine : SKRepresentable
{
  var asNode: SKNode {
    return createLineShapeNode(self.line)
  }
}
extension LabeledPoint : SKRepresentable
{
  var asNode: SKNode {
    let circleN = createCircleShapeNode(self)
    let n = createLableNode(Label(text: self.label))
    n.position = self.position
    circleN.addChild(n)
    
    return circleN

  }
}
extension TextureLine : SKRepresentable
{
  var asNode: SKNode {
     fatalError()
  }
}





func createOval(_ oval: Oval) -> SKShapeNode
{
  let node = SKShapeNode(ellipseOf: oval.ellipseOf)
  node.fillColor = oval.fillColor
  node.lineWidth = 0.0
  return node
}



func createLableNode(_ label: Label) -> SKLabelNode {
  let node = SKLabelNode(text: label.text)
  node.fontName = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium).fontName
  node.fontSize = 14// * scale
  node.zRotation = label.rotation == .h ? 0.0 : 0.5 * CGFloat.pi
  node.position = label.position
  node.verticalAlignmentMode = .center
  return node
}

func changeFontColor(color: UIColor, _ node: SKLabelNode) {
  node.fontColor = color
}

public func createLineShapeNode(_ line: Line) -> SKShapeNode {
  let path = CGMutablePath()
  path.move(to: line.start)
  path.addLine(to: line.end)
  let node = SKShapeNode(path: path)
  return node
}

func createCircleShapeNode(_ line: Geometry) -> SKShapeNode {
  let rectSize = CGSize(5,5)
  let path = CGMutablePath()
  path.move(to: line.position)
  path.addEllipse(in: CGRect.around(line.position, size: rectSize))
  let node = SKShapeNode(path: path)
  return node
}



func scaleTransform( _ scale: CGFloat) -> (SKNode)-> Void
{
  return {skNode in
    skNode.setScale(scale)
  }
}

func scalePosition( _ scale: CGFloat) -> (SKNode)-> Void
{
  return {skNode in
    skNode.position = skNode.position * scale
  }
}

func highlightStrokeShapeNode(node:SKShapeNode)-> Void
{
  node.lineWidth = 2.0
  node.strokeColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
}



let scaleAll : (CGFloat) -> (SKNode)-> Void = scaleTransform <> scalePosition
