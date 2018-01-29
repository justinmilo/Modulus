//
//  ViewController.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/14/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit

class VerticalController: UIViewController, UIPageViewControllerDataSource  {
  var pageViewController: UIPageViewController!
  var content : [UIViewController]!
  
  override func viewDidLoad() {
    
    self.content = [InitialController(), InitialController()]
    
    super.viewDidLoad()
    
    let pc = UIPageControl.appearance()
    pc.pageIndicatorTintColor = .lightGray
    pc.currentPageIndicatorTintColor = .white
    self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: nil)
    self.pageViewController.dataSource = self
    self.restartAction(sender: self)
    self.addChildViewController(self.pageViewController)
    self.view.addSubview(pageViewController.view)
    self.pageViewController.didMove(toParentViewController: self)
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





















class InitialController: UIViewController, UIPageViewControllerDataSource  {

  var pageViewController: UIPageViewController!
  var content : [UIViewController]!
  
  override func viewDidLoad() {
    
    self.content = [ViewController(), TestViewController()]
    
    super.viewDidLoad()
    
    let pc = UIPageControl.appearance()
    pc.pageIndicatorTintColor = .lightGray
    pc.currentPageIndicatorTintColor = .white
    self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    self.pageViewController.dataSource = self
    self.restartAction(sender: self)
    self.addChildViewController(self.pageViewController)
    self.view.addSubview(pageViewController.view)
    self.pageViewController.didMove(toParentViewController: self)
    
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

