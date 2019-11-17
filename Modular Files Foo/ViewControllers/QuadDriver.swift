//
//  QuadDriver.swift
//  Modular
//
//  Created by Justin Smith on 8/22/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation


class QuadDriver : PageControllerDelegate {
  
  private var upper : PageController
  private var lower : PageController
  public var group : PageController
  
  init (upper:[UIViewController],
        lower:[UIViewController]){
    // Pre-condition could gurantee the equvalence of indices ie: 2x2 matrix
    let hor1 : PageController = PageController(orientation: .horizontal, content:upper)
    
    let hor2 = PageController(orientation: .horizontal, content:lower)
    
    let vert = PageController(orientation: .vertical, content:[hor1, hor2])
    hor1.newDelegate = vert
    hor2.newDelegate = vert
    
    (self.upper, self.lower, self.group) = (hor1, hor2, vert)
    
    vert.newDelegate = self
  }
  
  func didTransition(to viewController: UIViewController, within pageController: PageController){
    
    enum Controller { case group, top, bottom }
    
    let type : Controller = pageController==group
      ? .group
      : pageController==upper
      ? .top
      : .bottom
    
    switch type {
    case .group: return
    case .top:
      let index = upper.content.firstIndex(of: viewController)!
      lower.quitelySetViewController(lower.content[index])
    case .bottom:
      let index = lower.content.firstIndex(of: viewController)!
      upper.quitelySetViewController(upper.content[index])
    }
  }
  
}
