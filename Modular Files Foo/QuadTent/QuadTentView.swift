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

public struct QuadState {
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
  public var planState: InterfaceState<TentGraph>
  public var rotatedPlanState: InterfaceState<TentGraph>
  public var frontState: InterfaceState<TentGraph>
  public var sideState: InterfaceState<TentGraph>
  
  public init (graph: TentGraph = TentGraph()) {
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
    
    let myGraph = TentGraph()
    planState = InterfaceState(
      graph: myGraph,
      mapping: [tentPlanMap],
      sizePreferences: self.sizePreferences,
      scale: self.scale,
      windowBounds: UIScreen.main.bounds,
      offset: planOrigin)
    rotatedPlanState = InterfaceState(
      graph: myGraph,
      mapping: [tentPlanMapRotated],
      sizePreferences: self.sizePreferences,
      scale: self.scale,
      windowBounds: UIScreen.main.bounds,
      offset: rotatedOrigin)
    frontState = InterfaceState(
      graph: myGraph,
      mapping: [tentFrontMap],
      sizePreferences: self.sizePreferences,
      scale: self.scale,
      windowBounds: UIScreen.main.bounds,
      offset: frontOrigin)
    sideState = InterfaceState(
      graph: myGraph,
      mapping: [tentSideMap],
      sizePreferences: self.sizePreferences,
      scale: self.scale,
      windowBounds: UIScreen.main.bounds,
      offset: sideOrigin)
  }
  
  
}

public enum QuadAction {
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
  case plan(InterfaceAction<TentGraph>)
  var plan: InterfaceAction<TentGraph>? {
    get {
      guard case let .plan(value) = self else { return nil }
      return value
    }
    set {
      guard case .plan = self, let newValue = newValue else { return }
      self = .plan(newValue)
    }
  }
  case rotated(InterfaceAction<TentGraph>)
  var rotated: InterfaceAction<TentGraph>? {
    get {
      guard case let .rotated(value) = self else { return nil }
      return value
    }
    set {
      guard case .rotated = self, let newValue = newValue else { return }
      self = .rotated(newValue)
    }
  }
  case front(InterfaceAction<TentGraph>)
  var front: InterfaceAction<TentGraph>? {
    get {
      guard case let .front(value) = self else { return nil }
      return value
    }
    set {
      guard case .front = self, let newValue = newValue else { return }
      self = .front(newValue)
    }
  }
  case side(InterfaceAction<TentGraph>)
  var side: InterfaceAction<TentGraph>? {
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

public let quadReducer =  combine(
  pullback(pageReducer, value: \QuadState.pageState, action: \QuadAction.page),
  pullback(interfaceReducer, value: \QuadState.planState, action: \QuadAction.plan),
  pullback(interfaceReducer, value: \QuadState.rotatedPlanState, action: \QuadAction.rotated),
  pullback(interfaceReducer, value: \QuadState.frontState, action: \QuadAction.front),
  pullback(interfaceReducer, value: \QuadState.sideState, action: \QuadAction.side),
  {(state: inout QuadState, action: QuadAction) -> [Effect<QuadAction>] in
    switch action {
    case .page: break
    case .plan:
         state.xOffset = state.planState.selectionView.x
         state.yOffset = state.planState.selectionView.y
         
         state.scale = state.planState.scale
         state.rotatedPlanState.scale = state.scale
         state.frontState.scale = state.scale
         state.sideState.scale = state.scale
         
         state.frontState.selectionView = CGRect(origin: state.frontOrigin, size: state.frontState.spriteState.viewSpaceSize)
         state.sideState.selectionView = CGRect(origin: state.sideOrigin, size: state.sideState.spriteState.viewSpaceSize)
         state.rotatedPlanState.selectionView = CGRect(origin: state.rotatedOrigin, size: state.rotatedPlanState.spriteState.viewSpaceSize)
         break
    case .rotated:
      state.yOffsetR = state.rotatedPlanState.selectionView.x
      state.xOffsetR = state.rotatedPlanState.selectionView.y
      
      state.scale = state.rotatedPlanState.scale
      state.planState.scale = state.scale
      state.frontState.scale = state.scale
      state.sideState.scale = state.scale
      
      state.frontState.selectionView = CGRect(origin: state.frontOrigin, size: state.frontState.spriteState.viewSpaceSize)
      state.sideState.selectionView = CGRect(origin: state.sideOrigin, size: state.sideState.spriteState.viewSpaceSize)
      state.planState.selectionView = CGRect(origin: state.planOrigin, size: state.planState.spriteState.viewSpaceSize)
      break
    case .front:
      state.xOffset = state.frontState.selectionView.x
      state.zOffset = state.frontState.selectionView.y
      
      state.scale = state.frontState.scale
      state.planState.scale = state.scale
      state.rotatedPlanState.scale = state.scale
      state.sideState.scale = state.scale
      
      state.rotatedPlanState.selectionView = CGRect(origin: state.rotatedOrigin, size: state.rotatedPlanState.spriteState.viewSpaceSize)
      state.sideState.selectionView = CGRect(origin: state.sideOrigin, size: state.sideState.spriteState.viewSpaceSize)
      state.planState.selectionView = CGRect(origin: state.planOrigin, size: state.planState.spriteState.viewSpaceSize)
      break
      
    case .side:
      state.yOffsetR = state.sideState.selectionView.x
      state.zOffset = state.sideState.selectionView.y
      
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




import Singalong
public struct QuadTentView : UIViewControllerRepresentable {
  public init() {
    self.init(store: Store(
       initialValue: QuadState(),
       reducer:  quadReducer |> logging
     )
    )
  }
  public init(store: Store<QuadState, QuadAction> ) {
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
  public let store : Store<QuadState, QuadAction>
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
    return tentVC(store: self.store, title: "Top")
  }
  public func updateUIViewController(_ uiViewController: InterfaceController<TentGraph>, context: UIViewControllerRepresentableContext<SingleTentView>) {
  }

  public typealias UIViewControllerType = InterfaceController<TentGraph>

}




public struct iPadView: View {
  public init() {
    self.init(store: Store(
       initialValue: QuadState(),
       reducer:  quadReducer |> logging
     )
    )
  }
  public init(store: Store<QuadState, QuadAction> ) {
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

  
  @ObservedObject public var store : Store<QuadState, QuadAction>
  
  public var body: some View {
    VStack{
      HStack{
        top
        right
      }
      HStack{
        left
        bottom
      }
    }
  }
  
}
