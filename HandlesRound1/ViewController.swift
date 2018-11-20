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
import Make2D


// centerAnchor
// Scrolled Anchor / Eventual Anchor Location
func contentSizeFrom (offsetFromCenter: CGVector, itemSize: CGSize, viewPortSize: CGSize) -> CGSize
{
  return (viewPortSize / 2) + offsetFromCenter.asSize() + (itemSize / 2)
}

protocol Driver {
  var content : UIView { get }
  func build(for size: CGSize) -> CGSize
  mutating func layout(origin: CGPoint)
  mutating func layout(size: CGSize)
  mutating func bind(to uiRect: CGRect)
}

class ViewController : UIViewController, SpriteDriverDelegate
{
  func didAddEdge() {
    Current.file.save(Current.model)
  }
  
  var viewport : CanvasViewport!
  var driver : SpriteDriver
  var driverLayout : PositionedLayout<IssuedLayout<LayoutToDriver<SpriteDriver>>>
  var scaleObserver : NotificationObserver!
  var scale: CGFloat = 1.0
  
  init(driver: SpriteDriver)
  {
    self.driver = driver
    self.driverLayout = PositionedLayout(
      child: IssuedLayout(child: LayoutToDriver( child: driver )),
      ofSize: CGSize.zero,
      aligned: (.center, .center))
    super.init(nibName: nil, bundle: nil)
    self.driver.delgate = self
    scaleObserver = NotificationObserver(
      notification: scaleChangeNotification,
      block: { [weak self] in
        self?.driver.scale = $0
        self?.viewport.scale = $0
        self?.scale = $0
        print("      ------    SCALE CHANGED TO ", $0, " ------ ")
    })
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("Init with coder not implemented")
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.driver.bind(to: viewport.canvas.frame)
    let bestFit = driver.size
    
    self.driverLayout.size = bestFit
    let selection = CGRect.around(viewport.canvas.frame.center, size: bestFit)
    self.viewport.animateSelection(to: selection)
    
    self.driverLayout.layout(in: self.viewport.selection)
  }
  
  //var booley = true
  override func loadView() {
    viewport = CanvasViewport(frame: UIScreen.main.bounds, element: self.driver.content)
    self.view = viewport
    
    self.view.backgroundColor = self.driver.twoDView.scene?.backgroundColor
    
    viewport.canvasChanged = { [weak self] newSize in
      guard let self = self else { return }
      print("Beg-Canvas changed")
      //self.navigationController?.navigationBar.backgroundColor = self.booley ? #colorLiteral(red: 1, green: 0.1492801309, blue: 0, alpha: 1) : #colorLiteral(red: 0.3954176307, green: 0.8185744882, blue: 0.6274910569, alpha: 1); self.booley = !self.booley
      self.logViewport()
      self.driver.bind(to: self.viewport.canvas.frame) /// Potentially not VPCoord
      // Now that the updated canvas is bound we want to
      // *Force* a layout at the selection's origin
      // This ignores whether the selection origin changed or not
      // —functionality that is part of the self.alignedLayout stack—
      // as a side note it also ignores alignment but this
      // doesnt matter in this case since we are probabbly already snug
      self.driver.layout(origin: self.viewport.selection.origin)
    }
    viewport.selectionOriginChanged = { [weak self] _ in
      guard let self = self else { return }
      self.driverLayout.layout(in: self.viewport.selection) /// should be VPCoord

    }
    viewport.selectionSizeChanged = { [weak self] _ in
      guard let self = self else { return }

      let bestFit = (self.viewport.selection.size, self.interimScale ?? self.scale) |> self.driver.build
      self.driverLayout.size = bestFit
      self.driverLayout.layout(in: self.viewport.selection)

    }
    viewport.didBeginEdit = {

      //self.map.isHidden = false
    }
    viewport.didEndEdit = {
      Current.file.save(Current.model)
      self.viewport.animateSelection(to:  self.driverLayout.child.issuedRect! )
    }
    viewport.didBeginPan = {
    }
    viewport.didBeginZoom = {

      // viewports scale is reset at each didEndZoom call
      // driver.scale needs to store the cumulative scale
      //print("before zoom begins - scale",  self.driver.scale)
    }
    viewport.zooming = { scale in

      //self.driver.set(scale: scale)
      
      //Current.scale = scale
      self.interimScale = scale
    }
    viewport.didEndZoom = { scale in


      
      self.interimScale = nil
      //Model scale is changed here by firing a notification to all listening viewcontrollers
      postNotification(note: scaleChangeNotification, value: scale)
      
      let bestFit = self.viewport.selection.size |> self.driver.build
      self.driverLayout.size = bestFit
      self.driverLayout.layout(in: self.viewport.selection)
      

    }
  
  }
  var interimScale : CGFloat?
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }
  
  
 
  
  

  /// End Scrollview
  
}

extension CanvasViewport {
  func logViewport ()
  {
    print("----------")
    print("-ModelSpace Selection", self.selection.scaled(by: self.scale).rounded(places: 1))
    print("-PaperSpace Selection", self.selection.rounded(places: 1))
    print("-Scale", self.scale.rounded(places: 2))
    print("-Offset", self.offset.rounded(places: 1))
    print("-Canvas", self.canvas.frame.rounded(places: 1))

  }
}

extension ViewController {
  func logViewport ()
  {
    self.viewport.logViewport()
    print("+Size", self.driver.size)
    print("+Previous", self.driver._previousSize)
    print("+UIOrigin", self.driver._previousOrigin.0)
    print("+SpriteOrign", self.driver._previousOrigin.1)
    
    

    print("++++ ", self.viewport.selection.origin, " == ", self.driver._previousOrigin.0, " => ", self.viewport.selection.origin ==  self.driver._previousOrigin.0, " ++++" )
    
    
    print("----------")

  }
  
}
