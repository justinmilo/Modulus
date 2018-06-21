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
  var alignedLayout : PositionedLayout<AnyLayout<UIView>>
  
  init(driver: ViewDriver)
  {
    self.driver = driver
    self.alignedLayout = PositionedLayout(child: LayoutToDriver( child: driver ).log().asAny,
                                     ofSize: CGSize.zero,
                                     aligned: (.center, .center))
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("Init with coder not implemented")
  }
  
  var viewport : CanvasViewport!
  var outline : UIView = {
    let v = UIView()
    v.layer.borderColor = UIColor.blue.cgColor
    v.layer.borderWidth = 2.0
    return v
  }()
  
  override func loadView() {
    viewport = CanvasViewport(frame: UIScreen.main.bounds, element: self.driver.content)
    self.view = viewport
    self.viewport.canvas.addSubview(outline)
    viewport.selectionOriginChanged = { [weak self] _ in
      guard let self = self else { return }
      
      self.outline.frame.origin = self.viewport.master.origin

      self.alignedLayout.layout(in: self.viewport.master)
    }
    viewport.selectionSizeChanged = { [weak self] _ in
      guard let self = self else { return }
      
      let bestFit = self.viewport.master.size |> self.driver.size
      
      self.alignedLayout.size = bestFit
      self.alignedLayout.layout(in: self.viewport.master)
    }
    viewport.didBeginEdit = {
      self.outline.removeFromSuperview()
    }
    viewport.didEndEdit = {
      self.outline.frame = self.viewport.master
      self.viewport.canvas.addSubview(self.outline)
    }
  
  }
  
  override func viewDidLoad() {
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
    self.driver.bind(to: self.viewport.canvas.frame)
  }
  
  @objc func tap() {
    print(self.outline.frame, self.viewport.master)
    self.outline.frame = self.viewport.master
  }
  

  /// End Scrollview
  
}


