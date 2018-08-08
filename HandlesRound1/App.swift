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




class LoadingViewController : UIViewController {
  
}

public class App {
  public init() {
    Current = .mock
    
    Current.file.load { [weak self] in
      guard let self = self else { return }
      switch $0 {
      case let .success(value):
        let edit = EditViewController(
          config: EditViewContConfiguration(
            initialValue: [value])
          { (anItem:Item<ScaffGraph> , cell: UITableViewCell) -> UITableViewCell in
            cell.textLabel?.text = anItem.name
            return cell
          }
        )
        edit.didSelect = { (item, cell) in
          self.rootController.pushViewController(self.gridController, animated: true)
        }
        self.rootController.setViewControllers([edit], animated: false)
      case let .error(error):
        fatalError()
      }
    }
  }
  
  public lazy var rootController: UINavigationController = {
    
    let nav = UINavigationController(rootViewController: LoadingViewController())
    styleNav(nav)
    return nav
    
  }()
  
  
  public lazy var gridController: UIViewController = {
    let func1 = flip(curry(controllerFromMap))(self)
      //>>> embedInNav
      //>>> inToOut(styleNav)
    
    let vc = VerticalController(
      upperLeft: Current.viewMaps.plan |> func1,
      upperRight: Current.viewMaps.rotatedPlan |> func1,
      lowerLeft: Current.viewMaps.front |> func1,
      lowerRight: Current.viewMaps.side |> func1)
    vc.title = Current.viewMaps.plan.label
    vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "3D", style: UIBarButtonItem.Style.plain , target: self, action: #selector(App.present3D))
    return vc
  }()
  
  @objc func dismiss3D()
  {
    self.rootController.dismiss(animated: true, completion: nil)
  }
  
  @objc func present3D()
  {
    let scaffProvider = Current.graph |> provider
    let newVC = CADViewController(grid: scaffProvider)
    
    let ulN = UINavigationController(rootViewController: newVC)
    ulN.navigationBar.prefersLargeTitles = false
    let nav = ulN.navigationBar
    newVC.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Dismiss",
      style: UIBarButtonItem.Style.plain ,
      target: self,
      action: #selector(App.dismiss3D)
    )
    
    
    self.rootController.present(ulN, animated: true, completion: nil)
  }
  
  
  
}


func controllerFromMap(_ vm: EditingViews.ViewMap, target: Any ) -> UIViewController
{
  let driver = SpriteDriver(mapping: vm.viewMap)
  let vc : ViewController = ViewController(driver: driver)
  let st = vm.label
  vc.title = st
  vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "3D", style: UIBarButtonItem.Style.plain , target: target, action: #selector(App.present3D))
  return vc
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

func inToOut<A>( _ f: @escaping (A)->Void) -> (A)->A {
  return { a in
    f(a)
    return a
  }
}
