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

typealias Config = FixedDiagramViewCongfiguration

struct ViewDriver : Driver {
  func bind(to uiRect: CGRect) {
    #warning("This is a dumb protocol requirement")
  }
  
  var assemblyView : FixedEditableDiagramView<InsetStrokeDrawable<Diagram>>
  
  
  // Drawing pure function
  var editingView : GraphEditingView
  
  var twoDView : UIView
  var content : UIView { return self.twoDView }
  
  public init(mapping: [GraphEditingView] )
  {
    editingView = mapping[0]
    
    twoDView = UIView(frame: Current.screen )
    
    let sub = InsetStrokeDrawable(subject:Diagram(elements:[]), strokeWidth: 8.0)
    assemblyView = FixedEditableDiagramView( subject: sub, config: Config(stroke: #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), strokeWidth: 8.0))
    assemblyView.backgroundColor = .lightGray
    
    twoDView.addSubview(assemblyView)
    
  }
  
  
  /// move the origin
  func layout(origin: CGPoint) {
    self.assemblyView.frame.origin = origin
  }
  
  /// Handler for Selection Size Changed
  mutating func layout(size: CGSize) {
    let artwork = Current.graph
      |> get(\ScaffGraph.planEdgesNoZeros)
      >>> modelToLinework
      >>> filter()
      >>> reduceDuplicates
    print(artwork)
    let original = Diagram(elements:artwork)
    let dia = InsetStrokeDrawable(subject: original, strokeWidth: 8.0)
    print("original")
    original.draw(in: TestRenderer())
    print("dia")
    dia.draw(in: TestRenderer())
    assemblyView.ground = dia
    assemblyView.setNeedsDisplay()
  
    // Set & Redraw Geometry
    self.assemblyView.frame.size = size
  }
  
  func size(for size: CGSize) -> CGSize {
    let s3 = size |> self.editingView.size3(Current.graph)
    (Current.graph.grid, Current.graph.edges) = self.editingView.build(s3, Current.graph.edges)
    return Current.graph |> self.editingView.size
  }
  
}
