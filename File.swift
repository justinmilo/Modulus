import UIKit
import Singalong
import BlackCricket
import SpriteKit
@testable import Graphe
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
    let vector = direction == .h ? unitY * 10 : unitX * 10
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

func kitView(nodes: [SKNode]) -> Sprite2DView {
  let s2DV = Sprite2DView(frame: CGSize(500, 500).asRect())
  s2DV.scale = 1/2

  nodes.forEach {
    s2DV.mainNode.addChild($0)
  }
  return s2DV
}



public func quadView() -> UIViewController {

  let size = CGSize3(width:500, depth:1000, elev:450)
  let (pos, edges) = createTentGridFromEaveHeiht(with:size)

  let plan2D : [C2Edge<TentParts>] = cedges(graph: pos, edges: edges) |> plan
  let plan2DR : [C2Edge<TentParts>] = cedges(graph: pos, edges: edges) |> plan
  let front2D : [C2Edge<TentParts>] = cedges(graph: pos, edges: edges) |> front
  let side2D : [C2Edge<TentParts>] = cedges(graph: pos, edges: edges) |> side

  func controller(_ view: UIView, _ titled : String)->UIViewController{
    let vc = UIViewController()
    vc.view = view
     vc.title = titled
    let colors : [UIColor] = [.white, .gray, .yellow, .blue, .green, .lightGray]
    return  vc
  }
  
  let one = controller( plan2D |> tentNodes >>> kitView , "Top")
  let two = controller( plan2DR |> tentNodes >>> kitView , "Top")
  let three = controller( front2D |> tentNodes >>> kitView, "Top")
  let four = controller(  side2D |> tentNodes >>> kitView, "Right")

  let delegate = QuadDriver(upper: [one, two], lower: [three, four])

  let a = embedInNav(delegate.group)

  return a


}
