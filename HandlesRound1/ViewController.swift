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

protocol Driver {
  var content : UIView { get }
  func size(for size: CGSize) -> CGSize
  mutating func layout(origin: CGPoint)
  mutating func layout(size: CGSize)
  mutating func set(scale: CGFloat)
  mutating func bind(to uiRect: CGRect)
}

class ViewController<DriverType : Driver> : UIViewController
{
//  override func loadView() {
//    self.view = GrippedViewHandles(frame: UIScreen.main.bounds)
//  }
  var driver : DriverType
  var alignedLayout : PositionedLayout<TwoferLayout<LayoutToDriver<DriverType>>>
  
  init(driver: DriverType)
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
    self.driver.bind(to: viewport.canvas.frame)
    
    viewport.canvasChanged = { [weak self] newSize in
      guard let self = self else { return }
      
      self.driver.bind(to: self.viewport.canvas.frame) /// Potentially not VPCoord
    }
    viewport.selectionOriginChanged = { [weak self] _ in
      guard let self = self else { return }
  
      self.alignedLayout.layout(in: self.viewport.selection) /// should be VPCoord
    }
    viewport.selectionSizeChanged = { [weak self] _ in
      guard let self = self else { return }
      
      let bestFit = self.viewport.selection.size |> self.driver.size
      self.alignedLayout.size = bestFit
      self.alignedLayout.layout(in: self.viewport.selection)
    }
    viewport.didBeginEdit = {
      self.logViewport()
      //self.map.isHidden = false
    }
    viewport.didEndEdit = {
      self.logViewport()
      self.viewport.animateSelection(to:  self.alignedLayout.child.issuedRect! )
    }
    viewport.didBeginZoom = {
      // viewports scale is reset at each didEndZoom call
      // driver.scale needs to store the cumulative scale
      //print("before zoom begins - scale",  self.driver.scale)
      print("before zoom begins - selection",  self.viewport.selection)
    }
    viewport.zooming = { scale in
      //self.driver.set(scale: scale)
      
    }
    viewport.didEndZoom = { scale in
      self.logViewport()

      // viewports scale is reset at each didEndZoom call
      // driver.scale needs to store the cumulative scale
      print("didEndZOom")
      //print("scale from canvas selection - given",  scale)
      //print("scale from existing driver -  given",  self.driver.scale)
      // print("new-scale                 - direven",  self.driver.scale * scale)
      self.driver.set(scale: scale)
      
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

extension CanvasViewport {
  func logViewport ()
  {
    print("ModelSpace size", self.selection.scaled(by: self.scale).rounded(places: 1))
    print("PaperSpace size", self.selection.rounded(places: 1))
    print("Scale", self.scale.rounded(places: 2))
  }
}

extension ViewController {
  func logViewport ()
  {
    self.viewport.logViewport()
    print("Size", self.driver.size(for: self.viewport.selection.size) )
  }
  
}
