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

class ViewController : UIViewController
{
//  override func loadView() {
//    self.view = GrippedViewHandles(frame: UIScreen.main.bounds)
//  }
  var driver : SpriteDriver
  var driverLayout : PositionedLayout<IssuedLayout<LayoutToDriver<SpriteDriver>>>
  
  init(driver: SpriteDriver)
  {
    self.driver = driver
    self.driverLayout = PositionedLayout(
      child: IssuedLayout(child: LayoutToDriver( child: driver )),
      ofSize: CGSize.zero,
      aligned: (.center, .center))
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("Init with coder not implemented")
  }
  
  var viewport : CanvasViewport!
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.driver.bind(to: viewport.canvas.frame)
    let bestFit = driver.size
    
    self.driverLayout.size = bestFit
    let selection = CGRect.around(viewport.canvas.frame.center, size: bestFit)
    self.viewport.animateSelection(to: selection)
    
    self.driverLayout.layout(in: selection)
  }
  
  override func loadView() {
    viewport = CanvasViewport(frame: UIScreen.main.bounds, element: self.driver.content)
    self.view = viewport
    
    viewport.canvasChanged = { [weak self] newSize in
      guard let self = self else { return }
      
      print("Canvas changed")
      self.logViewport()
      self.driver.bind(to: self.viewport.canvas.frame) /// Potentially not VPCoord
      // Now that the updated canvas is bound we want to
      // *Force* a layout at the selection's origin
      // This ignores whether the selection origin changed or not
      // —functionality that is part of the self.alignedLayout stack—
      // as a side note it also ignores alignment but this
      // doesnt matter in this case since we are probabbly already snug
      self.driver.layout(origin: self.viewport.selection.origin)
      self.logViewport()
      
    print("Canas Changed End")
    }
    viewport.selectionOriginChanged = { [weak self] _ in
      guard let self = self else { return }
  print("selection origin changed")
      self.driverLayout.layout(in: self.viewport.selection) /// should be VPCoord
    }
    viewport.selectionSizeChanged = { [weak self] _ in
      guard let self = self else { return }
      print("selection size changed")

      let bestFit = self.viewport.selection.size |> self.driver.size
      self.driverLayout.size = bestFit
      self.driverLayout.layout(in: self.viewport.selection)
    }
    viewport.didBeginEdit = {
      print("did begin edit")

      self.logViewport()
      //self.map.isHidden = false
    }
    viewport.didEndEdit = {
      print("did end edit")

      self.logViewport()
      self.viewport.animateSelection(to:  self.alignedLayout.child.issuedRect! )
    }
    viewport.didBeginPan = {
      self.logViewport()
    }
    viewport.didBeginZoom = {
      print("did begin zoom")

      // viewports scale is reset at each didEndZoom call
      // driver.scale needs to store the cumulative scale
      //print("before zoom begins - scale",  self.driver.scale)
      print("before zoom begins - selection",  self.viewport.selection)
    }
    viewport.zooming = { scale in
      print("zooming")

      //self.driver.set(scale: scale)
      
    }
    viewport.didEndZoom = { scale in
      print("did end zooom")

      self.logViewport()

      // viewports scale is reset at each didEndZoom call
      // driver.scale needs to store the cumulative scale
      //print("scale from canvas selection - given",  scale)
      //print("scale from existing driver -  given",  self.driver.scale)
      // print("new-scale                 - direven",  self.driver.scale * scale)
      self.driver.set(scale: scale)
      
      let bestFit = self.viewport.selection.size |> self.driver.size
      self.driverLayout.size = bestFit
      self.driverLayout.layout(in: self.viewport.selection)
    }
  
  }
  
  override func viewDidLayoutSubviews() {
    print("view did layout subviews")
    super.viewDidLayoutSubviews()
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
    print("----------")
    print("-ModelSpace size", self.selection.scaled(by: self.scale).rounded(places: 1))
    print("-PaperSpace size", self.selection.rounded(places: 1))
    print("-Scale", self.scale.rounded(places: 2))
    print("------")
    print("-Offset", self.offset.rounded(places: 1))
    print("-Canvas", self.canvas.frame.rounded(places: 1))

  }
}

extension ViewController {
  func logViewport ()
  {
    self.viewport.logViewport()
    print("-Size", self.driver.size(for: self.viewport.selection.size) )
    print("----------")

  }
  
}
