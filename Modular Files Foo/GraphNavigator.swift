//
//  GraphNavigator.swift
//  Modular
//
//  Created by Justin Smith on 8/22/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation
import GrapheNaked
import Singalong
import Volume
@testable import FormsCopy
import Interface
import ComposableArchitecture







public class GraphNavigator {
  init(id: String, store: Store<AppState, AppAction>) {
    self.id = id
    self.store = store
  }
  /// graph is *the* ScaffGraph for all the Nav's VC's
  /// set at init. Graph is a refernce object shared by all instances of the graph editing viewcontrollers
  
  let store : Store<AppState, AppAction>
  
  lazy var vc: UIViewController = quadVC.group
  
  lazy var func1 : ((label: String, viewMap: [GraphEditingView])) -> ViewController  =
    { ($0,self.store.value.items.getItem(id: self.id)!) }
      >>> curry(curry(controllerFromMap)(store))(self)

  lazy var planVC : ViewController = {
    return Current.viewMaps.plan |> func1
  }()
  lazy var rotatedVC : ViewController = {
    return Current.viewMaps.rotatedPlan |> func1
  }()
  lazy var frontVC : ViewController = {
    return Current.viewMaps.front |> func1
  }()
  lazy var sideVC : ViewController = {
    return Current.viewMaps.side |> func1
  }()
  
  lazy var quadVC : QuadDriver = {
    let aQD = QuadDriver(upper: [planVC, rotatedVC], lower: [frontVC, sideVC])
    aQD.group |> self.addNavBarItem
    return aQD
  }()
  
  func addNavBarItem(vc :UIViewController ) {
    vc.navigationItem.rightBarButtonItems = [
      UIBarButtonItem(title: "AR", style: UIBarButtonItem.Style.plain , target: self, action: #selector(GraphNavigator.presentAR)),
      UIBarButtonItem(title: "3D", style: UIBarButtonItem.Style.plain , target: self, action: #selector(GraphNavigator.present3D)),
      UIBarButtonItem(title: "Info", style: UIBarButtonItem.Style.plain , target: self, action: #selector(GraphNavigator.presentInfo)),
    ]
  }
  
  @objc func save() {
    store.send(.interfaceAction(.saveData))
  }
  
  @objc func presentInfo() {
    let cell = self.store.value.items.getItem(id: self.id)!
    let driver = FormDriver(initial: cell, build: colorsForm)
    driver.formViewController.navigationItem.largeTitleDisplayMode = .never
    driver.didUpdate = {
      self.store.send(.addOrReplace($0))
      self.store.send(.interfaceAction(.saveData))
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
    if let item = self.store.value.items.getItem(id: id) {
      self.store.send(.addOrReplace(item))
    }
    //ICAN : AScaffProvider is linked by Graph |> Provider func however....
    //ICANTSHOULD : Graph -> CADGeneric3DGunkInput
    //ICANTSHOULD : ARSCNVIEWCONTROLLER should take (ScnNodes) and any other needed info
    //ICANTSHOULD : provider func should be provided by the map
    let scaffProvider = self.store.value.items.getItem(id: id)!.content |> provider
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
    if let item = self.store.value.items.getItem(id: id) {
      self.store.send(.addOrReplace(item))
    }
    
    //ICAN : AScaffProvider is linked by Graph |> Provider func however....
    //ICANTSHOULD : Graph -> CADGeneric3DGunkInput
    //ICANTSHOULD : ARSCNVIEWCONTROLLER should take (ScnNodes) and any other needed info
    //ICANTSHOULD : provider func should be provided by the map
    let scaffProvider = self.store.value.items.getItem(id: id)!.content |> provider
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

