import UIKit
import Singalong
@testable import BlackCricket
import SpriteKit
@testable import GrapheNaked
import Geo

extension Array where Element == Label {
  func secondPassLayout() -> [Label] {
    let copy = self
    return copy.reduce([]) {
    
    (res, geo) -> [Label] in
    
    if res.contains(where: {
      
      let r = CGRect.around($0.position, size: CGSize(40,40))
      return r.contains(geo.position)
      
    })
    {
      var new = geo
      new.position = new.position + CGVector(dx: 15, dy: 15)
      return res + [new]
    }
    
    return res + [geo]
  }
  
  }
  
}

func tentLinesLabels(tentParts: [C2Edge<TentParts>]) -> Composite {
  func lines(item: C2Edge<TentParts>) -> Line {
     return Line(p1: item.p1, p2: item.p2)
   }
  let labels = tentParts.map { edge -> Label in
    let direction : Label.Rotation = edge.content == TentParts.rafter ? .h : .v
    let vector = direction == .h ? Geo.unitY * 10 : Geo.unitX * 10
    return Label(text: edge.content.rawValue, position: (edge.p1 + edge.p2).center + vector, rotation: direction)
  }
  let labelsSecondPassNodes = labels.secondPassLayout()
  
  let joints : [CGPoint] = tentParts.reduce([]){ (res, edge) -> [CGPoint] in
    var res = res
    if !res.contains(edge.p1) {
      res.append(edge.p1)
    }
    if !res.contains(edge.p2) {
      res.append(edge.p2)
    }
    return res
  }
  let jointNodes : [Oval] = joints.map{
    return Oval(size: CGSize(10,10), position: $0)
  }
  return Composite(geometry: tentParts.map(lines) + jointNodes, labels: labelsSecondPassNodes)
}


func tentNodes(tentParts: [C2Edge<TentParts>]) -> [SKNode] {
  
  func lines(item: C2Edge<TentParts>) -> SKShapeNode {
    let cgPath = CGMutablePath()
    cgPath.move(to: item.p1)
    cgPath.addLine(to: item.p2)
    
    print(item.p1, item.p2)
    let node = SKShapeNode(path: cgPath)
    return node
  }
  
  let labels = tentParts.map { edge -> Label in
    let direction : Label.Rotation = edge.content == TentParts.rafter ? .h : .v
    let vector = direction == .h ? Geo.unitY * 10 : Geo.unitX * 10
    return Label(text: edge.content.rawValue, position: (edge.p1 + edge.p2).center + vector, rotation: direction)
  }
  let labelsSecondPassNodes = labels.secondPassLayout().map{ $0.asNode }
  
  let joints : [CGPoint] = tentParts.reduce([]){ (res, edge) -> [CGPoint] in
    var res = res
    if !res.contains(edge.p1) {
      res.append(edge.p1)
    }
    if !res.contains(edge.p2) {
      res.append(edge.p2)
    }
    return res
  }
  let jointNodes : [SKNode] = joints.map{
    let shape = SKShapeNode(circleOfRadius: 10)
    shape.position = $0
    shape.fillColor = .gray
    return shape
  }
  
  return tentParts.map(lines) + labelsSecondPassNodes + jointNodes

}

import Interface
import ComposableArchitecture

class TentGraph : GraphHolder {
  typealias Content = TentParts
  var id : String
  var edges : [Edge<Content>]
  var grid : GraphPositions
  
  init() {
    let size = CGSize3(width:500, depth:1000, elev:450)
    let (pos, edges) = createTentGridFromEaveHeiht(with:size)
    
    self.edges = edges
    self.grid = pos
    self.id = "MODEMOCK"
  }
}

typealias ConsumerEdges = (TentGraph) -> [C2Edge<TentParts>]
let plan2D : ConsumerEdges = { ($0.grid, $0.edges) } >>> cedges >>> plan  >>> reduceDup
let plan2DR : ConsumerEdges = { ($0.grid, $0.edges) } >>> cedges >>> plan >>> reduceDup
let front2D : ConsumerEdges = { ($0.grid, $0.edges) } >>> cedges >>> front  >>> reduceDup
let side2D : ConsumerEdges = { ($0.grid, $0.edges) } >>> cedges >>> side  >>> reduceDup



let size3Plan : (CGSize3) -> (CGSize) -> CGSize3 = {frozen in { CGSize3(width: $0.width, depth: $0.height, elev: frozen.elev) }}
let add3rdDimToRotatedPlan : (CGSize3) -> (CGSize) -> CGSize3 = {frozen in { CGSize3(width: $0.height, depth: $0.width, elev: frozen.elev) }}
let add3rdDimToFront : (CGSize3) -> (CGSize) -> CGSize3 = {frozen in { CGSize3(width: $0.width, depth: frozen.depth, elev: $0.height) }}
let size3Side : (CGSize3) -> (CGSize) -> CGSize3 = {frozen in { CGSize3(width: frozen.width, depth: $0.width, elev: $0.height) }}

let sizePlanTent : (TentGraph) -> (CGSize) -> CGSize3 = get(\.bounds) >>> size3Plan
let sizePlanRotatedTent : (TentGraph) -> (CGSize) -> CGSize3 = get(\.bounds) >>> add3rdDimToRotatedPlan
let sizeFrontTent : (TentGraph) -> (CGSize) -> CGSize3 = get(\.bounds) >>> add3rdDimToFront
let sizeSideTent : (TentGraph) -> (CGSize) -> CGSize3 = get(\.bounds) >>> size3Side

