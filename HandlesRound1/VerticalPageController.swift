//
//  ViewController.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/14/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit

class VerticalPageController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  var pageViewController: UIPageViewController!
  var content : [HorizontalPageHolder]!
  
  var conts : [UIViewController]
  init(upperLeft: UIViewController, upperRight: UIViewController, lowerLeft: UIViewController, lowerRight: UIViewController) {
    self.conts = [upperLeft, upperRight, lowerLeft, lowerRight]
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    
    
    self.content = [
      HorizontalPageHolder(content:  [conts[0], conts[1]]),
      HorizontalPageHolder(content:  [conts[2], conts[3]])
    ]
    
    super.viewDidLoad()
    
    let pc = UIPageControl.appearance()
    pc.pageIndicatorTintColor = .lightGray
    pc.currentPageIndicatorTintColor = .white
    self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: nil)
    self.pageViewController.dataSource = self
    self.restartAction(sender: self)
    self.addChild(self.pageViewController)
    self.view.addSubview(pageViewController.view)
    self.pageViewController.didMove(toParent: self)
    
    let v = UIView(frame: CGRect( (self.view.frame.width - 200)/2, 300, 50, 100))
    v.backgroundColor = .blue
    self.view.addSubview(v)
    
    for c in content { c.pageViewController.delegate = self }
  }
  
  func restartAction(sender: AnyObject) {
    self.pageViewController.setViewControllers([self.viewControllerAtIndex(index: 0)], direction: .forward, animated: true, completion: nil)
  }
  
  func viewControllerAtIndex(index: Int) -> UIViewController {
    return self.content[index]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
   
    
    if pageViewController == content[0].pageViewController, completed == true
    {
        if let first = content[0].pageViewController.viewControllers?.first, let index = content[0].content.index(of: first)
        {
          let b = content[1]
          let target = b.content[index]
          content[1].pageViewController.setViewControllers([target],
                                                           direction: UIPageViewController.NavigationDirection.forward,
                                                           animated: true,
                                                           completion: { (_) in })
        }
    }
    if pageViewController == content[1].pageViewController, completed == true
    {
      if let first = content[1].pageViewController.viewControllers?.first, let index = content[1].content.index(of: first)
      {
        let b = content[0]
        let target = b.content[index]
        content[0].pageViewController.setViewControllers([target],
                                                         direction: UIPageViewController.NavigationDirection.forward,
                                                         animated: true,
                                                         completion: { (_) in })
      }
    }
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    
    if viewController == self.content[0] {
      return nil
    }
    else if viewController == self.content[1] {
      return self.content[0]
    }
    return nil
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    
    if viewController == self.content[0] {
      return self.content[1]
    }
    else if viewController == self.content[1] {
      return nil
    }
    return nil
  }
  
  func presentationCount(for pageViewController: UIPageViewController) -> Int // The number of items reflected in the page indicator.
  {
    return self.content.count
  }
  
  func presentationIndex(for pageViewController: UIPageViewController) -> Int // The selected item reflected in the page indicator.
  {
    return 0
  }
}




















