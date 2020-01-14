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

extension QuadState where Holder == ScaffGraph {
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



public typealias QuadScaffState = QuadState<ScaffGraph>


import Singalong
public struct QuadScaffView : UIViewControllerRepresentable {
  public init() {
    self.init(store: Store(
       initialValue: QuadScaffState(),
       reducer:  quadReducer |> logging
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
       reducer:  quadReducer |> logging
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