let planEdgesTent : (TentGraph) -> [C2Edge<TentParts>] = { ($0.grid, $0.edges) |> planSection().parse }
let frontEdgesTent : (TentGraph) -> [C2Edge<TentParts>] = { ($0.grid, $0.edges) |> frontSection().parse }
let sideEdgesTent : (TentGraph) -> [C2Edge<TentParts>] = { ($0.grid, $0.edges) |> sideSection().parse }

func positionsInEdges<A>(edges: [C2Edge<A>]) -> GraphPositions2DSorted {
  return GraphPositions2DSorted(
    pX: edges.flatMap{ [$0.p1.x] + [$0.p2.x] } |> removeDup,
    pY: edges.flatMap{ [$0.p1.y] + [$0.p2.y] } |> removeDup
  )
}
let planPositionsTent = planEdgesTent >>> log >>> positionsInEdges
let rotatedPlanPositionsTent = planEdgesTent >>> rotateGroup >>> log >>> positionsInEdges
let frontPositionsTent = frontEdgesTent >>> log >>> positionsInEdges
let sidePositionsTent = sideEdgesTent >>> log >>> positionsInEdges

let overallTent : ([CGFloat], CGSize3, [Edge<TentParts>]) -> (GraphPositions, [Edge<TentParts>]) = { _, size, _ in
   createTentGridFromEaveHeiht(with:size)
}


let planLineworkTent : (TentGraph) -> Composite =
get(\TentGraph.grid)
  >>> graphToNonuniformPlan
  >>> basic
  >>> Composite.init(geometry:)

let rotatedPlanLineworkTent : (TentGraph) -> Composite =
get(\TentGraph.grid)
  >>> graphToNonuniformPlan
  >>> rotateUniform
  >>> basic
  >>> Composite.init(geometry:)

let frontLineworkTent : (TentGraph) -> Composite =
get(\TentGraph.grid)
  >>> graphToNonuniformFront
  >>> basic
  >>> Composite.init(geometry:)

let sideLineworkTent : (TentGraph) -> Composite =
get(\TentGraph.grid)
  >>> graphToNonuniformSide
  >>> basic
  >>> Composite.init(geometry:)

let addTentHeight = { (size:CGSize) -> CGSize in
  let opposite = tan(18.0 * CGFloat.pi / 180) * size.width/2
  return CGSize(w: size.width, h: size.height + opposite)
}

let minusTentHeight = { (myFunc: @escaping (CGSize)->CGSize3) -> (CGSize)->CGSize3 in
  return { size in
    let opposite = tan(18.0 * CGFloat.pi / 180) * size.width/2
    return myFunc(CGSize(w: size.width, h: size.height - opposite))
  }
}

let tentPlanMap = GenericEditingView<TentGraph>(
  build: overallTent,
  origin: originZero,
  size: { $0.bounds }
    >>> remove3rdDimPlan,
  size3: sizePlanTent,
  composite: plan2D
    >>> tentLinesLabels
    <> get(\.grid)
    >>> plan
    >>> (innerDim(meterFormat)
      <> outerDim(meterFormat)),
  grid2D: planPositionsTent,
  selectedCell: { _, _, edges in return edges}
)

let tentPlanMapRotated = GenericEditingView<TentGraph>(
  build: overallTent,
  origin: originZero,
  size: { $0.bounds }
    >>> remove3rdDimPlan
    >>> flip,
  size3: { $0.bounds } >>> add3rdDimToRotatedPlan,
  composite: plan2D
    >>> rotateGroup
    >>>  tentLinesLabels
    <> get(\.grid)
    >>> rotatedPlan
    >>> (innerDim(meterFormat)
      <> outerDim(meterFormat)),
  grid2D: rotatedPlanPositionsTent,
  selectedCell: { _, _, edges in return edges}
)

let tentFrontMap = GenericEditingView<TentGraph>(
  build: overallTent,
  origin: originZero,
  size: { $0.bounds }
    >>> remove3rdDimFront
    >>> addTentHeight,
  size3: { $0.bounds }
    >>> add3rdDimToFront
    >>> minusTentHeight,
  composite: front2D
    >>>  tentLinesLabels
    <> get(\.grid)
    >>> front
    >>> (innerDim(meterFormat)
      <> outerDim(meterFormat)),
  grid2D: frontPositionsTent,
  selectedCell: { _, _, edges in return edges}
)

let tentSideMap = GenericEditingView<TentGraph>(
  build: overallTent,
  origin: originZero,
  size: { $0.bounds } >>> remove3rdDimSide >>> addTentHeight,
  size3: { $0.bounds } >>> size3Side  >>> minusTentHeight,
  composite: side2D
    >>> tentLinesLabels
    <> get(\.grid)
    >>> side
    >>> (innerDim(meterFormat)
      <> outerDim(meterFormat)),
  grid2D: sidePositionsTent,
  selectedCell: { _, _, edges in return edges}
)



func tentVC(store: Store<InterfaceState<TentGraph>, InterfaceAction<TentGraph>>, title: String, graph: TentGraph, tentMap:GenericEditingView<TentGraph>) -> ViewController<TentGraph> {
  

  let vc = ViewController( mapping: [tentMap], graph: graph, scale: 1.0, screenSize: Current.screen, store:store)
  vc.title = title
  addBarSafely(to:vc)
  return vc
}


