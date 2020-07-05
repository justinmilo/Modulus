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

typealias TentEdge2D = C2Edge<TentParts>
let planLabel : (TentEdge2D)->Label = { (edge) -> Label in
  let direction : Label.Rotation = edge.content == TentParts.rafter ? .h : .v
  let vector = direction == .h ? Geo.unitY * 10 : Geo.unitX * -10
  return Label(text: edge.content.rawValue, position: (edge.p1 + edge.p2).center + vector, rotation: direction)
}
let sideLabel : (TentEdge2D)->Label = { edge -> Label in
  let direction : Label.Rotation = edge.content == TentParts.purlin ? .h : .v
  let vector = direction == .h ? Geo.unitY * 10 : Geo.unitX * 10
  return Label(text: edge.content.rawValue, position: (edge.p1 + edge.p2).center + vector, rotation: direction)
}
func lines(item: TentEdge2D) -> Line {
   return Line(p1: item.p1, p2: item.p2)
 }

typealias TentEdges2D = [C2Edge<TentParts>]
let planLabels : (TentEdges2D)->[Label] = { $0.map(planLabel).secondPassLayout() }
let sideLabels : (TentEdges2D)->[Label] = { $0.map(sideLabel).secondPassLayout() }

let joints :  (TentEdges2D)->[CGPoint] = { $0.reduce([]) { (res, edge) -> [CGPoint] in
  var res = res
  if !res.contains(edge.p1) {
    res.append(edge.p1)
  }
  if !res.contains(edge.p2) {
    res.append(edge.p2)
  }
  return res
  }
}
let jointNodes : ([CGPoint])->[Oval] = { $0.map{
  return Oval(size: CGSize(10,10), position: $0)
  }
}

let tentLinesLabelsPlan : (TentEdges2D) -> Composite =
  planLabels
    >>> Composite.init
    <> (joints
      >>> jointNodes)
    >>> Composite.init
    <> { $0 .map(lines) }
    >>> Composite.init

let tentLinesLabelsSide : (TentEdges2D) -> Composite =
sideLabels
  >>> Composite.init
  <> (joints
    >>> jointNodes)
  >>> Composite.init
  <> { $0 .map(lines) }
  >>> Composite.init





import Interface
import ComposableArchitecture

public class TentGraph : GraphHolder, Equatable {
   public static func == (lhs: TentGraph, rhs: TentGraph) -> Bool {
      (lhs.edges == rhs.edges) && (lhs.grid == rhs.grid)
   }
   
  public typealias Content = TentParts
  public var id : String
  public var edges : [Edge<Content>]
  public var grid : GraphPositions
  
  public convenience init(width: CGFloat = 500, depth:CGFloat=1000, elev:CGFloat=450, id:String="MODEMOCK") {
    let size = CGSize3(width:width, depth:depth, elev:elev)
    let (pos, edges) = createTentGridFromRidgeHeight(with:size)
    self.init(positions: pos, edges: edges, id: id)
    self.edges = edges
    self.grid = pos
    self.id = id
  }
  public init(positions: GraphPositions, edges:[Edge<Content>], id:String="MODEMOCK") {
    let (pos, edges) = (positions, edges)
    
    self.edges = edges
    self.grid = pos
    self.id = id
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
  createTentGridFromRidgeHeight(with:size)
}


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

public let tentPlanMapF = { build in GenericEditingView<TentGraph>(
  build: build,
  origin: originZero,
  size: { $0.bounds }
    >>> remove3rdDimPlan,
  size3: sizePlanTent,
  composite: plan2D
    >>> tentLinesLabelsPlan
    <> get(\.grid)
    >>> plan
    >>> (innerDim(meterFormat)
      <> outerDim(meterFormat)),
  grid2D: planPositionsTent,
  selectedCell: { _, _, edges in return edges}
  )
}
let tentPlanMap = tentPlanMapF(overallTent)

let tentPlanMapRotated = GenericEditingView<TentGraph>(
  build: overallTent,
  origin: originZero,
  size: { $0.bounds }
    >>> remove3rdDimPlan
    >>> flip,
  size3: { $0.bounds } >>> add3rdDimToRotatedPlan,
  composite: plan2D
    >>> rotateGroup
    >>>  tentLinesLabelsSide
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
    // >>> addTentHeight
  ,
  size3: { $0.bounds }
    >>> add3rdDimToFront
    //>>> minusTentHeight
  ,
  composite: front2D
    >>>  tentLinesLabelsPlan
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
  size: { $0.bounds } >>> remove3rdDimSide // >>> addTentHeight
  ,
  size3: { $0.bounds } >>> size3Side // >>> minusTentHeight
  ,
  composite: side2D
    >>> tentLinesLabelsSide
    <> get(\.grid)
    >>> side
    >>> (innerDim(meterFormat)
      <> outerDim(meterFormat)),
  grid2D: sidePositionsTent,
  selectedCell: { _, _, edges in return edges}
)

import Geo
func tentVC<Holder: GraphHolder>(store: Store<InterfaceState<Holder>, InterfaceAction<Holder>>, title: String) -> InterfaceController<Holder> {
  let vc = InterfaceController(store:store)
  vc.title = title
  let bottomBar = UIVisualEffectView(effect: UIBlurEffect(style:.dark))
  vc.view.addSubview( bottomBar )
  bottomBar.frame = vc.view.frame.bottomLeft + (vc.view.frame.bottomRight - Geo.unitY * 102)

  return vc
}


