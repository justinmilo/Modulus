//
//  PageController.swift
//  Deploy
//
//  Created by Justin Smith on 8/17/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit

protocol PageControllerDelegate : class {
  func didTransition(to viewController: UIViewController, within pageController: PageController<UIViewController>)
}

// MARK: PageController
class PageController<ControllerType:UIViewController>: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate{
  
  // MARK: Data Source
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    return content.previousElement(at: content.firstIndex(of: viewController as! ControllerType)! )
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    return content.nextElement(at: content.firstIndex(of: viewController as! ControllerType)! )
  }
  
  // MARK: Init
  let content: [ControllerType]
  weak var newDelegate : PageControllerDelegate?
  
  init(orientation: UIPageViewController.NavigationOrientation,
       content: [ControllerType]) {
    self.content = content
    super.init(transitionStyle: .scroll, navigationOrientation: orientation, options: nil)
    self.dataSource = self
    self.delegate = self
    self.setViewControllers([content[0]], direction: .forward, animated: true, completion: nil)
  }
  
  override func setViewControllers(_ viewControllers: [UIViewController]?, direction: UIPageViewController.NavigationDirection, animated: Bool, completion: ((Bool) -> Void)? = nil) {
    super.setViewControllers(viewControllers, direction: direction, animated: animated, completion: completion)
    
    guard let first = viewControllers?.first, let safeFirst = first as? ControllerType else { return }
    
    self.newDelegate?.didTransition(to: safeFirst, within: self as! PageController<UIViewController>)
    
    self.title = first.title
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MAsRK: Optional Datasource
  // The number of items reflected in the page indicator.
//  func presentationCount(for pageViewController: UIPageViewController) -> Int {
//    return self.content.count
//  }
//
//  // The selected item reflected in the page indicator.
//  func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//    return 0
//  }
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    
    
    guard completed else { return}
    guard let first =  pageViewController.viewControllers?.first, let safeFirst = first as? ControllerType else { return }

    self.newDelegate?.didTransition(to: safeFirst, within: self as! PageController<UIViewController>)
    
    self.title = first.title
  }
  
  
}

extension PageController : PageControllerDelegate {
  func didTransition(to viewController: UIViewController, within pageController: PageController<UIViewController>) {
    print(viewController.title)
    self.newDelegate?.didTransition(to: viewController, within: self as! PageController<UIViewController>)
    self.title = viewController.title
  }
  
}
