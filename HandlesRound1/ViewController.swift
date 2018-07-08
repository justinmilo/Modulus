//
//  ViewController.swift
//  ScrollViewGrower
//
//  Created by Justin Smith on 4/26/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit
import Geo
import GrippableView
import Singalong
import Layout


// centerAnchor
// Scrolled Anchor / Eventual Anchor Location
func contentSizeFrom (offsetFromCenter: CGVector, itemSize: CGSize, viewPortSize: CGSize) -> CGSize
{
  return (viewPortSize / 2) + offsetFromCenter.asSize() + (itemSize / 2)
}
struct TestLayout
{
  //  override func loadView() {
  //    self.view = GrippedViewHandles(frame: UIScreen.main.bounds)
  //  }
  var driver : ViewDriver
  var alignedLayout : MarginLayout<UIView>
}


class ViewController: UIViewController
{
//  override func loadView() {
//    self.view = GrippedViewHandles(frame: UIScreen.main.bounds)
//  }
  var driver : ViewDriver
  var alignedLayout : PositionedLayout<TwoferLayout<LayoutToDriver>>
  
  init(driver: ViewDriver)
  {
    self.driver = driver
    let adapaterLayout = LayoutToDriver( child: driver )
    let beforeDriverLayout = TwoferLayout(child: adapaterLayout)

    self.alignedLayout = PositionedLayout(child: beforeDriverLayout,
                                     ofSize: CGSize.zero,
                                     aligned: (.center, .center))
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("Init with coder not implemented")
  }
  
  var viewport : CanvasViewport!
  
  override func loadView() {
    viewport = CanvasViewport(frame: UIScreen.main.bounds, element: self.driver.content)
    self.view = viewport
    
    viewport.selectionOriginChanged = { [weak self] _ in
      guard let self = self else { return }
  
      self.alignedLayout.layout(in: self.viewport.selection)
    }
    viewport.selectionSizeChanged = { [weak self] _ in
      guard let self = self else { return }
      
      let bestFit = self.viewport.selection.size |> self.driver.size
      
      self.alignedLayout.size = bestFit
      self.alignedLayout.layout(in: self.viewport.selection)
    }
    viewport.didBeginEdit = {
      //self.map.isHidden = false
    }
    viewport.didEndEdit = {
      self.viewport.animateSelection(to:  self.alignedLayout.child.issuedRect! )
    }
    viewport.didBeginZoom = {
      // viewports scale is reset at each didEndZoom call
      // driver.scale needs to store the cumulative scale
      print("before zoom begins - scale",  self.driver.scale)
      print("before zoom begins - selection",  self.viewport.selection)
    }
    viewport.zooming = { scale in
      self.driver.scale = scale
      
    }
    viewport.didEndZoom = { scale in
      // viewports scale is reset at each didEndZoom call
      // driver.scale needs to store the cumulative scale
      print("scale from canvas selection - given",  scale)
      print("scale from existing driver -  given",  self.driver.scale)
      print("new-scale                 - direven",  self.driver.scale * scale)
      self.driver.scale = scale
      
      let bestFit = self.viewport.selection.size |> self.driver.size
      self.alignedLayout.size = bestFit
      self.alignedLayout.layout(in: self.viewport.selection)
      
    
    }
  
  }
  
  override func viewDidLoad() {
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
  }
  
  @objc func tap() {
    self.viewport.animateSelection(
      to: self.viewport.canvas.convert(
        CGRect.around(self.view.center, size: self.viewport!.selection.size),
        from: self.view))
  }
  
  

  /// End Scrollview
  
}


