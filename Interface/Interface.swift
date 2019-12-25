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
import Make2D
import ComposableArchitecture
import GrapheNaked




public struct InterfaceState<Holder:GraphHolder> {
  public let windowBounds : CGRect
 
  public init(
    graph: Holder,
    mapping: [GenericEditingView<Holder>],
    sizePreferences: [CGFloat],
    scale : CGFloat,
    windowBounds: CGRect,
    selection : CGRect
  ) {
    self.windowBounds = windowBounds
    self.canvasState = CanvasSelectionState(frame: windowBounds, rect: selection,
                                            handleBoundary: windowBounds
                                              .inset(by: UIEdgeInsets(top: 120, left: 40, bottom: 100, right: 40)))
    self.spriteState =  SpriteState(scale : scale, sizePreferences: sizePreferences, boundingRect: selection, graph: graph, editingViews: mapping )
  }

  var spriteState : SpriteState<Holder>
  var canvasState : CanvasSelectionState {
    didSet {
      spriteState.frame.update(self.selection)
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

extension InterfaceState {
  public var sizePreferences : [CGFloat] { get { self.spriteState.sizePreferences } set { self.spriteState.sizePreferences = newValue} }
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
  case sprite
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
           
            }]
        case .canvasAction(.scroll(_)):
          return []
        case .canvasAction(.handles(.handles(.top(.timerUpdate)))):
          return []
        case .canvasAction(.handles(.handles(.top(.handle(.didPress(_)))))):
          return []
          
        case .canvasAction(.handles(.handles(.top(.handle(.animationComplete))))):
          return []
          
        case .canvasAction(.handles(.handles(.bottom(.timerUpdate)))):
          return []
          
        case .canvasAction(.handles(.handles(.bottom(.handle(.didPress(_)))))):
          return []
          
        case .canvasAction(.handles(.handles(.bottom(.handle(.animationComplete))))):
          return []
          
        case .canvasAction(.handles(.handles(.left(.timerUpdate)))):
          return []
          
        case .canvasAction(.handles(.handles(.left(.handle(.didPress(_)))))):
          return []
          
        case .canvasAction(.handles(.handles(.left(.handle(.animationComplete))))):
          return []
          
        case .canvasAction(.handles(.handles(.right(.timerUpdate)))):
          return []
          
        case .canvasAction(.handles(.handles(.right(.handle(.didPress(_)))))):
          return []
          
        case .canvasAction(.handles(.handles(.right(.handle(.animationComplete))))):
          return []

        case .sprite:
          return []
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
  mutating func bind(to uiRect: CGRect)
}

import Combine
public class ViewController<Holder:GraphHolder> : UIViewController, SpriteDriverDelegate {
  var viewport : CanvasViewport!
  var driver : SpriteDriver<Holder>
  let store: Store<InterfaceState<Holder>, InterfaceAction<Holder>>
  var cancellable : AnyCancellable!
  
  public init(scale: CGFloat, screenSize: CGRect, store: Store<InterfaceState<Holder>, InterfaceAction<Holder>> )
  {
    self.store = store
    self.driver = SpriteDriver(screenSize: screenSize, store: store.view(value: {$0.spriteState}, action: { _ in .sprite }))
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
      
      self.store.send(.thumbnailsAddToCache(cropped, id: self.store.value.spriteState.graph.id))
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

