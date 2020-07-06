//
//  QuadView.swift
//  Modular
//
//  Created by Justin Smith  on 1/17/20.
//  Copyright © 2020 Justin Smith. All rights reserved.
//

import Foundation

//
//  TentView.swift
//  TentApp
//
//  Created by Justin Smith  on 11/27/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import UIKit
import SwiftUI
@testable import Interface
@testable import GrippableView
import ComposableArchitecture
import Geo

public struct QuadState<Holder:GraphHolder> : Equatable{
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
  public var sizePreferences : [CGFloat]
  var pageState : PageState
  public var planState: InterfaceState<Holder>
  public var rotatedPlanState: InterfaceState<Holder>
  public var frontState: InterfaceState<Holder>
  public var sideState: InterfaceState<Holder>
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
  case plan(InterfaceAction<Holder>)
  case rotated(InterfaceAction<Holder>)
  case front(InterfaceAction<Holder>)
  case side(InterfaceAction<Holder>)
}

public struct QuadEnvironment {
   
}

public func quadReducer<Holder: GraphHolder>()->Reducer<QuadState<Holder>, QuadAction<Holder>, QuadEnvironment>{

      Reducer.combine(
         pageReducer.pullback(state: \QuadState<Holder>.pageState, action: /QuadAction<Holder>.page, environment: {_ in PageEnvironment() }),
         interfaceReducer().pullback(state: \QuadState.planState, action: /QuadAction.plan, environment: {_ in InterfaceEnvironment() })
         )
}
/*
         interfaceReducer.pullback(state: \QuadState.rotatedPlanState, action: /QuadAction.rotated),
         interfaceReducer.pullback(state: \QuadState.frontState, action: /QuadAction.front),
         interfaceReducer.pullback(state: \QuadState.sideState, action: /QuadAction.side),
  {(state: inout QuadState<Holder>, action: QuadAction<Holder>, env : QuadEnvironment) in
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
}

*/

public typealias QuadTentState = QuadState<TentGraph>

import Singalong
public struct QuadView<Holder : GraphHolder> : UIViewControllerRepresentable {
//  Store( initialValue: QuadState(), reducer:  quadReducer |> logging)
  public init(store: Store<QuadState<Holder>, QuadAction<Holder>> ) {
    self.store = store
   self.storeView = ViewStore(self.store)
   let storeOne = self.store.scope(state: {$0.planState}, action: { .plan($0) })
    let one = tentVC(store: storeOne, title: "Top")
   let store2 = self.store.scope(state: {$0.rotatedPlanState}, action: { .rotated($0) })
    let two = tentVC(store: store2, title: "Rotated Plan")
   let store3 = self.store.scope(state: {$0.frontState}, action: { .front($0) })
    let three = tentVC( store: store3, title: "Front")
   let store4 = self.store.scope(state: {$0.sideState}, action: { .side($0) })
    let four =  tentVC(store: store4, title: "Side")
   driver = QuadDriverCA(store: self.store.scope(state: {$0.pageState}, action: { .page($0) }), upper: [one, two], lower: [three, four])
  }
  private var driver : QuadDriverCA
  public let store : Store<QuadState<Holder>, QuadAction<Holder>>
   public let storeView : ViewStore<QuadState<Holder>, QuadAction<Holder>>
  public func makeUIViewController(context: UIViewControllerRepresentableContext<QuadView<Holder>>) -> UINavigationController {
    return embedInNav(driver.group)
  }
  
  public func updateUIViewController(_ uiViewController: UINavigationController, context: UIViewControllerRepresentableContext<QuadView<Holder>>) {
  }

  public typealias UIViewControllerType = UINavigationController
}


