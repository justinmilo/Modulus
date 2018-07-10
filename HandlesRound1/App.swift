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





func app() -> UIViewController
{
   // graph is passed passed by reference here ...
  
  
        //let uR2 = SpriteScaffViewController(graph: graph, mapping: frontMap2)
  
  
  
  
  //return foo2( Current.viewMaps.plan)
  
  return VerticalController(upperLeft: foo2( Current.viewMaps.plan),
                            upperRight: foo2(Current.viewMaps.rotatedPlan),
                            lowerLeft: foo2(Current.viewMaps.front),
                            lowerRight: foo2(Current.viewMaps.side))

}



func foo2(_ vm: EditingViews.ViewMap) -> UIViewController
{
  let driver = SpriteDriver(mapping: vm.viewMap)
  let vc : ViewController = ViewController(driver: driver)
  let st = vm.label
  vc.title = st
  vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "3D", style: UIBarButtonItem.Style.plain , target: vc, action: #selector(ViewController.tap))
  let ulN = UINavigationController(rootViewController: vc)
  ulN.navigationBar.prefersLargeTitles = true
  let nav = ulN.navigationBar
  nav.barStyle = UIBarStyle.blackTranslucent
  nav.tintColor = .white
  nav.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
  
  return ulN
}
