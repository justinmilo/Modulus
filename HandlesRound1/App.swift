//
//  App.swift
//  HandlesRound1
//
//  Created by Justin Smith on 3/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit
import Singalong
import Graphe
import Volume

struct AScaffProvider : ScaffProvider {
  var scaff: [ScaffMember]
}

extension Point3 {
  var asDoubleTuple: (x: Double, y: Double, z: Double)
  {
    return (x: Double(x), y: Double(y), z: Double(z))
  }
}
extension ScaffType.Axis {
  init (_ axis: Axis)
  {
    switch axis{
    case .x : self = ScaffType.Axis.y
    case .y : self = ScaffType.Axis.x
    }
  }
}

func graph_measure(_ cgFloat: CGFloat) -> Measurement<UnitLength>
{
  return Measurement(
  value: Double(cgFloat),
  unit: UnitLength.centimeters)
}


func members(graph: ScaffGraph) -> [ScaffMember]
{
  return graph.edges.flatMap { edge -> [ScaffMember] in
    
    switch edge.content {
    case .bc:
      return [ScaffMember(
        type: .bc,
        position: edge.p1.toPoint3(graph.grid).asDoubleTuple
      )]
    case .diag:
      let seg3 = (graph.grid, edge) |> segment3
      return [ScaffMember(
        type: ScaffType.diag(
          run: graph_measure( (seg3|>run)!),
          rise: graph_measure(seg3|>rise),
          axis: ScaffType.Axis( (seg3|>axis)! )
        ),
        position: edge.p1.toPoint3(graph.grid).asDoubleTuple
      )]
    case .jack:
      return [ScaffMember(
        type: .screwJack,
        position: edge.p1.toPoint3(graph.grid).asDoubleTuple
      )]
    case .ledger:
      let seg3 = (graph.grid, edge) |> segment3
      return [ScaffMember(
        type: .ledger(
          size: graph_measure((seg3|>run)!),
          axis: ScaffType.Axis( (seg3|>axis)! ) ),
        position: edge.p1.toPoint3(graph.grid).asDoubleTuple)]
    case .standardGroup:
      let seg3 = (graph.grid, edge) |> segment3
      
      let mxRpt = maximumRepeated(availableInventory: [50,100,150,200,250,300], targetMaximum: seg3|>rise)
      
      let pos = mxRpt.reduce([0]){ (posRes, nextSeg) -> [CGFloat] in
        return posRes + [posRes.last! + nextSeg]
        
      }
      
      return zip(mxRpt, pos).map{
        (stHeight, stPos) -> ScaffMember in
        let base3 = edge.p1.toPoint3(graph.grid).asDoubleTuple
        let pos3 = (base3.x, base3.y, base3.z + Double(stPos))
        return ScaffMember(
          type: .standard(size: graph_measure( stHeight ), with: false),
          position: pos3)
        
        
      }
    }
      
      
      
  }
}

let provider = members >>> AScaffProvider.init


class App
{
  
  lazy var rootController: UIViewController =
  {
    //let uR2 = SpriteScaffViewController(graph: graph, mapping: frontMap2)
    //return foo2( Current.viewMaps.plan)
    
    return VerticalController(upperLeft: foo2( Current.viewMaps.plan),
                              upperRight: foo2(Current.viewMaps.rotatedPlan),
                              lowerLeft: foo2(Current.viewMaps.front),
                              lowerRight: foo2(Current.viewMaps.side))
    
  }()
  
  @objc func dismiss3D()
  {
    self.rootController.dismiss(animated: true, completion: nil)
  }
  
  @objc func present3D()
  {
    let scaffProvider = Current.graph |> provider
    let newVC = CADViewController(grid: scaffProvider)
    
    let ulN = UINavigationController(rootViewController: newVC)
    ulN.navigationBar.prefersLargeTitles = false
    let nav = ulN.navigationBar
    newVC.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Dismiss",
      style: UIBarButtonItem.Style.plain ,
      target: self,
      action: #selector(App.dismiss3D)
    )
    
    
    self.rootController.present(ulN, animated: true, completion: nil)
  }
  
  func foo2(_ vm: EditingViews.ViewMap) -> UIViewController
  {
    let driver = SpriteDriver(mapping: vm.viewMap)
    let vc : ViewController = ViewController(driver: driver)
    let st = vm.label
    vc.title = st
    vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "3D", style: UIBarButtonItem.Style.plain , target: self, action: #selector(App.present3D))
    let ulN = UINavigationController(rootViewController: vc)
    ulN.navigationBar.prefersLargeTitles = true
    let nav = ulN.navigationBar
    nav.barStyle = UIBarStyle.blackTranslucent
    nav.tintColor = .white
    nav.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    
    return ulN
  }
  
}




