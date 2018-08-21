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

func addBarSafely<T:UIViewController>(to viewController: T) {
  let vis : ()->UIVisualEffectView = {
    let v2 = UIVisualEffectView(effect: UIBlurEffect(style:.dark))
    v2.frame = viewController.view.frame.bottomLeft + (viewController.view.frame.bottomRight - unitY * 88)
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



