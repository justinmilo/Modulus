//
//  ViewDiagramDriver.swift
//  HandlesRound1
//
//  Created by Justin Smith on 6/17/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit

import Layout
import Singalong
import Diagrams
import Graphe
import Geo
import BlackCricket


typealias Config = FixedDiagramViewCongfiguration

class ViewDriver : Driver  {
  
  func set(scale: CGFloat) {
    self.scale = scale
  }
  
  func bind(to uiRect: CGRect) {
    return
  }
  
  
  
  var assemblyView : FixedEditableDiagramView<InsetStrokeDrawable<Scaled<Diagram>>>
  
  // Drawing pure function
  var editingView : GraphEditingView
  private var scale: CGFloat
  var twoDView : UIView
  var content : UIView { return self.twoDView }
  let id : String
  
  public init(mapping: [GraphEditingView], id: String , scale: CGFloat)
  {
    editingView = mapping[0]
    self.id = id
    twoDView = UIView(frame: Current.screen )
    
    self.scale = scale
    let sub = InsetStrokeDrawable(subject:Diagram(elements:[]).scaled(by: self.scale), strokeWidth: 8.0)
    assemblyView = FixedEditableDiagramView( subject: sub, config: Config(stroke: #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), strokeWidth: 8.0))
    
    twoDView.addSubview(assemblyView)
    
  }
  
  
  /// move the origin
  func layout(origin: CGPoint) {
    print("LAYOUT ORIGIN", origin.x)
    self.assemblyView.frame.origin = origin
  }
  
  var graph : ScaffGraph { return Current.model.getItem(id: self.id)!.content |> ScaffGraph.init}
  
  /// Handler for Selection Size Changed
   func layout(size: CGSize) {
    
    
    print("LAYOUT SIZE", size, "LAYOUT Scale," , scale, "Basic size", size * scale)

    let artwork = self.graph
      |> get(\ScaffGraph.planEdgesNoZeros)
      >>> modelToLinework
      >>> filter()
      >>> reduceDuplicates

  
    let original = Diagram(elements:artwork)
    let scaledDiagram = original.scaled(by: scale) /// Stupid

    assemblyView.ground = InsetStrokeDrawable(subject: scaledDiagram, strokeWidth: 8.0)
    assemblyView.setNeedsDisplay()
  
    // Set & Redraw Geometry
    self.assemblyView.frame.size = size
  }
  
  func build(for size: CGSize) -> CGSize {
    print("size from main driver - given",  size)
    print("size from main driver - scale",  scale)
    print("size from main driver - pre-delivr",  size * (1/scale))

    let scaledSize = (size * (1/scale))
    let roundedScaledSize = CGSize(width: scaledSize.width.rounded(places: 5), height: scaledSize.height.rounded(places: 5))
    
    print("size from main driver - delivr",  roundedScaledSize)
    let s3 =  roundedScaledSize |> self.editingView.size3(self.graph)
    (self.graph.grid, self.graph.edges) = self.editingView.build(s3, self.graph.edges)
    let adjSize = self.graph |> self.editingView.size
    print("size from main driver - scaled",  adjSize)
    print("size from main driver - return",  adjSize  * scale)
    return (self.graph |> self.editingView.size) * scale
  }
  
}







