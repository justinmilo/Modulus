//
//  3DExchange.swift
//  Modular
//
//  Created by Justin Smith on 8/6/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation
import Volume
import Graphe
import Singalong

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
    case .y : self = ScaffType.Axis.y
    case .x : self = ScaffType.Axis.x
    }
  }
}

func graph_measure(_ cgFloat: CGFloat) -> Measurement<UnitLength>{
  return Measurement(
    value: Double(cgFloat),
    unit: UnitLength.centimeters)
}


func members(graph: ScaffGraph) -> [ScaffMember] {
  return graph.edges.flatMap { edge -> [ScaffMember] in
    
    switch edge.content {
    case .bc:
      return [ScaffMember(
        type: .bc,
        position: edge.p1.toPoint3(graph.grid).asDoubleTuple
        )]
    case .diag:
      let seg3 = (graph.grid, edge) |> segment3
      guard let axis = seg3|>axis, let run = (seg3|>run) else { return [] }
      return [ScaffMember(
        type: ScaffType.diag(
          run: graph_measure(run),
          rise: graph_measure(seg3|>rise),
          axis: ScaffType.Axis( axis )
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
