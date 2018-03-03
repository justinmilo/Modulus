//
//  SliceCore.swift
//  HandlesRound1
//
//  Created by Justin Smith on 3/1/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics


func plan(_ p3: Point3) -> CGPoint { return CGPoint(x: p3.x, y: p3.y) }
func front(_ p3: Point3) -> CGPoint { return CGPoint(x: p3.x, y: p3.z) }
func side(_ p3: Point3) -> CGPoint { return CGPoint(x: p3.y, y: p3.z) }
func plan(_ cedge: CEdge) -> C2Edge { return C2Edge(content: cedge.content, p1: cedge.p1 |> plan, p2: cedge.p2 |> plan ) }
func front(_ cedge: CEdge) -> C2Edge { return C2Edge(content: cedge.content, p1: cedge.p1 |> front, p2: cedge.p2 |> front ) }
func side(_ cedge: CEdge) -> C2Edge { return C2Edge(content: cedge.content, p1: cedge.p1 |> side, p2: cedge.p2 |> side ) }
func plan(_ edges: [CEdge]) -> [C2Edge] { return edges.map(plan) }
func front(_ edges: [CEdge]) -> [C2Edge] { return edges.map(front) }
func side(_ edges: [CEdge]) -> [C2Edge] { return edges.map(side) }

// Front edge has the same 0 y index
func frontEdge(edge:Edge)-> Bool
{
  switch(edge.p1, edge.p2)
  {
    // Front edge has the same 0 y index
  //    (x,y,z)
  case ((_,0,_), (_,0,_)):
    return true
  default:
    return false
  }
}

// Front edge has the same 0 y index
func sideEdge(edge:Edge)-> Bool
{
  switch(edge.p1, edge.p2)
  {
    // Same edge has the same 0 y index
  //    (x,y,z)
  case ((0,_,_), (0,_,_)):
    return true
  default:
    return false
  }
}

// Front edge has the same 0 y index
func planEdge(edge:Edge)-> Bool
{
  switch(edge.p1, edge.p2)
  {
    // Same edge has the same 0 y index
  //    (x,y,z)
  case ((_,_,0), (_,_,0)):
    return true
  default:
    return false
  }
}

func frontSection() -> Parse<[C2Edge]>
{
  return Parse { (graphC) -> [C2Edge] in
    let items = graphC.1.filter(frontEdge)
    return (graphC.0, items) |> cedges >>> front
  }
}

func sideSection() -> Parse<[C2Edge]>
{
  return Parse { (graphC) -> [C2Edge] in
    let items = graphC.1.filter(sideEdge)
    return (graphC.0, items) |> cedges >>> side
  }
}
func planSection() -> Parse<[C2Edge]>
{
  return Parse { (graphC) -> [C2Edge] in
    let items = graphC.1.filter(sideEdge)
    return (graphC.0, items) |> cedges >>> side
  }
}


func fromPlan(elev:CGFloat) -> (CGSize) -> CGSize3     { return {    CGSize3(width: $0.width, depth:  $0.height, elev:  elev)} }
func fromFront(depth:CGFloat) -> (CGSize) -> CGSize3   { return {  CGSize3(width: $0.width, depth:  depth, elev:  $0.height)} }
func fromSide(width:CGFloat) -> (CGSize) -> CGSize3    { return {   CGSize3(width: width, depth:  $0.width, elev:  $0.height)} }

