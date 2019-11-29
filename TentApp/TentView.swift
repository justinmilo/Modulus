//
//  TentView.swift
//  TentApp
//
//  Created by Justin Smith Nussli on 11/27/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import UIKit
import SwiftUI
import Interface
@testable import Modular

struct QuadTentView : UIViewControllerRepresentable {
  
  
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<QuadTentView>) -> UINavigationController {
    
    func controller(_ vc: UIViewController, _ titled : String)->UIViewController{
       vc.title = titled
      return  vc
    }
    
    let graph = TentGraph()
    
    let one = tentVC(title: "Top", graph: graph, tentMap: tentPlanMap)
    let two = tentVC( title: "Rotated Plan", graph: graph, tentMap: tentPlanMapRotated)
    let three = tentVC( title: "Front", graph: graph, tentMap: tentFrontMap)
    let four =  tentVC( title: "Side", graph: graph, tentMap: tentSideMap)

    let delegate = QuadDriver(upper: [one, two], lower: [three, four])

    let a = embedInNav(delegate.group)

    return a
    
    
  }
  
  func updateUIViewController(_ uiViewController: UINavigationController, context: UIViewControllerRepresentableContext<QuadTentView>) {
    
  }

  typealias UIViewControllerType = UINavigationController
  
  
}


