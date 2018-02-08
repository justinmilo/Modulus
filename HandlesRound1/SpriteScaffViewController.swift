//
//  TestViewController.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit

func originSwap(origin: CGRect, height: CGFloat) -> CGPoint
{
  return CGPoint(origin.x, height - origin.y - origin.height)
}


class SpriteScaffViewController : UIViewController {
  
  var twoDView : Sprite2DView
  var handleView : HandleViewRound1
  var graph : ScaffGraph
  
  let add3rdDim : (CGSize) -> CGSize3 = {
    return CGSize3(width: $0.width, depth: 400, elev : $0.height)
  }
  let remove3rdDim : (CGSize3) -> CGSize = {
    return CGSize(width: $0.width, height:  $0.elev)
  }
  
  override func loadView() {
    
    view = UIView()
    view.addGestureRecognizer(UITapGestureRecognizer(target: twoDView, action: #selector(Sprite2DView.tapped)))
    
    let boundingGrips = self.handleView
    boundingGrips.handler =    {
      master, positions in
      let foo1 = master.size |> self.add3rdDim |> createScaffolding
      self.graph = foo1
      let swappedOrigin = (master, self.twoDView.bounds.height) |> originSwap
      let g = (self.graph.frontEdgesNoZeros, swappedOrigin) |> modelToLinework
      let b = (self.graph.frontEdgesNoZeros, swappedOrigin) |> modelToTexturesElev
      self.twoDView.geometries = [[g], [b]]
      self.twoDView.redraw( self.twoDView.index )
    }
    boundingGrips.completed = {
      master, positions in
      let foo1 = master.size |> self.add3rdDim |> createScaffolding
      self.graph = foo1
      print(self.graph.grid)
      let size = self.graph.bounds |> self.remove3rdDim
      let new = CGRect(origin: master.origin, size:size)
      self.handleView.set(master: new )
      
      
    }
    for v in [twoDView, boundingGrips]{ self.view.addSubview(v) }
  }
  
  
  init()
  {
    twoDView = Sprite2DView(frame: UIScreen.main.bounds)
    self.handleView = HandleViewRound1(frame: UIScreen.main.bounds, state: .edge)
    self.graph = (CGSize3(width: 150, depth: 150, elev: 820) |> createScaffolding)
    super.init(nibName: nil, bundle: nil)
  }

  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  

  
}
