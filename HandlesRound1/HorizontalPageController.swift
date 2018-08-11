//
//  HorizontalPageController.swift
//  Modular
//
//  Created by Justin Smith on 8/10/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation

class HorizontalPageHolder: UIViewController, UIPageViewControllerDataSource  {
  
  var pageViewController: UIPageViewController
  var content : [UIViewController]!
  
  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  init(content: [UIViewController])
  {
    self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    super.init(nibName: nil, bundle: nil)
    
    
    self.content = content
  }
  
  
  override func viewDidLoad() {
    
    
    let pc = UIPageControl.appearance()
    pc.pageIndicatorTintColor = .lightGray
    pc.currentPageIndicatorTintColor = .white
    self.pageViewController.dataSource = self
    self.restartAction(sender: self)
    self.addChild(self.pageViewController)
    self.view.addSubview(pageViewController.view)
    self.pageViewController.didMove(toParent: self)
    
    let v = UIView(frame: CGRect( (self.view.frame.width - 200)/2, 100, 200, 400))
    v.backgroundColor = .green
    self.view.addSubview(v)
    
    super.viewDidLoad()
  }
  
  func restartAction(sender: AnyObject) {
    self.pageViewController.setViewControllers([self.viewControllerAtIndex(index: 0)], direction: .forward, animated: true, completion: nil)
  }
  
  func viewControllerAtIndex(index: Int) -> UIViewController {
    return self.content[index]
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

