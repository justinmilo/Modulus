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



public struct Item1UpView {
  var quad : QuadScaffState
  var item : Item<ScaffGraph>
}


public class GraphNavigator {
  public init(store: Store<Item1UpView, QuadAction<ScaffGraph>> ) {
    self.store = store
    self.quadStore = store.view(value: {$0.quad}, action: { $0 })
    let storeOne = quadStore.view(value: {$0.planState}, action: { .plan($0) })
    let one = tentVC(store: storeOne, title: "Top")
    let store2 = quadStore.view(value: {$0.rotatedPlanState}, action: { .rotated($0) })
    let two = tentVC(store: store2, title: "Rotated Plan")
    let store3 = quadStore.view(value: {$0.frontState}, action: { .front($0) })
    let three = tentVC( store: store3, title: "Front")
    let store4 = quadStore.view(value: {$0.sideState}, action: { .side($0) })
    let four =  tentVC(store: store4, title: "Side")
    driver = QuadDriverCA(store: quadStore.view(value: {$0.pageState}, action: { .page($0) }), upper: [one, two], lower: [three, four])
    driver.group  |> self.addNavBarItem
  }
  private var driver : QuadDriverCA
  public let store : Store<Item1UpView, QuadAction<ScaffGraph>>
  public let quadStore :  Store<QuadScaffState, QuadAction<ScaffGraph>>
  /// graph is *the* ScaffGraph for all the Nav's VC's
  /// set at init. Graph is a refernce object shared by all instances of the graph editing viewcontrollers
  
  lazy var vc: UIViewController = driver.group
  
  func addNavBarItem(vc :UIViewController ) {
    vc.navigationItem.rightBarButtonItems = [
      UIBarButtonItem(title: "AR", style: UIBarButtonItem.Style.plain , target: self, action: #selector(GraphNavigator.presentAR)),
      UIBarButtonItem(title: "3D", style: UIBarButtonItem.Style.plain , target: self, action: #selector(GraphNavigator.present3D)),
      UIBarButtonItem(title: "Info", style: UIBarButtonItem.Style.plain , target: self, action: #selector(GraphNavigator.presentInfo)),
    ]
  }
  
//  @objc func save() {
//    store.send(.interfaceAction(.saveData))
//  }
  
  @objc func presentInfo() {
    let cell = self.store.value.item
    let driver = FormDriver(initial: cell, build: colorsForm)
    driver.formViewController.navigationItem.largeTitleDisplayMode = .never
    driver.didUpdate = { _ in
      //self.store.send(.addOrReplace($0))
      //self.store.send(.interfaceAction(.saveData))
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
  
  @objc func present3D() {
//    if let item = self.store.value.items.getItem(id: id) {
//      self.store.send(.addOrReplace(item))
//    }
    let scaffProvider = self.store.value.item.content |> provider
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
//    if let item = self.store.value.items.getItem(id: id) {
//      self.store.send(.addOrReplace(item))
//    }
    let scaffProvider = self.store.value.item.content |> provider
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

