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
import ComposableArchitecture
import GrapheNaked



public struct PointIndex2 : Equatable {
  public let xI, yI : Int
  public init( xI: Int, yI: Int) {
    (self.xI, self.yI) = (xI, yI)
  }
}

public struct Edge2<Content> where Content : Codable {
  public var content : Content
  public var p1 : PointIndex2
  public var p2 : PointIndex2
  
  public init( content: Content, p1: PointIndex2, p2: PointIndex2 ) {
    self.content = content
    self.p1 = p1
    self.p2 = p2
  }
}

public struct InterfaceState<Holder:GraphHolder> {
//  var screenSize : CGSize
//  var holder : Holder
  //var positions2 : Position2D
  //var edges2 : [Edge2<Holder.Content>]
  
  public var zoomState : ZoomState
  public var windowBounds : CGRect
  public var selection : CGRect
  
  public enum ZoomState {
    case zooming(interimScale:CGFloat)
    case scaled(CGFloat)
  }
  
  public init(
               sizePreferences: [CGFloat],
               scale: CGFloat,
               windowBounds: CGRect,
               selection : CGRect
    //, positions2: Position2D,
    // edges2: [Edge2<Holder.Content>]
  ) {
    self.sizePreferences = sizePreferences
    self.zoomState = ZoomState.scaled(scale)
    self.windowBounds = windowBounds
    self.selection = selection
//    self.positions2 = positions2
//    self.edges2 = edges2
  }
  public var sizePreferences : [CGFloat]
}

extension InterfaceState {
  var canvasState : CanvasState {
    get {
      CanvasState(selection: self.selection, scale: self.scale)
    }
    set {
      self.selection = newValue.selection
      self.scale = newValue.scale
    }
  }
}

public enum InterfaceAction<Holder:GraphHolder> {
  case saveData
  case addOrReplace(Holder)
  // case getItem
  //case getThumbmnailURL
  //case setThumbmnailURL
  case thumbnailsAddToCache(UIImage, id: String)
  case canvasAction(CanvasAction)
  
  var canvasAction: CanvasAction? {
    get {
      guard case let .canvasAction(value) = self else { return nil }
      return value
    }
    set {
      guard case .canvasAction = self, let newValue = newValue else { return }
      self = .canvasAction(newValue)
    }
  }
}


public func interfaceReducer<Holder:GraphHolder>(state: inout InterfaceState<Holder>, action: InterfaceAction<Holder>) -> [Effect<InterfaceAction<Holder>>] {
  
  let canvasPullback = pullback(canvasReducer, value: \InterfaceState<Holder>.canvasState, action: \InterfaceAction<Holder>.canvasAction)
  
//  switch action {
//  case  .thumbnailsAddToCache:
//    return []
//  case .saveData:
//    return []
//  case .addOrReplace:
//    return []
//  case .canvasAction(_):
//    return []
//  }
  return canvasPullback(&state, action)
}
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

public class ViewController<Holder:GraphHolder> : UIViewController, SpriteDriverDelegate {
  var viewport : CanvasViewport!
  var driver : SpriteDriver<Holder>
  var driverLayout : PositionedLayout<IssuedLayout<LayoutToDriver<SpriteDriver<Holder>>>>
  let store: Store<InterfaceState<Holder>, InterfaceAction<Holder>>
  
  public init(mapping: [ GenericEditingView<Holder>], graph: Holder, scale: CGFloat, screenSize: CGRect, store: Store<InterfaceState<Holder>, InterfaceAction<Holder>> )
  {
    self.store = store
    self.driver = SpriteDriver(mapping: mapping, graph: graph, screenSize: screenSize, sizePreferences: self.store.value.sizePreferences, store: store)
    self.driverLayout = PositionedLayout(
      child: IssuedLayout(child: LayoutToDriver( child: driver )),
      ofSize: CGSize.zero,
      aligned: (.center, .center))
    super.init(nibName: nil, bundle: nil)
    self.driver.delgate = self
    store.subscribe{ [weak self]
       newState in
      
      switch newState.zoomState {
      case .scaled(let newScale):
        let bestFit = self.store.value.selection.size |> self.driver.build
        self.driverLayout.size = bestFit
        self.driverLayout.layout(in: self.store.value.selection)
        
      case .zooming(interimScale: let interim):
        self.interimScale = scale

      }
      
        //self?.viewport.scale = newState.scale
      }
    }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("Init with coder not implemented")
  }
  
  
  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.driver.bind(to: viewport.canvas.frame)
    let bestFit = driver.size
    
    self.driverLayout.size = bestFit
    let selection = CGRect.around(viewport.canvas.frame.center, size: bestFit)
    self.viewport.animateSelection(to: selection)
    
    self.driverLayout.layout(in: self.store.value.selection)
  }
  
  func saveSnapshot(view: UIView) {
    // Save Image to Cache...

    let img = image(with:view)!
    //let img = image(with:self.view)!
    let newSize = CGSize(width: view.bounds.width,  height: view.bounds.height)
    
    DispatchQueue.global(qos: .background).async {
      let cropped = cropToBounds(image: img, width: newSize.width, height:newSize
        .height)
      
      self.store.send(.thumbnailsAddToCache(cropped, id: self.driver.graph.id))
      //let urlRes = Current.thumbnails.addToCache(cropped, item.thumbnailFileName)
      
      }
    // ...End Save Image
  }
  
  
  func didAddEdge() {
    self.saveSnapshot(view: self.view)

    self.store.send(.saveData)
  }
  
  //var booley = true
  override public func loadView() {
    viewport = CanvasViewport(frame: store.value.windowBounds,
                              element: self.driver.content,
                              store:store.view(value: { $0.canvasState
                              }, action: {
                                .canvasAction($0)
                              }))
    self.view = viewport
    
    self.view.backgroundColor = self.driver.spriteView.scene?.backgroundColor
    
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
      self.driver.layout(origin: self.store.value.selection.origin)
    }
    viewport.selectionOriginChanged = { [weak self] _ in
      guard let self = self else { return }
      self.driverLayout.layout(in: self.store.value.selection) /// should be VPCoord

    }
    viewport.selectionSizeChanged = { [weak self] _ in
      guard let self = self else { return }

      let bestFit = (self.store.value.selection.size, self.interimScale ?? self.store.value.scale) |> self.driver.build
      self.driverLayout.size = bestFit
      self.driverLayout.layout(in: self.store.value.selection)

    }
    viewport.didBeginEdit = {

      //self.map.isHidden = false
    }
    viewport.animationFinished = {
      self.store.send(.saveData)
    }
    viewport.didEndEdit = {
      
      self.saveSnapshot(view: self.view)

      self.store.send(.saveData)
      
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
    }
    viewport.didEndZoom = { scale in

      self.interimScale = nil
      //Model scale is changed here by firing a notification to all listening viewcontrollers
      //self.store.send(.zoomDidEnd(scale: scale))
      
      
    }
  
  }
  override public func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }
  
  
 
  
  

  /// End Scrollview
  
}

extension CanvasViewport {
  func logViewport ()
  {
    print("----------")
    //print("-ModelSpace Selection", self.selection.scaled(by: self.scale).rounded(places: 1))
    //print("-PaperSpace Selection", self.selection.rounded(places: 1))
    //print("-Scale", self.scale.rounded(places: 2))
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
    
    

    //print("++++ ", self.viewport.selection.origin, " == ", self.driver._previousOrigin.0, " => ", self.viewport.selection.origin ==  self.driver._previousOrigin.0, " ++++" )
    
    
    print("----------")

  }
  
}
