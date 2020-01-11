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
import ComposableArchitecture

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

func controllerFromMap(store:Store<AppState, AppAction>, target: Any, _ vm: (label:String, viewMap: [GraphEditingView]), graph: Item<ScaffGraph>) -> InterfaceController<ScaffGraph> {

  //  let vc = ViewController(mapping: vm.viewMap, graph: graph.content, scale: 1.0, screenSize: Current.screen, store:
  let vc = InterfaceController(store:
    store.view (
    value:{$0.interfaceState},
    action: { .interfaceAction($0) }))
  
  
//  let vc : ViewController = ViewController(mapping: vm.viewMap, graph: graph.content, scale: 1.0)
  vc.title = vm.label
  vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "3D", style: UIBarButtonItem.Style.plain , target: target, action: #selector(GraphNavigator.present3D))
  
  return vc
}

func mockControllerFromMap(target: Any, _ vm: (label:String, viewMap: [GraphEditingView]) ) -> UIViewController {
  let vc = UIViewController()
  vc.view.backgroundColor = .red
  vc.title = vm.label
  vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "3D", style: UIBarButtonItem.Style.plain , target: target, action: #selector(GraphNavigator.present3D))
  return vc
}

