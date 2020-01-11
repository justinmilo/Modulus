//
//  SimpleSpriteView.swift
//  TentApp
//
//  Created by Justin Smith Nussli on 12/28/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation
import GrapheNaked
import Modular
@testable import Interface

struct SpriteViewInterface {
  mutating func update(canvas: CGRect, available: CGRect, scale: CGFloat) {
    
  }
  var size: CGSize
}

struct ComplicatedSprite<Holder:GraphHolder> {
  let graph : Holder
  let editingView : GenericEditingView<Holder>
  
  init(scale : CGFloat, graph: Holder, editingView: GenericEditingView<Holder> ){
    self.editingView = editingView
    self.graph = graph
  }
}
extension ComplicatedSprite {
  var simpleSprite : SimpleSprite {
    SimpleSprite(composite: self.editingView.composite(self.graph), origin: CGPoint.zero, scale: 1.0)
  }
}

import BlackCricket
struct SimpleSprite {
  var composite : Composite
  var origin : CGPoint
  var scale : CGFloat
}


import ComposableArchitecture
import Combine
class SimpleSpriteDriver<Holder:GraphHolder> {
  public var spriteView : Sprite2DView
  let store: Store<SimpleSprite, Never>
  var cancellable : AnyCancellable!
  
  public init(store: Store<SimpleSprite, Never>) {
    self.store = store
    spriteView = Sprite2DView(frame:CGRect.zero)

    cancellable = store.$value.sink{ [weak self]
      state in
      guard let self = self else { return }
      self.spriteView.redraw(state.composite)
      self.spriteView.scale = state.scale
      self.spriteView.mainNode.position = state.origin
    }
  }
}


@testable import Modular

class SimpleSpriteVC : UIViewController {
  var driver : SimpleSpriteDriver<TentGraph>!
  var cancellable : AnyCancellable!
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    let complicatedSprite = ComplicatedSprite(scale: 1.0, graph: TentGraph(), editingView: tentPlanMap)
    let state = complicatedSprite.simpleSprite
    let store: Store<SimpleSprite, Never> = Store(initialValue: state, reducer: { _, _ in return [] })

    self.driver = SimpleSpriteDriver(store: store)
    self.driver.spriteView.frame = self.view.frame
    self.view.addSubview(self.driver.spriteView)
  }
}

import SwiftUI
struct SimpleSpriteUI : UIViewControllerRepresentable {

func makeUIViewController(context: UIViewControllerRepresentableContext<SimpleSpriteUI>) -> SimpleSpriteVC {
  return SimpleSpriteVC()
}

func updateUIViewController(_ uiViewController: SimpleSpriteVC, context: UIViewControllerRepresentableContext<SimpleSpriteUI>) {
}
typealias UIViewControllerType = SimpleSpriteVC
}
