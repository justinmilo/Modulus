//: Playground - noun: a place where people can play

import CoreGraphics

struct GraphSegments
{
  var sX : [CGFloat]
  var sY : [CGFloat]
  var sZ : [CGFloat]
}

struct GraphPositions
{
  var pX : [CGFloat]
  var pY : [CGFloat]
  var pZ : [CGFloat]
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

func segToPos ( seg: GraphSegments) -> GraphPositions
{
  return GraphPositions(
    pX: seg.sX |> segToPos,
    pY: seg.sY |> segToPos,
    pZ: seg.sZ |> segToPos)
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

func posToSeg ( pos: GraphPositions ) -> GraphSegments
{
  return GraphSegments(
    sX: pos.pX |> posToSeg,
    sY: pos.pY |> posToSeg,
    sZ: pos.pZ |> posToSeg)
}


struct Edge
{
  typealias PointIndex = (xI: Int, yI: Int, zI: Int)
  var content : String
  var p1 : PointIndex
  var p2 : PointIndex
}
extension Edge : CustomStringConvertible {
  var description : String { return "\(p1.xI),\(p1.yI),\(p1.zI), -> \(p2.xI),\(p2.yI),\(p2.zI)\n"}
}



struct Point3 {
  var (x, y, z) : (CGFloat,CGFloat,CGFloat)
}
extension Point3 : CustomStringConvertible {
  var description : String { return "\(x), \(y), \(z)"}
}

struct Segment3 {
  var (p1, p2) : (Point3, Point3)
}
extension Segment3 : CustomStringConvertible {
  var description : String { return "\(p1), -> \t\t\t \(p2)\n"}
}

func pi2p3(graph: GraphPositions, index: Edge.PointIndex) -> Point3
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

func addNode(graph: GraphPositions, node: Point3 ) -> GraphPositions
{
  return GraphPositions(
    pX: (graph.pX, node.x) |> addIf,
    pY: (graph.pY, node.y) |> addIf,
    pZ: (graph.pZ, node.z) |> addIf)
}

func addNodeWith(graph: GraphPositions, node: Point3 ) -> (GraphPositions, Edge.PointIndex)
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


struct CEdge
{
  var content : String
  var p1 : Point3
  var p2 : Point3
}
extension CEdge : CustomStringConvertible {
  var description : String { return "\(content) \(p1), -> \t\t\t \(p2)\n"}
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

func value(graph: GraphPositions, index: Edge.PointIndex) -> (CGFloat,CGFloat,CGFloat)
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

func cedges(graph: GraphPositions, edges: [Edge]) -> ([CEdge])
{
  return edges.map( curry(cedge)(graph) )
}



class ScaffGraph{
  init(grid: GraphPositions, edges:[Edge])
  {
    self.grid = grid
    self.edges = edges
  }
  var grid : GraphPositions
  var edges : [Edge]
  
  func addEdge(_ cedge : CEdge) {
    let new = (grid, cedge) |> add
    grid = new.0
    edges.append(new.1)
  }
}


extension ScaffGraph {
  
  func screwJacks(to max:(Int,Int) ) -> [Edge]
  {
    // import part z:0, p2: z:1
    return (0 ..< max.0).flatMap { x in
      (0 ..< max.1).map{ y in
        return Edge(content: "Jack", p1: (x,y,0), p2: (x,y,1))
      }
    }
  }
  
  func everyLedger(xCount:Int, yCount: Int, zCount: Int) -> [Edge]
  {
    let x = zip( (0 ..< xCount), (1 ..< xCount) ).flatMap
    {
      tup in
      
      (0 ..< yCount).flatMap
        { y in
          // Ledgers start at 1
          (1 ..< zCount).map
            { z in
              return Edge(content: "Ledger", p1: (tup.0,y,z), p2: (tup.1,y,z))
          }
      }
    }
    
    let y = (0 ..< xCount).flatMap
    {
      x in
      
      zip( (0 ..< yCount), (1 ..< yCount) ).flatMap
        { yVals in
          // Ledgers start at 1
          (1 ..< zCount).map
            { z in
              return Edge(content: "Ledger", p1: (x,yVals.0,z), p2: (x,yVals.1,z))
          }
      }
    }
    
    return Array(x + y)
  }
  
  
  
 
  
  func everyBC(to xCount:Int, yCount:Int ) -> [Edge]
  {
    // import part (x,y,1), p2: (x,y,1))
    
    return (0 ..< xCount).flatMap { x in
      (0 ..< yCount).map{ y in
        return Edge(content: "BC", p1: (x,y,1), p2: (x,y,1))
      }
    }
  }
  
  
  func addScaff() {
    let g =  grid
    let sj = (g.pX.count, g.pY.count) |> screwJacks
    let l = (g.pX.count, g.pY.count, g.pZ.count) |> everyLedger
    let bc = (g.pX.count, g.pY.count) |> everyBC
    
    
    
    edges += sj + l + bc
    
    let seg = g |> posToSeg
    let standards = [seg.sZ.first!] + ( (g.pZ.last! - g.pZ.first!) |> maximumStandards )
    let stdPositions = standards |> segToPos
    
    let standardEdges = {
      (x : CGFloat,y : CGFloat) -> [CEdge] in
      
      let stdPositions = stdPositions.dropFirst()
      return zip(stdPositions, stdPositions.dropFirst()).map {
        return CEdge(content: "Standard", p1: Point3(x: x, y: y, z: $0.0), p2: Point3(x: x, y: y, z: $0.1))
      }
    }
    
    let standardCedges = g.pX.flatMap { x in
      g.pY.flatMap { y in standardEdges(x, y) } }
    
    (self.grid, self.edges) = standardCedges.reduce( (grid, edges) )
    {
      (res, cedge) -> (GraphPositions, [Edge]) in
      
      let new = (res.0, cedge) |> add
      
      return (new.0, res.1 + [new.1])
    }
  }
}


func maximumStandards(in height:CGFloat) -> [CGFloat]
{
  return maximumRepeated(availableInventory:[50,100], targetMaximum: height)
  
}


struct C2Edge : Equatable{
  var content : String
  var (p1,p2) : (CGPoint, CGPoint)
  
  static func ==(lhs: C2Edge, rhs: C2Edge) -> Bool
  {
    let pointsEqual = (lhs.p1 == rhs.p1 && lhs.p2 == rhs.p2)
      || (lhs.p1 == rhs.p2 && lhs.p2 == rhs.p1)
    return lhs.content == rhs.content && pointsEqual
  }
}

func plan(_ p3: Point3) -> CGPoint { return CGPoint(x: p3.x, y: p3.y) }
func front(_ p3: Point3) -> CGPoint { return CGPoint(x: p3.x, y: p3.z) }
func side(_ p3: Point3) -> CGPoint { return CGPoint(x: p3.y, y: p3.z) }
func plan(_ cedge: CEdge) -> C2Edge { return C2Edge(content: cedge.content, p1: cedge.p1 |> plan, p2: cedge.p2 |> plan ) }
func front(_ cedge: CEdge) -> C2Edge { return C2Edge(content: cedge.content, p1: cedge.p1 |> front, p2: cedge.p2 |> front ) }
func side(_ cedge: CEdge) -> C2Edge { return C2Edge(content: cedge.content, p1: cedge.p1 |> side, p2: cedge.p2 |> side ) }
func plan(_ edges: [CEdge]) -> [C2Edge] { return edges.map(plan) }
func front(_ edges: [CEdge]) -> [C2Edge] { return edges.map(front) }
func side(_ edges: [CEdge]) -> [C2Edge] { return edges.map(side) }

func reduceDup (_ array: [C2Edge] ) -> [C2Edge] {
  
  return array.reduce([]) { (res, ed) -> [C2Edge] in
    if res.contains(where: { ed == $0 }) {
      return res
    }
    return res + [ed]
  }
}

func cedgeMaker(_ grid: GraphPositions) -> (Edge) -> (CEdge)
{
  return  { (grid, $0) |> cedge }
}





struct CGSize3 { var (width, depth, elev) : (CGFloat, CGFloat, CGFloat) }

func fromPlan(elev:CGFloat) -> (CGSize) -> CGSize3     { return {    CGSize3(width: $0.width, depth:  $0.height, elev:  elev)} }
func fromFront(depth:CGFloat) -> (CGSize) -> CGSize3   { return {  CGSize3(width: $0.width, depth:  depth, elev:  $0.height)} }
func fromSide(width:CGFloat) -> (CGSize) -> CGSize3    { return {   CGSize3(width: width, depth:  $0.width, elev:  $0.height)} }

func mapEdges( ed: [Edge], ceMak: (Edge) -> (CEdge)) -> [CEdge] { return ed.map( ceMak) }

func filterLedgers(edge : C2Edge) -> Bool
{
  return !(edge.content == "Ledger" && edge.p1 == edge.p2)
  
}

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

extension ScaffGraph
{
  var planEdges : [C2Edge] {
    let planedges = (self.edges, self.grid |> cedgeMaker) |> mapEdges |> plan |> reduceDup
    return planedges
  }
  var planEdgesNoZeros : [C2Edge] {
    let new = self.planEdges.filter { $0.content == "Ledger" || $0.content == "Standard" }
    return new
  }
  var frontEdges : [C2Edge] {
    let consumer3D = try! self.edges.map( self.grid |> cedgeMaker)
    return  consumer3D |> front |> reduceDup
  }
  var frontEdgesNoZeros : [C2Edge] {
    return self.frontEdges |> reduceZeros
  }
  var sideEdges : [C2Edge] {
    let consumer3D = try! self.edges.map( self.grid |> cedgeMaker)
    return  consumer3D |> side |> reduceDup
  }
  var sideEdgesNoZeros : [C2Edge] {
    return self.sideEdges |> reduceZeros
  }
  
  var bounds: CGSize3 {
    return self.grid |> posToSize
  }
  
  var boundsOfGrid: (CGSize3, CGFloat) {
    return (self.grid |> dropBottomZBay |> posToSize, (self.grid.pZ |> posToSeg |> { ($0.first)!} ))
  }
  
}


func createScaffolding(with bounding: CGSize3) -> (GraphPositions, [Edge])
{
  let graphSegments = GraphSegments(
    sX: ([50, 100, 150, 200], bounding.width) |> maximumRepeated,
    sY: ([50, 100, 150, 200], bounding.depth) |> maximumRepeated,
    // sZ is the ledger bays not the standards
    sZ: ([50, 100, 150, 200], bounding.elev) |> maximumRepeatedWithR |> { [$0.1] + $0.0 }
  )
  let s = ScaffGraph( grid : graphSegments |> segToPos, edges : [] )
  s.addScaff()
  return (s.grid, s.edges)
}

func createGrid(with bounding: CGSize3) -> (GraphPositions, [Edge])
{
  let screwJack : [CGFloat] = [30]
  let graphSegments = GraphSegments(
    sX: ([50, 100, 150, 200], bounding.width) |> maximumRepeated,
    sY: ([50, 100, 150, 200], bounding.depth) |> maximumRepeated,
    // sZ is the ledger bays not the standards
    sZ: ([50, 100, 150, 200], bounding.elev) |> maximumRepeated |> { screwJack + $0  }
  )
  let s = ScaffGraph( grid : graphSegments |> segToPos, edges : [] )
  s.addScaff()
  return (s.grid, s.edges)
}

typealias SGraph = (GraphPositions, [Edge])
struct Parse<A>
{
  let parse: (SGraph) -> (A)
}

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

func frontSection() -> Parse<[C2Edge]>
{
  return Parse { (graphC) -> [C2Edge] in
    let items = graphC.1.filter(frontEdge)
    return (graphC.0, items) |> cedges >>> front
  }
}

extension C2Edge : CustomStringConvertible {
    var description : String { return "\(content) \(p1), -> \t\t\t \(p2)\n"}
}
