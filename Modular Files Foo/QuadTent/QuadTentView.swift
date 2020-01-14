//
//  TentView.swift
//  TentApp
//
//  Created by Justin Smith Nussli on 11/27/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import UIKit
import SwiftUI
@testable import Interface
@testable import GrippableView
import ComposableArchitecture

public struct QuadState<Holder:GraphHolder>{
  var scale : CGFloat =  1
  public var xOffset : CGFloat
  public var xOffsetR : CGFloat
  public var yOffset : CGFloat
  public var yOffsetR : CGFloat
  public var zOffset : CGFloat
  var planOrigin : CGPoint { CGPoint(xOffset, yOffset) }
  var rotatedOrigin : CGPoint { CGPoint(yOffsetR, xOffsetR) }
  var frontOrigin  : CGPoint { CGPoint(xOffset, zOffset) }
  var sideOrigin  : CGPoint { CGPoint(yOffsetR, zOffset) }
  public var sizePreferences : [CGFloat] = [100.0]
  var pageState : PageState
  public var planState: InterfaceState<Holder>
  public var rotatedPlanState: InterfaceState<Holder>
  public var frontState: InterfaceState<Holder>
  public var sideState: InterfaceState<Holder>
}

extension QuadState where Holder == TentGraph {
  public init (graph: TentGraph = TentGraph(), size: CGSize = UIScreen.main.bounds.size) {
    xOffset = 50
    yOffset = 200
    zOffset = 200
    xOffsetR = 50
    yOffsetR = 200
    
    let planOrigin : CGPoint = CGPoint(xOffset, yOffset)
    let rotatedOrigin : CGPoint = CGPoint(yOffsetR, xOffsetR)
    let frontOrigin  : CGPoint = CGPoint(xOffset, zOffset)
    let sideOrigin  : CGPoint = CGPoint(yOffsetR, zOffset)
    
    pageState = PageState(currentlyTop: true, currentlyLeft: true)
    
    let myGraph = graph
    planState = InterfaceState(
      graph: myGraph,
      mapping: [tentPlanMap],
      sizePreferences: self.sizePreferences,
      scale: self.scale,
      windowBounds: size.asRect(),
      offset: planOrigin)
    rotatedPlanState = InterfaceState(
      graph: myGraph,
      mapping: [tentPlanMapRotated],
      sizePreferences: self.sizePreferences,
      scale: self.scale,
      windowBounds: size.asRect(),
      offset: rotatedOrigin)
    frontState = InterfaceState(
      graph: myGraph,
      mapping: [tentFrontMap],
      sizePreferences: self.sizePreferences,
      scale: self.scale,
      windowBounds: size.asRect(),
      offset: frontOrigin)
    sideState = InterfaceState(
      graph: myGraph,
      mapping: [tentSideMap],
      sizePreferences: self.sizePreferences,
      scale: self.scale,
      windowBounds: size.asRect(),
      offset: sideOrigin)
  }
}

func zoomEnded(state: inout CenteredGrowState) {
  let setterScale = state.grow.read.zoomScale
  let oldFrame = state.grow.read.rootContentFrame
  let oldOffset = state.grow.read.contentOffset
  let portSize = state.portSize
  
  let (newOffset,newDelta) = factorOutNegativeScrollviewOffsets(scaledRootFrame: oldFrame, contentOffset: oldOffset)
  let newSize = CGSize(width: oldFrame.width + newDelta.x, height: oldFrame.height + newDelta.y)
  let additionalSizeDelta = additionalDeltaToExtendContentSizeToEdgeOfBounds(newOffset, newSize, portSize)
  let setterSize = newSize + additionalSizeDelta
  let setterContent = CGRect(origin: .zero, size:  setterSize)

  state.grow.read.rootContentFrame = setterContent
  state.grow.read.contentOffset = newOffset
  state.grow.read.contentSize = setterSize
  state.grow.read.areaOfInterest = state.grow.read.areaOfInterest.scaled(by: setterScale) + newDelta.asVector()
  state.grow.read.zoomScale = 1.0
  state.currentScale = state.currentScale * setterScale
  state.setter = .finalZoom(childDelta: newDelta)
}

 

