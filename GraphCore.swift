//
//  GraphCore.swift
//  HandlesRound1
//
//  Created by Justin Smith on 3/1/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics

func add(edges:[Edge], new:Edge)-> [Edge]
{
  if  (edges, new) |> contains {
    return edges
  }
  else {
    return edges + [new]
  }
}
func remove(edges:[Edge], new:Edge) -> [Edge]
{
  let index = edges.index(of: new)
  
  if let index = index {
    var edges = edges
    edges.remove(at: index)
    return edges
  }
  return edges
}

func contains(edges:[Edge], new:Edge)-> Bool
{
  return edges.contains{ $0 == new }
}



func indicesToPositions(
  p:GraphPositions2DSorted,
  index: (Int, Int)
  ) -> (CGFloat, CGFloat)
{
  return (p.pX[index.0], p.pY[index.1])
}


func pi2p3(graph: GraphPositions, index: PointIndex) -> Point3
{
  return (graph.pX[ index.xI],
          graph.pY[ index.yI ],
          graph.pZ[index.zI])
    |> Point3.init
}
func e2S3 (graph: GraphPositions, edges: [Edge]) -> [Segment3]
{
  return edges.map { e in
    ((graph, e.p1 ) |> pi2p3,
     (graph, e.p2 ) |> pi2p3)
      |> Segment3.init
  }
}




func combineSegments(_ lhs: [CGFloat], _ rhs: [CGFloat]) -> [CGFloat]
{
  // combine segments
  // [100, 200] + [100, 50] => [100, 50, 150]
  // [50, 200, 200] + [400, 50] => [50, 200, 150, 50, 50]
  
  
  func c(l:ArraySlice<CGFloat>, r: ArraySlice<CGFloat>, sum: [CGFloat]) -> [CGFloat]
  {
    guard let left = l.first else { return sum + r }
    guard let right = r.first else { return sum + l }
    
    if left < right {
      return c(
        l: l.dropFirst(),
        r: [right - left] + r.dropFirst(),
        sum: sum + [left] )
    }
    else if right < left {
      return c(
        l: [left - right] + l.dropFirst(),
        r: r.dropFirst(),
        sum: sum + [right] )
    }
    else if right == left {
      return c(
        l: l.dropFirst(),
        r: r.dropFirst(),
        sum: sum + [left] )
    }
    fatalError()
  }
  
  return c(l: ArraySlice(lhs), r: ArraySlice(rhs), sum: [])
  
}


func add(graph: GraphPositions, cedge: CEdge) ->  (GraphPositions, Edge)
{
  let (graph1, p1) = (graph, cedge.p1) |> addNodeWith
  let (graph2, p2) = (graph1, cedge.p2) |> addNodeWith
  return (
    graph2,
    Edge(content: cedge.content, p1: p1, p2: p2)
  )
}

func value(graph: GraphPositions, index: PointIndex) -> (CGFloat,CGFloat,CGFloat)
{
  return (graph.pX[index.xI],
          graph.pY[index.yI],
          graph.pZ[index.zI])
}

func cedge(graph: GraphPositions, edge: Edge) -> (CEdge)
{
  return CEdge(content: edge.content,
               p1: (graph, edge.p1) |> value |> Point3.init,
               p2: (graph, edge.p2) |> value |> Point3.init)
}

func addNode(graph: GraphPositions, node: Point3 ) -> GraphPositions
{
  return GraphPositions(
    pX: (graph.pX, node.x) |> addIf,
    pY: (graph.pY, node.y) |> addIf,
    pZ: (graph.pZ, node.z) |> addIf)
}

func addNodeWith(graph: GraphPositions, node: Point3 ) -> (GraphPositions, PointIndex)
{
  let pX = (graph.pX, node.x) |> addWith
  let pY = (graph.pY, node.y) |> addWith
  let pZ = (graph.pZ, node.z) |> addWith
  return (
    GraphPositions(
      pX: pX.0,
      pY: pY.0,
      pZ: pZ.0),
    (xI: pX.1, yI:pY.1, zI:pZ.1))
}

func cedgeMaker(_ grid: GraphPositions) -> (Edge) -> (CEdge)
{
  return  { (grid, $0) |> cedge }
}

func addIf(positions: [CGFloat], node: CGFloat) -> [CGFloat]
{
  if positions.contains(node) { return positions }
  
  return positions + [node]
}

func addWith(positions: [CGFloat], node: CGFloat) -> ([CGFloat], Int)
{
  if let i = positions.index(of: node)
  {
    return (positions, i)
  }
  
  return (positions + [node], positions.count)
}





func segToPos ( seg: GraphSegments) -> GraphPositions
{
  return GraphPositions(
    pX: seg.sX |> segToPos,
    pY: seg.sY |> segToPos,
    pZ: seg.sZ |> segToPos)
}
func posToSeg ( pos: GraphPositions ) -> GraphSegments
{
  return GraphSegments(
    sX: pos.pX |> posToSeg,
    sY: pos.pY |> posToSeg,
    sZ: pos.pZ |> posToSeg)
}

func maxEdges ( pos: GraphPositions) -> PointIndex
{
  return (pos.pX.count, pos.pY.count, pos.pZ.count)
}




func segToPos ( seg: [CGFloat] ) -> [CGFloat]
{
  // Without Origin we assume zero. first position is either origin or zero
  return seg.reduce([0.0])
  {
    (res, current) -> [CGFloat] in
    return res + [(res.last ?? 0.0) + current]
  }
}

func posToSeg ( pos: [CGFloat] ) -> [CGFloat]
{
  let pos = pos.sorted()
  // Without Origin we assume zero. first position is either origin or zero
  let zp = zip( pos , pos.dropFirst() ).map
  {
    return $0.1 - $0.0
  }
  return Array(zp)
}



func reduceDup (_ array: [C2Edge] ) -> [C2Edge] {
  
  return array.reduce([]) { (res, ed) -> [C2Edge] in
    if res.contains(where: { ed == $0 }) {
      return res
    }
    return res + [ed]
  }
}




func mapEdges( ed: [Edge], ceMak: (Edge) -> (CEdge)) -> [CEdge] { return ed.map( ceMak) }

func reduceZeros(_ array: [C2Edge] ) -> [C2Edge] {
  return array.filter(filterLedgers)
}

func positionSorted(p: GraphPositions) -> GraphPositions
{
  return GraphPositions(pX: p.pX.sorted(), pY: p.pY.sorted(), pZ: p.pZ.sorted())
}

func posToSize(position: GraphPositions) -> CGSize3
{
  let position = position |> positionSorted
  
  return CGSize3(
    width: position.pX.last! - position.pX.first! ,
    depth: position.pY.last! - position.pY.first!,
    elev: position.pZ.last! - position.pZ.first!)
}

func dropBottomZBay( position: GraphPositions ) -> GraphPositions
{
  return GraphPositions(pX: position.pX, pY: position.pY, pZ: Array(position.pZ.dropFirst()) )
}


func filterBelow (max: PointIndex, point:PointIndex) -> Bool
{
  // max a count semantic so
  // [1,1] = count 2, 2 is greater than
  if point.xI >= max.xI {
    return false
  }
  if point.yI >= max.yI {
    return false
  }
  if point.zI >= max.zI {
    return false
  }
  return true
}
func filterEdgeBelow (max:@escaping (PointIndex) -> Bool) -> (Edge) -> Bool
{
  return { edge in
    return edge.p2 |> max && edge.p1 |> max
  }
}

func filter<A>(_ t: (A)->Bool, _ array: [A]) -> [A]
{
  return array.filter(t)
}
