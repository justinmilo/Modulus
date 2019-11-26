//
//  HorizontalPageController.swift
//  Modular
//
//  Created by Justin Smith on 8/10/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

func m_stylePageControl(_ pc: UIPageControl) {
  pc.pageIndicatorTintColor = .lightGray
  pc.currentPageIndicatorTintColor = .white
}

import Foundation
import Singalong
import Geo
import GrapheNaked
import Interface

struct AppState {
  var interfaceState : StateModel<ScaffGraph>
}

enum AppAction {
  case interfaceAction(InterfaceAction<ScaffGraph>)
  
  var interfaceAction: InterfaceAction<ScaffGraph>? {
    get {
      guard case let .interfaceAction(value) = self else { return nil }
      return value
    }
    set {
      guard case .interfaceAction = self, let newValue = newValue else { return }
      self = .interfaceAction(newValue)
    }
  }
}

import ComposableArchitecture
let appReducer =  combine(
  pullback(interfaceReducer, value: \AppState.interfaceState, action: \AppAction.interfaceAction)
)

let finalAppReducer = appReducer |> logging >>> savingReducer

func savingReducer(
  _ reducer: @escaping Reducer<AppState, AppAction>
) -> Reducer<AppState, AppAction> {
  return { state, action in
  switch action {
    
  case let .interfaceAction(intAction):
    switch intAction {
      
    case .saveData:
      return []
    case .addOrReplace(_):
      return []
    case .thumbnailsAddToCache(_, _):
      return []
    }

    }
}
}

func styleNav(_ ulN: UINavigationController) {
  ulN.navigationBar.prefersLargeTitles = true
  let nav = ulN.navigationBar
  nav.barStyle = UIBarStyle.blackTranslucent
  nav.tintColor = .white
  nav.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
}

func embedInNav(_ vc: UIViewController)-> UINavigationController {
  let ulN = UINavigationController(rootViewController: vc)
  return ulN
}

func addBarSafely<T:UIViewController>(to viewController: T) {
  let vis : ()->UIVisualEffectView = {
    let v2 = UIVisualEffectView(effect: UIBlurEffect(style:.dark))
    v2.frame = viewController.view.frame.bottomLeft + (viewController.view.frame.bottomRight - unitY * 102)
    return v2
  }
  let tagID = 5000
  if viewController.view?.subviews.first(where: {$0.tag == tagID}) != nil {
    return
  }
  let copy = vis()
  copy.tag = tagID
  viewController.view?.addSubview( copy )
}
func controllerFromMap(target: Any, _ vm: (label:String, viewMap: [GraphEditingView]), graph: Item<ScaffGraph>) -> ViewController<ScaffGraph> {

  let store = Store(initialValue:
  AppState(interfaceState: StateModel(thumbnailFileName: nil)), reducer: finalAppReducer)
  let vc = ViewController(mapping: vm.viewMap, graph: graph.content, scale: 1.0, screenSize: Current.screen, store:
    store.view (
    value:{$0.interfaceState},
    action: { .interfaceAction($0) }))
  
  
//  let vc : ViewController = ViewController(mapping: vm.viewMap, graph: graph.content, scale: 1.0)
  vc.title = vm.label
  vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "3D", style: UIBarButtonItem.Style.plain , target: target, action: #selector(GraphNavigator.present3D))
  
  addBarSafely(to:vc)
  return vc
}

func mockControllerFromMap(target: Any, _ vm: (label:String, viewMap: [GraphEditingView]) ) -> UIViewController {
  let vc = UIViewController()
  vc.view.backgroundColor = .red
  vc.title = vm.label
  vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "3D", style: UIBarButtonItem.Style.plain , target: target, action: #selector(GraphNavigator.present3D))
  return vc
}

func createPageController(func1 : ((String,[GraphEditingView]))->UIViewController) -> QuadDriver {
  let top = [Current.viewMaps.plan, Current.viewMaps.rotatedPlan].map(func1)
  let bottom = [Current.viewMaps.front, Current.viewMaps.side].map(func1)
  return QuadDriver(upper: top, lower: bottom)
}