public enum QuadAction<Holder: GraphHolder> {
  case page(PageAction)
  var page: PageAction? {
    get {
      guard case let .page(value) = self else { return nil }
      return value
    }
    set {
      guard case .page = self, let newValue = newValue else { return }
      self = .page(newValue)
    }
  }
  case plan(InterfaceAction<Holder>)
  var plan: InterfaceAction<Holder>? {
    get {
      guard case let .plan(value) = self else { return nil }
      return value
    }
    set {
      guard case .plan = self, let newValue = newValue else { return }
      self = .plan(newValue)
    }
  }
  case rotated(InterfaceAction<Holder>)
  var rotated: InterfaceAction<Holder>? {
    get {
      guard case let .rotated(value) = self else { return nil }
      return value
    }
    set {
      guard case .rotated = self, let newValue = newValue else { return }
      self = .rotated(newValue)
    }
  }
  case front(InterfaceAction<Holder>)
  var front: InterfaceAction<Holder>? {
    get {
      guard case let .front(value) = self else { return nil }
      return value
    }
    set {
      guard case .front = self, let newValue = newValue else { return }
      self = .front(newValue)
    }
  }
  case side(InterfaceAction<Holder>)
  var side: InterfaceAction<Holder>? {
    get {
      guard case let .side(value) = self else { return nil }
      return value
    }
    set {
      guard case .side = self, let newValue = newValue else { return }
      self = .side(newValue)
    }
  }
}

public func quadReducer<Holder:GraphHolder>(state: inout QuadState<Holder>, action: QuadAction<Holder>) -> [Effect<QuadAction<Holder>>]{
  
  let combined = combine(
  pullback(pageReducer, value: \QuadState.pageState, action: \QuadAction.page),
  pullback(interfaceReducer, value: \QuadState.planState, action: \QuadAction.plan),
  pullback(interfaceReducer, value: \QuadState.rotatedPlanState, action: \QuadAction.rotated),
  pullback(interfaceReducer, value: \QuadState.frontState, action: \QuadAction.front),
  pullback(interfaceReducer, value: \QuadState.sideState, action: \QuadAction.side),
  {(state: inout QuadState<Holder>, action: QuadAction<Holder>) -> [Effect<QuadAction<Holder>>] in
    switch action {
    case .page: break
    case .plan:
      //state.xOffset = state.planState.selectionView.x
      state.yOffset = state.planState.selectionView.y
      
      var aState = state.planState
      zoomEnded(state: &aState.canvasState.scroll.centered)
      state.xOffset = aState.selectionView.x
      
      state.scale = state.planState.scale
      state.rotatedPlanState.scale = state.scale
      state.frontState.scale = state.scale
      state.sideState.scale = state.scale


      state.frontState.selectionView = CGRect(origin: state.frontOrigin, size: state.frontState.spriteState.viewSpaceSize)
      state.sideState.selectionView = CGRect(origin: state.sideOrigin, size: state.sideState.spriteState.viewSpaceSize)
      state.rotatedPlanState.selectionView = CGRect(origin: state.rotatedOrigin, size: state.rotatedPlanState.spriteState.viewSpaceSize)
      break
    case .rotated:
      //state.yOffsetR = state.rotatedPlanState.selectionView.x
      state.xOffsetR = state.rotatedPlanState.selectionView.y
      
      var aState = state.rotatedPlanState
      zoomEnded(state: &aState.canvasState.scroll.centered)
      state.yOffsetR = aState.selectionView.x
      
      state.scale = state.rotatedPlanState.scale
      state.planState.scale = state.scale
      state.frontState.scale = state.scale
      state.sideState.scale = state.scale
      
      state.frontState.selectionView = CGRect(origin: state.frontOrigin, size: state.frontState.spriteState.viewSpaceSize)
      state.sideState.selectionView = CGRect(origin: state.sideOrigin, size: state.sideState.spriteState.viewSpaceSize)
      state.planState.selectionView = CGRect(origin: state.planOrigin, size: state.planState.spriteState.viewSpaceSize)
      break
    case .front:
//      state.xOffset = state.frontState.selectionView.x
//      state.zOffset = state.frontState.selectionView.y
      
      var aState = state.frontState
      zoomEnded(state: &aState.canvasState.scroll.centered)
      state.xOffset = aState.selectionView.x
      state.zOffset = aState.selectionView.y
      
      state.scale = state.frontState.scale
      state.planState.scale = state.scale
      state.rotatedPlanState.scale = state.scale
      state.sideState.scale = state.scale
      
      state.rotatedPlanState.selectionView = CGRect(origin: state.rotatedOrigin, size: state.rotatedPlanState.spriteState.viewSpaceSize)
      state.sideState.selectionView = CGRect(origin: state.sideOrigin, size: state.sideState.spriteState.viewSpaceSize)
      state.planState.selectionView = CGRect(origin: state.planOrigin, size: state.planState.spriteState.viewSpaceSize)
      break
      
    case .side:
//      state.yOffsetR = state.sideState.selectionView.x
//      state.zOffset = state.sideState.selectionView.y
      
      var aState = state.sideState
      zoomEnded(state: &aState.canvasState.scroll.centered)
      state.yOffsetR = aState.selectionView.x
      state.zOffset = aState.selectionView.y
      
      state.scale = state.sideState.scale
      state.planState.scale = state.scale
      state.rotatedPlanState.scale = state.scale
      state.frontState.scale = state.scale
      
      state.rotatedPlanState.selectionView = CGRect(origin: state.rotatedOrigin, size: state.rotatedPlanState.spriteState.viewSpaceSize)
      state.frontState.selectionView = CGRect(origin: state.frontOrigin, size: state.frontState.spriteState.viewSpaceSize)
      state.planState.selectionView = CGRect(origin: state.planOrigin, size: state.planState.spriteState.viewSpaceSize)
      break
    }
    return []
  }
  )
  
  return combined(&state, action)
  
}


