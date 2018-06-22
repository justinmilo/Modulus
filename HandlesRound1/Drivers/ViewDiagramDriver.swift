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

struct TwoferLayout<Child : Layout> : Layout {
  mutating func layout(in rect: CGRect) {
    issuedRect = rect
    self.child.layout(in: issuedRect!)
  }
  
  var contents: [Child.Content] { return child.contents }
  typealias Content = Child.Content
  
  
  var issuedRect : CGRect? = nil
  var child: Child
  
  public init( child : Child) { self.child = child}
}

typealias Config = FixedDiagramViewCongfiguration

class ViewDriver : Driver {
  
  func bind(to uiRect: CGRect) {
    #warning("This is a dumb protocol requirement")
  }
  
  var assemblyView : FixedEditableDiagramView<InsetStrokeDrawable<Scaled<Diagram>>>
  
  // Drawing pure function
  var editingView : GraphEditingView
  
  var twoDView : UIView
  var content : UIView { return self.twoDView }
  
  public init(mapping: [GraphEditingView] )
  {
    editingView = mapping[0]
    
    twoDView = UIView(frame: Current.screen )
    
    let sub = InsetStrokeDrawable(subject:Diagram(elements:[]).scaled(by: 1.0), strokeWidth: 8.0)
    assemblyView = FixedEditableDiagramView( subject: sub, config: Config(stroke: #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), strokeWidth: 8.0))
    
    twoDView.addSubview(assemblyView)
    
  }
  
  
  /// move the origin
  func layout(origin: CGPoint) {
    print("LAYOUT ORIGIN", origin.x)
    self.assemblyView.frame.origin = origin
  }
  
  /// Handler for Selection Size Changed
   func layout(size: CGSize) {
    
    
    #warning("Stupid")
    let width = Current.graph
      |> editingView.size
      >>> get(\CGSize.width)
    let scale = size.width / width
    #warning("End Stupid")
    
    print("LAYOUT SIZE", size, "LAYOUT Scale," , scale, "Basic size", size * scale)

    let artwork = Current.graph
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
  
  func size(for size: CGSize) -> CGSize {
    let s3 = size  |> self.editingView.size3(Current.graph)
    (Current.graph.grid, Current.graph.edges) = self.editingView.build(s3, Current.graph.edges)
    let adjSize = Current.graph |> self.editingView.size
    print("size from main driver",  adjSize)
    return (Current.graph |> self.editingView.size)
  }
  
}
