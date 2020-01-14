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

public struct QuadScaffState {
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
  public var planState: InterfaceState<ScaffGraph>
  public var rotatedPlanState: InterfaceState<ScaffGraph>
  public var frontState: InterfaceState<ScaffGraph>
  public var sideState: InterfaceState<ScaffGraph>
  
  public init (graph: ScaffGraph = createScaffolding((200,200,200)), size: CGSize = UIScreen.main.bounds.size) {
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
      mapping: planMap,
      sizePreferences: self.sizePreferences,
      scale: self.scale,
      windowBounds: size.asRect(),
      offset: planOrigin)
    rotatedPlanState = InterfaceState(
      graph: myGraph,
      mapping: planMapRotated,
      sizePreferences: self.sizePreferences,
      scale: self.scale,
      windowBounds: size.asRect(),
      offset: rotatedOrigin)
    frontState = InterfaceState(
      graph: myGraph,
      mapping: frontMap,
      sizePreferences: self.sizePreferences,
      scale: self.scale,
      windowBounds: size.asRect(),
      offset: frontOrigin)
    sideState = InterfaceState(
      graph: myGraph,
      mapping: sideMap,
      sizePreferences: self.sizePreferences,
      scale: self.scale,
      windowBounds: size.asRect(),
      offset: sideOrigin)
  }
}

let scaffInterfaceReducer :  (inout InterfaceState<ScaffGraph>,  InterfaceAction<ScaffGraph>) -> [Effect<InterfaceAction<ScaffGraph>>] = interfaceReducer

public let quadScaffReducer : (inout QuadScaffState,  QuadAction<ScaffGraph>) -> [Effect<QuadAction<ScaffGraph>>] =  combine(
  pullback(pageReducer, value: \QuadScaffState.pageState, action: \QuadAction.page),
  pullback(scaffInterfaceReducer, value: \QuadScaffState.planState, action: \QuadAction.plan),
  pullback(interfaceReducer, value: \QuadScaffState.rotatedPlanState, action: \QuadAction.rotated),
  pullback(interfaceReducer, value: \QuadScaffState.frontState, action: \QuadAction.front),
  pullback(interfaceReducer, value: \QuadScaffState.sideState, action: \QuadAction.side),
  {(state: inout QuadScaffState, action: QuadAction<ScaffGraph>) -> [Effect<QuadAction<ScaffGraph>>] in
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




import Singalong
public struct QuadScaffView : UIViewControllerRepresentable {
  public init() {
    self.init(store: Store(
       initialValue: QuadScaffState(),
       reducer:  quadScaffReducer |> logging
     )
    )
  }
  public init(store: Store<QuadScaffState, QuadAction<ScaffGraph>> ) {
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
  public let store : Store<QuadScaffState, QuadAction<ScaffGraph>>
  public func makeUIViewController(context: UIViewControllerRepresentableContext<QuadScaffView>) -> UINavigationController {
    return embedInNav(driver.group)
  }
  
  public func updateUIViewController(_ uiViewController: UINavigationController, context: UIViewControllerRepresentableContext<QuadScaffView>) {
  }

  public typealias UIViewControllerType = UINavigationController
}




public struct SingleScaffView : UIViewControllerRepresentable {
  public init(store: Store<InterfaceState<ScaffGraph>, InterfaceAction<ScaffGraph>> ) {
    self.store = store
  }
  public let store :Store<InterfaceState<ScaffGraph>, InterfaceAction<ScaffGraph>>

  public func makeUIViewController(context: UIViewControllerRepresentableContext<SingleScaffView>) -> InterfaceController<ScaffGraph> {
    let vc = InterfaceController(store:store)
    return vc
  }
  public func updateUIViewController(_ uiViewController: InterfaceController<ScaffGraph>, context: UIViewControllerRepresentableContext<SingleScaffView>) {
  }

  public typealias UIViewControllerType = InterfaceController<ScaffGraph>

}



import Geo
public struct iPadScaffView: View {
  public init() {
    self.init(store: Store(
      initialValue: QuadScaffState(size: UIScreen.main.bounds.size * 0.5),
       reducer:  quadScaffReducer |> logging
     )
    )
  }
  public init(store: Store<QuadScaffState, QuadAction<ScaffGraph>> ) {
    self.store = store
    
    let storeOne = store.view(value: {$0.planState}, action: { .plan($0) })
    top = SingleScaffView(store: storeOne)

    let store2 = store.view(value: {$0.rotatedPlanState}, action: { .rotated($0) })
    right = SingleScaffView(store: store2)
    
    let store3 = store.view(value: {$0.frontState}, action: { .front($0) })
    left = SingleScaffView(store: store3)
    
    let store4 = store.view(value: {$0.sideState}, action: { .side($0) })
    bottom = SingleScaffView(store: store4)
    
  }
  var top: SingleScaffView
  var right: SingleScaffView
  var left: SingleScaffView
  var bottom: SingleScaffView

  
  @ObservedObject public var store : Store<QuadScaffState, QuadAction<ScaffGraph>>
  
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
