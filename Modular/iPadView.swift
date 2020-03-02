//
//  iPadView.swift
//  Modular
//
//  Created by Justin Smith  on 1/17/20.
//  Copyright © 2020 Justin Smith. All rights reserved.
//

import SwiftUI
import Interface
import ComposableArchitecture

public struct SingleHolderView <Holder: GraphHolder>: UIViewControllerRepresentable {
  public init(store: Store<InterfaceState<Holder>, InterfaceAction<Holder>> ) {
    self.store = store
  }
  public let store :Store<InterfaceState<Holder>, InterfaceAction<Holder>>

  public func makeUIViewController(context: UIViewControllerRepresentableContext<SingleHolderView<Holder>>) -> InterfaceController<Holder> {
    let vc = InterfaceController(store:store)
    return vc
  }
  public func updateUIViewController(_ uiViewController: InterfaceController<Holder>, context: UIViewControllerRepresentableContext<SingleHolderView<Holder>>) {
  }

  public typealias UIViewControllerType = InterfaceController<Holder>

}



import Geo
public struct iPadView<Holder: GraphHolder>: View {
//  Store(
//   initialValue: QuadState(size: UIScreen.main.bounds.size * 0.5),
//    reducer:  quadReducer |> logging
//  )
  
  public init(store: Store<QuadState<Holder>, QuadAction<Holder>> ) {
    self.store = store
    
    let storeOne = store.view(value: {$0.planState}, action: { .plan($0) })
    top = SingleHolderView(store: storeOne)

    let store2 = store.view(value: {$0.rotatedPlanState}, action: { .rotated($0) })
    right = SingleHolderView(store: store2)
    
    let store3 = store.view(value: {$0.frontState}, action: { .front($0) })
    left = SingleHolderView(store: store3)
    
    let store4 = store.view(value: {$0.sideState}, action: { .side($0) })
    bottom = SingleHolderView(store: store4)
    
  }
  var top: SingleHolderView<Holder>
  var right: SingleHolderView<Holder>
  var left: SingleHolderView<Holder>
  var bottom: SingleHolderView<Holder>

  @ObservedObject public var store : Store<QuadState<Holder>, QuadAction<Holder>>
  
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

struct iPadView_Previews: PreviewProvider {
   static var previews: some View {
      /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
   }
}
