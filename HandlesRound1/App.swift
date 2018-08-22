//
//  App.swift
//  HandlesRound1
//
//  Created by Justin Smith on 3/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit
import Singalong
import Graphe
import Volume

public class App {
  public init() {
  }
  
  public lazy var rootController: UIViewController = loadEntryTable
  public lazy var mock : ()->(UIViewController) = {
    let nav = embedInNav(GraphNavigator(id: "Mock0").vc)
    styleNav(nav)
    return nav
  }
  
  lazy var loadEntryTable : UINavigationController  = {
    let load = Current.file.load()
    
    switch load {
    case let .success(value):
      
      Current.model = value
      
      let edit = EditViewController(
        config: EditViewContConfiguration(
          initialValue: value.contents)
        { (anItem:Item<ScaffGraph> , cell: UITableViewCell) -> UITableViewCell in
          cell.textLabel?.text = anItem.name
          return cell
        }
      )
      edit.didSelect = { (item, cell) in
        self.currentNavigator = GraphNavigator(id: cell.id)
        self.loadEntryTable.pushViewController(self.currentNavigator.vc, animated: true)
      }
      edit.title = "Meccano"
      let nav = UINavigationController(rootViewController: edit)
      styleNav(nav)
      return nav
    case let .error(error):
      print(error, "DUDE")
      fatalError()
    }
  
    
  }()
  var currentNavigator : GraphNavigator!
}



public class GraphNavigator {
  init(id: String) {
    self.id = id
  }
  
  var graph : ScaffGraph {
    get {
      return Current.model.getItem(id: id)!.content
    }
  }
  
  lazy var vc: UIViewController = quadVC
  typealias ViewMap = EditingViews.ViewMap

  lazy var mockCreator : (ViewMap)->UIViewController =
    curry(mockControllerFromMap)(self)
  lazy var mockInternalNavFunc : (ViewMap)->UIViewController =
    curry(mockControllerFromMap)(self)
      >>> embedInNav
      >>> inToOut(styleNav)
  
  
  lazy var mock : UIViewController =  mockCreator(Current.viewMaps.front) |> addNavBarItem
  lazy var mockInternalNav : UIViewController = mockInternalNavFunc(Current.viewMaps.front) |> addNavBarItem
  lazy var quadDriver : QuadDriver =
    { ($0, self.graph) }
      >>> curry(controllerFromMap)(self)
      >>> inToOut(addBarSafely)
      |> createPageController
  lazy var quadVC : UIViewController = quadDriver.group |> addNavBarItem
  lazy var quadNavs : QuadDriver  =
    { ($0, self.graph) }
      >>> curry(controllerFromMap)(self)
      >>> inToOut(addBarSafely)
      >>> embedInNav
      >>> inToOut(styleNav)
      |> createPageController

  func addNavBarItem<ReturnVC:UIViewController>(vc :ReturnVC ) -> ReturnVC {
    vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "3D", style: UIBarButtonItem.Style.plain , target: self, action: #selector(GraphNavigator.present3D))
    return vc
  }
  
  @objc func save() {
    Current.file.save(Current.model)
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
  
  
  
  @objc func dismiss3D() {
    self.vc.dismiss(animated: true, completion: nil)
  }
  
  
  
}



