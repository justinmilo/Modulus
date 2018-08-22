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
import Graphe

func addBarSafely<T:UIViewController>(to viewController: T) {
  let vis : ()->UIVisualEffectView = {
    let v2 = UIVisualEffectView(effect: UIBlurEffect(style:.dark))
    v2.frame = viewController.view.frame.bottomLeft + (viewController.view.frame.bottomRight - unitY * 102)
    return v2
  }
  
  let tagID = 5000
  
  if let view = viewController.view?.subviews.first(where: {$0.tag == tagID}){
    return
  }
  
  let copy = vis()
  copy.tag = tagID
  viewController.view?.addSubview( copy )
  
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

#warning("Move to Singalong")
func inToOut<A>( _ f: @escaping (A)->Void) -> (A)->A {
  return { a in
    f(a)
    return a
  }
}
public func zflip<A,C>(_ t: @escaping (A)->()->C ) -> (A)->(C) {
  return zurry(flip(t))
}


func controllerFromMap(target: Any, _ vm: EditingViews.ViewMap, graph: ScaffGraph) -> UIViewController {
  let driver = SpriteDriver(mapping: vm.viewMap, graph: graph, scale: 1.0)
  let vc : ViewController = ViewController(driver: driver)
  vc.title = vm.label
  vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "3D", style: UIBarButtonItem.Style.plain , target: target, action: #selector(GraphNavigator.present3D))
  return vc
}

func mockControllerFromMap(target: Any, _ vm: EditingViews.ViewMap) -> UIViewController {
  let vc = UIViewController()
  vc.view.backgroundColor = .red
  vc.title = vm.label
  vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "3D", style: UIBarButtonItem.Style.plain , target: target, action: #selector(GraphNavigator.present3D))
  return vc
}

func createPageController(func1 : (EditingViews.ViewMap)->UIViewController )->QuadDriver{
  let top = [Current.viewMaps.plan, Current.viewMaps.rotatedPlan].map(func1)
  let bottom = [Current.viewMaps.front, Current.viewMaps.side].map(func1)
  
  let quadDriver = QuadDriver(upper: top, lower: bottom)
  
  let vc = quadDriver
  return vc
}


