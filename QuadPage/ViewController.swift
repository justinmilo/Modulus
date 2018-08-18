//
//  ViewController.swift
//  QuadPage
//
//  Created by Justin Smith on 8/11/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit
import Singalong
@testable import Modular


class ViewController: UIViewController {
 
  override func viewDidAppear(_ animated: Bool) {
  
    super.viewDidAppear(animated)
    // Do any additional setup after loading the view, typically from a nib.
    
    let v = CGSize(300.0, 400.0).asRect() |> UIView.init
    v.backgroundColor = .green
    self.view.addSubview(v)
    
    //: [Next](@next)
    let a : [UIViewController] = [UIColor.green, .blue, .gray, .lightGray] .map { let v = UIViewController(nibName: nil, bundle: nil)
      let scroll = UIScrollView(frame: v.view.frame)
      let scaleR = v.view.frame.scaled(by: 1.2)
      scroll.contentSize = scaleR.size
      v.view.addSubview(scroll)
      let overlay = GridView(frame: scaleR)
      scroll.addSubview(overlay)
      scroll.backgroundColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 0.170109161)
      v.view.backgroundColor = $0
      return v
    }
    
    
    let vc = VerticalPageController(
      upperLeft: a[0],
      upperRight: a[1],
      lowerLeft: a[2],
      lowerRight: a[3])
    
    

    
    self.present(vc, animated: true, completion: nil)
  }


}