public typealias QuadTentState = QuadState<TentGraph>

import Singalong
public struct QuadTentView : UIViewControllerRepresentable {
  public init() {
    self.init(store: Store(
       initialValue: QuadState(),
       reducer:  quadReducer |> logging
     )
    )
  }
  public init(store: Store<QuadTentState, QuadAction<TentGraph>> ) {
    self.store = store
    let storeOne = self.store.view(value: {$0.planState}, action: { .plan($0) })
    let one = tentVC(store: storeOne, title: "Top")
    let store2 = self.store.view(value: {$0.rotatedPlanState}, action: { .rotated($0) })
    let two = tentVC(store: store2, title: "Rotated Plan")
    let store3 = self.store.view(value: {$0.frontState}, action: { .front($0) })
    let three = tentVC( store: store3, title: "Front")
    let store4 = self.store.view(value: {$0.sideState}, action: { .side($0) })
    let four =  tentVC(store: store4, title: "Side")
    driver = QuadDriverCA(store: self.store.view(value: {$0.pageState}, action: { .page($0) }), upper: [one, two], lower: [three, four])
  }
  private var driver : QuadDriverCA
  public let store : Store<QuadTentState, QuadAction<TentGraph>>
  public func makeUIViewController(context: UIViewControllerRepresentableContext<QuadTentView>) -> UINavigationController {
    return embedInNav(driver.group)
  }
  
  public func updateUIViewController(_ uiViewController: UINavigationController, context: UIViewControllerRepresentableContext<QuadTentView>) {
  }

  public typealias UIViewControllerType = UINavigationController
}

public struct SingleTentView : UIViewControllerRepresentable {
  public init(store: Store<InterfaceState<TentGraph>, InterfaceAction<TentGraph>> ) {
    self.store = store
  }
  public let store :Store<InterfaceState<TentGraph>, InterfaceAction<TentGraph>>

  public func makeUIViewController(context: UIViewControllerRepresentableContext<SingleTentView>) -> InterfaceController<TentGraph> {
    let vc = InterfaceController(store:store)
    return vc
  }
  public func updateUIViewController(_ uiViewController: InterfaceController<TentGraph>, context: UIViewControllerRepresentableContext<SingleTentView>) {
  }

  public typealias UIViewControllerType = InterfaceController<TentGraph>

}



import Geo
public struct iPadView: View {
  public init() {
    self.init(store: Store(
      initialValue: QuadState(size: UIScreen.main.bounds.size * 0.5),
       reducer:  quadReducer |> logging
     )
    )
  }
  public init(store: Store<QuadTentState, QuadAction<TentGraph>> ) {
    self.store = store
    
    let storeOne = store.view(value: {$0.planState}, action: { .plan($0) })
    top = SingleTentView(store: storeOne)

    let store2 = store.view(value: {$0.rotatedPlanState}, action: { .rotated($0) })
    right = SingleTentView(store: store2)
    
    let store3 = store.view(value: {$0.frontState}, action: { .front($0) })
    left = SingleTentView(store: store3)
    
    let store4 = store.view(value: {$0.sideState}, action: { .side($0) })
    bottom = SingleTentView(store: store4)
    
  }
  var top: SingleTentView
  var right: SingleTentView
  var left: SingleTentView
  var bottom: SingleTentView

  
  @ObservedObject public var store : Store<QuadTentState, QuadAction<TentGraph>>
  
  public var body: some View {
    VStack(spacing: 0){
      HStack(spacing: 0){
        top
        right
      }
      HStack(spacing: 0){
        left
        bottom
      }
    }
  }
  
}
