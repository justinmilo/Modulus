//
//  SpriteDriverViewUI.swift
//  TentApp
//
//  Created by Justin Smith Nussli on 12/27/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI
import GrapheNaked
@testable import Modular
@testable import Interface
import Combine
import ComposableArchitecture
import Geo

class SpriteDriverViewVC : UIViewController {
  var driver : SpriteDriver<TentGraph>!
  var cancellable : AnyCancellable!
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let windowBounds = self.view.frame
    var state = SpriteState(screen: windowBounds,
                            scale : 0.5,
                            sizePreferences: [100.0],
    graph: TentGraph(),
    editingViews: [tentPlanMap])
    //let offset = CGPoint(50, 100)
    //let selection = offset + state.currentSize
    //state.frame.update(selection)

    let store: Store<SpriteState<TentGraph>, Never> = Store(initialValue: state, reducer: { _, _ in return [] })

    self.driver = SpriteDriver(store: store)
    self.view.addSubview(self.driver.content)
  }
}


struct SpriteDriverViewUI : UIViewControllerRepresentable {

func makeUIViewController(context: UIViewControllerRepresentableContext<SpriteDriverViewUI>) -> SpriteDriverViewVC {
  
  return SpriteDriverViewVC()
  
}

func updateUIViewController(_ uiViewController: SpriteDriverViewVC, context: UIViewControllerRepresentableContext<SpriteDriverViewUI>) {
  
}

typealias UIViewControllerType = SpriteDriverViewVC

}
