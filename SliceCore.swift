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


let sizeFront : (ScaffGraph) -> (CGSize) -> CGSize3 = {graph in { CGSize3(width: $0.width, depth: graph.bounds.depth, elev: $0.height) } }

typealias DimGenerating = (CGSize) -> CGSize3

let overall : (@escaping DimGenerating) -> (CGSize, [Edge]) ->  (GraphPositions, [Edge]) = { addDim in

  return { size, edges in
  
  let bo = addDim >>> generateSegments >>> segToPos
  let pos = size |> addDim >>> generateSegments >>> segToPos
  let max = pos |> maxEdges
  
  //let edges = maxClip(max: max, edges: edges)
  let edge1 = clipOne(max: max, t: lensZ, edges:edges)
  let edge2 = clipOne(max: max, t: lensX, edges:edge1)
  let edge3 = clipOne(max: max, t: lensY, edges:edge2)
  
  
  let s = ScaffGraph( grid : pos, edges : [])
  s.addScaff()
  
  let combined  =  edge3 + s.edges.filter { !edge3.contains($0) }
  
  let combinedRemovedStandard : [Edge] = combined.reduce([]) {
    res,next in
    
    let i = res.index(where: { (edge) -> Bool in
      return edge.content == "StandardGroup" &&
        (edge.p1 == next.p1 ||
          edge.p2 == next.p2)
      
    })
    if let i = i {
      let existing = res[i]
      
      if abs(existing.p1.zI - existing.p2.zI) > abs(next.p1.zI - next.p2.zI)
      {
        return res
      }
      else {
        var mutating = res
        mutating.remove(at: i)
        return mutating + [next]
      }
    }
    
    return res + [next]
  }
  
  return (pos, combinedRemovedStandard)
  }
  
}

typealias BayIndex = (x: Int, y: Int)
typealias BayIndex3 = (x: Int, y: Int, z:Int)

func addY(y: Int, pi: PointIndex2D) -> PointIndex
{
  return (xI: pi.x, yI: y, zI: pi.y)
}



struct IndexVector{ var (x, y, z) : (Int, Int, Int) }
extension IndexVector { init(_ xI: Int, _ yI: Int, _ zI: Int) { (x, y, z) = (xI, yI, zI) } }

func vectorIndexFrom(i1 : PointIndex, i2: PointIndex) -> IndexVector
{
  return IndexVector(x: i1.xI - i2.xI, y: i1.yI - i2.yI, z: i1.zI - i2.zI)
}



func points( edge: Edge ) -> (PointIndex, PointIndex)
{
  return (edge.p1, edge.p2)
}

let edgeVector : (Edge)->IndexVector = points >>> vectorIndexFrom
let xDiagUp = IndexVector  ( 1, 0,  1)
let xDiagDown = IndexVector( 1, 0, -1)
let yDiagUp = IndexVector  ( 0, 1,  1)
let yDiagDown = IndexVector( 0, 1, -1)

let edgeXDiagUp = Predicate<Edge>{ xDiagUp == $0 |>  edgeVector }
let edgeXDiagDown = Predicate<Edge>{ xDiagDown == $0 |>  edgeVector }

let bayToPosition : ( Int ) -> (Int, Int) = { return ($0, $0 + 1)}

let xPos : (Int) -> Predicate<Edge> = {
  i in
  return Predicate<Edge>{ (e : Edge) -> Bool in
    return (e.p1.xI == i || e.p2.xI == i)
  }
}

let yPos : (Int) -> Predicate<Edge> = {
  i in
  return Predicate<Edge>{ (e : Edge) -> Bool in
    return (e.p1.yI == i || e.p2.yI == i)
  }
}

let zPos : (Int) -> Predicate<Edge> = {
  i in return Predicate{ ($0.p1.zI == i || $0.p2.zI == i) }
}

let xBay : (Int) -> Predicate<Edge> =  {
  i in
  let pI = i |> bayToPosition
  return  xPos(pI.0) && xPos(pI.1)
}

let yBay : (Int) -> Predicate<Edge> =  {
  i in
  let pI = i |> bayToPosition
  return  yPos(pI.0) && yPos(pI.1)
}

let zBay : (Int) -> Predicate<Edge> =  {
  i in
  let pI = i |> bayToPosition
  return  zPos(pI.0) && zPos(pI.1)
}

func anyDiagTest(edges: [Edge], bayIndex:BayIndex )->[Edge] {
  print(
"""
    index: \(bayIndex)
    x: \(edges.filtered(by: xBay(bayIndex.x )))
    y: \(edges.filtered(by: zBay(bayIndex.y)))
    x&y: \(edges.filtered(by:  (xBay(bayIndex.x) && zBay(bayIndex.y))))
    diags: \(edges.filtered(by:  (edgeXDiagUp || edgeXDiagDown)))
    all: \(edges.filtered(by:  (xBay(bayIndex.x) && zBay(bayIndex.y)) && (edgeXDiagUp || edgeXDiagDown)))
""")
  
  
  return edges.filtered(by: (xBay(bayIndex.x) && zBay(bayIndex.y)) && (edgeXDiagUp || edgeXDiagDown))
}

let diagLeft: (BayIndex) -> Predicate<Edge> =
{
  let (p1x, p2x) = highToLow(gIndex: $0)
  return Predicate {
    edge in
    
    let p1_3 = p1x |> (curry(addY)(edge.p1.yI))
    let p2_3 = p2x |> curry(addY)(edge.p2.yI)
    
    let testEdge = Edge(content: "_test", p1:p1_3, p2: p2_3)
  return edge == testEdge
  }
}
let diagRight: (BayIndex) -> Predicate<Edge> =
{
  let (p1x, p2x) = lowToHigh(gIndex: $0)
  return Predicate<Edge> {
    edge in
    
    let p1_3 = p1x |> (curry(addY)(edge.p1.yI))
    let p2_3 = p2x |> curry(addY)(edge.p2.yI)
    
    let testEdge = Edge(content: "_test", p1:p1_3, p2: p2_3)
    return edge == testEdge
  }
}



let inBayIndex: (BayIndex) -> Predicate<Edge> =
{
  let (p1x, p2x) = lowToHigh(gIndex: $0)
  return Predicate {
    edge in
    
    let p1_3 = p1x |> (curry(addY)(edge.p1.yI))
    let p2_3 = p2x |> curry(addY)(edge.p2.yI)
    
    let testEdge = Edge(content: "_test", p1:p1_3, p2: p2_3)
    return edge == testEdge
  }
}



func iv2tup ( iv : IndexVector) -> (x: Int, y:Int, z:Int)
{
  return (x: iv.x,
          y: iv.y,
          z: iv.z)
}



func oppossiteIndexVector(iv:IndexVector) -> IndexVector {
  return IndexVector(x: -iv.x, y: -iv.y, z: -iv.z)
}

func ==(lhs:IndexVector, rhs:IndexVector) -> Bool {
  return  lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z ||
    lhs.x == -rhs.x && lhs.y == -rhs.y  && lhs.z == -rhs.z
}



//var basicBayTransform : ([Edge], BayIndex3) -> (added:[Edge], removed:[Edge])
