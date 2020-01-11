//
//  InterfaceView.swift
//  TentApp
//
//  Created by Justin Smith Nussli on 12/24/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation
import CoreGraphics
import Interface
@testable import Modular
import ComposableArchitecture

struct TentState {
  var scale : CGFloat { self.planState.scale }
  public var sizePreferences : [CGFloat] = [100.0]
  
  var planState: InterfaceState<TentGraph>
  
  init () {
    planState = InterfaceState(
      graph: TentGraph(), mapping: [tentPlanMap],
      sizePreferences: self.sizePreferences,
    scale: 1.0,
    windowBounds: UIScreen.main.bounds,
    offset: CGPoint(0, 0))
  }
  

  
  
}

enum TentAction {
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
}

let tentReducer =  combine(
  pullback(interfaceReducer, value: \TentState.planState, action: \TentAction.plan),
  {(state: inout TentState, action: TentAction) -> [Effect<TentAction>] in
    
    return []
})

import SwiftUI
import Singalong
struct TentView : UIViewControllerRepresentable {
  
  let store : Store<TentState, TentAction> = Store(
    initialValue: TentState(),
    reducer:  tentReducer
       |> logging
  )
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<TentView>) -> UINavigationController {
    
    func controller(_ vc: UIViewController, _ titled : String)->UIViewController{
       vc.title = titled
      return  vc
    }
    
    let graph = TentGraph()
    
    let storeOne = self.store.view(value: {$0.planState}, action: { .plan($0) })
    let one = tentVC(store: storeOne, title: "Top")
    
    return embedInNav(one)
    
    
  }
  
  func updateUIViewController(_ uiViewController: UINavigationController, context: UIViewControllerRepresentableContext<TentView>) {
    
  }

  typealias UIViewControllerType = UINavigationController
  
  
}
