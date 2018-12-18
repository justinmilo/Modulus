//
//  GraphNavigator.swift
//  Modular
//
//  Created by Justin Smith on 8/22/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation
import Graphe
import Singalong
import Volume
@testable import FormsCopy



public class GraphNavigator {
  init(id: String) {
    self.id = id
    graph = Current.model.getItem(id: id)!.content
  }
  /// graph is *the* ScaffGraph for all the Nav's VC's
  /// set at init. Graph is a refernce object shared by all instances of the graph editing viewcontrollers
  let graph : ScaffGraph
  
  var scale : CGFloat = 1.0 {
    didSet {
      postNotification(note: scaleChangeNotification, value: scale)
    }
  }
  
  lazy var vc: UIViewController = quadVC
  typealias ViewMap = (label: String, viewMap: [GraphEditingView])
  
  lazy var quadDriver222  =
    { ($0,Current.model.getItem(id: self.id)!) }
      >>> curry(controllerFromMap)(self)
      >>> inToOut(addBarSafely)
  
  lazy var mock : UIViewController =
    Current.viewMaps.front
      |>  curry(mockControllerFromMap)(self)
      >>> addNavBarItem
  lazy var mockInternalNav : UIViewController =
    Current.viewMaps.front
      |> curry(mockControllerFromMap)(self)
      >>> embedInNav
      >>> inToOut(styleNav)
      >>> addNavBarItem
  lazy var quadDriver : QuadDriver =
    { ($0,Current.model.getItem(id: self.id)!) }
      >>> curry(controllerFromMap)(self)
      >>> inToOut(addBarSafely)
      |> createPageController
  lazy var quadVC : UIViewController = quadDriver.group |> addNavBarItem
  lazy var quadNavs : QuadDriver  =
    { ($0, Current.model.getItem(id: self.id)!) }
      >>> curry(controllerFromMap)(self)
      >>> inToOut(addBarSafely)
      >>> embedInNav
      >>> inToOut(styleNav)
      |> createPageController
  
  func addNavBarItem<ReturnVC:UIViewController>(vc :ReturnVC ) -> ReturnVC {
    vc.navigationItem.rightBarButtonItems = [
      UIBarButtonItem(title: "AR", style: UIBarButtonItem.Style.plain , target: self, action: #selector(GraphNavigator.presentAR)),
      UIBarButtonItem(title: "3D", style: UIBarButtonItem.Style.plain , target: self, action: #selector(GraphNavigator.present3D)),
      UIBarButtonItem(title: "Info", style: UIBarButtonItem.Style.plain , target: self, action: #selector(GraphNavigator.presentInfo)),
    ]
    
    return vc
  }
  
  @objc func save() {
    Current.file.save(Current.model)
  }
  
  @objc func presentInfo() {
    let cell = Current.model.getItem(id: self.id)!
    let driver = FormDriver(initial: cell, build: colorsForm)
    driver.formViewController.navigationItem.largeTitleDisplayMode = .never
    driver.didUpdate = {
      Current.model.addOrReplace(item: $0)
    }
    let nav = embedInNav(driver.formViewController)
    nav.navigationBar.prefersLargeTitles = false
    driver.formViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Dismiss",
      style: UIBarButtonItem.Style.plain ,
      target: self,
      action: #selector(GraphNavigator.dismiss3D)
    )
    self.vc.present(nav, animated: true, completion: nil)
  }
  
  let id : String
  @objc func present3D() {
    
    if let item = Current.model.getItem(id: id) {
      Current.model.addOrReplace(item: item )
    }
    
    let scaffProvider = Current.model.getItem(id: id)!.content |> provider
    let newVC = CADViewController(grid: scaffProvider)
    
    let ulN = UINavigationController(rootViewController: newVC)
    ulN.navigationBar.prefersLargeTitles = false
    newVC.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Dismiss",
      style: UIBarButtonItem.Style.plain ,
      target: self,
      action: #selector(GraphNavigator.dismiss3D)
    )
    
    
    self.vc.present(ulN, animated: true, completion: nil)
  }
  
  @objc func presentAR() {
    
    if let item = Current.model.getItem(id: id) {
      Current.model.addOrReplace(item: item )
    }
    
    let scaffProvider = Current.model.getItem(id: id)!.content |> provider
    
    let cadController = ARScnViewController(provider: scaffProvider)
    
    let ulN = UINavigationController(rootViewController: cadController)
    ulN.navigationBar.prefersLargeTitles = false
    cadController.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Dismiss",
      style: UIBarButtonItem.Style.plain ,
      target: self,
      action: #selector(GraphNavigator.dismiss3D)
    )
    
    
    self.vc.present(ulN, animated: true, completion: nil)
  }
  
  
  
  @objc func dismiss3D() {
    self.vc.dismiss(animated: true, completion: nil)
  }
  
  
  
}

