//
//  ViewController.swift
//  ScrollViewGrower
//
//  Created by Justin Smith on 4/26/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit
import Geo
@testable import GrippableView
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

struct Changed<A: Equatable> {
  private(set) var changed : A?
  mutating func update(_ val: A) {
    if previous != val
    { changed = val }
    else { changed = nil }
    previous = val
  }
  private var previous: A
  init(_ value: A) {
    previous = value
  }
}


public struct InterfaceState<Holder:GraphHolder> {
  public var windowBounds : CGRect
  
  
  var selOriginChanged : Changed<CGPoint>
  var selSizeChanged: Changed<CGSize>
  
  public init(
               sizePreferences: [CGFloat],
               scale : CGFloat,
               windowBounds: CGRect,
               selection : CGRect
  ) {
    self.sizePreferences = sizePreferences
    self.windowBounds = windowBounds
    self.canvasState = CanvasSelectionState(frame: windowBounds, rect: selection,
                                            handleBoundary: windowBounds
                                              .inset(by: UIEdgeInsets(top: 120, left: 40, bottom: 100, right: 40)))
    selOriginChanged = Changed(selection.origin)
    selSizeChanged = Changed(selection.size)
  }
  public var sizePreferences : [CGFloat]
  
  var canvasState : CanvasSelectionState {
    didSet {
      selOriginChanged.update( self.selection.origin)
      selSizeChanged.update( self.selection.size)
    }
  }
}

extension InterfaceState {
  var canvasFrame : CGRect { self.canvasState.scroll.centered.grow.read.rootContentFrame }
  var canvasSize : CGSize { self.canvasState.scroll.canvasSize }
  var canvasOffset : CGPoint { self.canvasState.scroll.canvasOffset }
  public var selection : CGRect { self.canvasState.scroll.scrollAreaofInterest }
  /// Either interim zooming scale or final scale
  public var scale : CGFloat  {
    switch self.canvasState.scroll.centered.setter {
    case .beginZoom,
         .none:
      return self.canvasState.scroll.centered.currentScale
    case .interimZoom,
         .finalZoom:
      return  self.canvasState.scroll.centered.grow.read.rootContentTransform * self.canvasState.scroll.centered.currentScale
    }
  }
}

public enum InterfaceAction<Holder:GraphHolder> {
  case saveData
  case addOrReplace(Holder)
  case thumbnailsAddToCache(UIImage, id: String)
  case canvasAction(CanvasSelectionAction)
  var  canvasAction:CanvasSelectionAction? {
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
  let reducer =  combine (
    pullback(canvasSelectionReducer, value: \InterfaceState<Holder>.canvasState, action: \InterfaceAction<Holder>.canvasAction),
    { (state: inout InterfaceState<Holder>, action: InterfaceAction<Holder>) -> [Effect<InterfaceAction<Holder>>] in
        switch action {
        case  .thumbnailsAddToCache:
          return []
        case .saveData:
          return []
        case .addOrReplace:
          return []
        case .canvasAction(.handles(.handles(.top(.handle(.didLetGo))))),
             .canvasAction(.handles(.handles(.bottom(.handle(.didLetGo))))),
             .canvasAction(.handles(.handles(.left(.handle(.didLetGo))))),
             .canvasAction(.handles(.handles(.right(.handle(.didLetGo))))):
          
          return []
        case .canvasAction(.handles(.handles(.top(.handle(.didMoveFinger(_)))))),
             .canvasAction(.handles(.handles(.bottom(.handle(.didMoveFinger(_)))))),
              .canvasAction(.handles(.handles(.left(.handle(.didMoveFinger(_)))))),
              .canvasAction(.handles(.handles(.right(.handle(.didMoveFinger(_)))))):
          
          return [Effect{ callback in
            callback(.)
            }]
      }
  }
  )
  return reducer(&state, action)
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

import Combine
public class ViewController<Holder:GraphHolder> : UIViewController, SpriteDriverDelegate {
  var viewport : CanvasViewport!
  var driver : SpriteDriver<Holder>
  var driverLayout : PositionedLayout<IssuedLayout<LayoutToDriver<SpriteDriver<Holder>>>>
  let store: Store<InterfaceState<Holder>, InterfaceAction<Holder>>
  var cancellable : AnyCancellable!
  
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
    self.cancellable = store.$value.sink{ [weak self]
       newState in
      guard let self = self else { return }
      
//      switch newState.zoomState {
//      case .scaled(let newScale):
//        let bestFit = newState.selection.size |> self.driver.build
//        self.driverLayout.size = bestFit
//        self.driverLayout.layout(in: self.store.value.selection)
//
//      case .zooming(interimScale: let interim): break
//        //self.interimScale = scale
//
//      }
      
      
      /// viewport.canvasChanged = { [weak self] newSize in
      //self.navigationController?.navigationBar.backgroundColor = self.booley ? #colorLiteral(red: 1, green: 0.1492801309, blue: 0, alpha: 1) : #colorLiteral(red: 0.3954176307, green: 0.8185744882, blue: 0.6274910569, alpha: 1); self.booley = !self.booley
      self.driver.bind(to: newState.canvasFrame) /// Potentially not VPCoord
      // Now that the updated canvas is bound we want to
      // *Force* a layout at the selection's origin
      // This ignores whether the selection origin changed or not
      // —functionality that is part of the self.alignedLayout stack—
      // as a side note it also ignores alignment but this
      // doesnt matter in this case since we are probabbly already snug
//      self.driver.layout(origin: newState.selection.origin)
      
      if let _ = newState.selOriginChanged.changed {
        /// Selection Origin Changed
        self.driverLayout.layout(in: newState.selection) /// should be VPCoord
      }
      if let _ = newState.selSizeChanged.changed {
        let bestFit = (newState.selection.size, newState.scale) |> self.driver.build
        self.driverLayout.size = bestFit
        self.driverLayout.layout(in: self.store.value.selection)
      }
      
    }
          
  }
 
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("Init with coder not implemented")
  }
  
  
  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
//    self.driver.bind(to: store.value.canvasState.scroll.)
//    let bestFit = driver.size
//
//    self.driverLayout.size = bestFit
//    let selection = CGRect.around(viewport.canvas.frame.center, size: bestFit)
//    self.viewport.animateSelection(to: selection)
//
//    self.driverLayout.layout(in: self.store.value.selection)
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
                              store: store.view(value: { $0.canvasState}, action: {.canvasAction($0)}),
                              rootContent: self.driver.content
    )
    
    self.view = viewport
    self.view.backgroundColor = self.driver.spriteView.scene?.backgroundColor
  }
  override public func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }
  
  /// End Scrollview
  
}

