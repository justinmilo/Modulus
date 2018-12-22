//
//  PageController.swift
//  Deploy
//
//  Created by Justin Smith on 8/17/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit

protocol PageControllerDelegate : class {
  func didTransition(to viewController: UIViewController, within pageController: PageController)
}

// MARK: PageController
class PageController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate{
  
  // MARK: Data Source
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    return content.previousElement(at: content.firstIndex(of: viewController)! )
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    return content.nextElement(at: content.firstIndex(of: viewController)! )
  }
  
  // MARK: Init
  let content: [UIViewController]
  weak var newDelegate : PageControllerDelegate?
  
  init(orientation: UIPageViewController.NavigationOrientation,
       content: [UIViewController]) {
    self.content = content
    super.init(transitionStyle: .scroll, navigationOrientation: orientation, options: nil)
    self.dataSource = self
    self.delegate = self
    self.setViewControllers([content[0]], direction: .forward, animated: true, completion: nil)
  }
  
  /// Sets single viewcontroller as current without issuing any delegate callbacks
  func quitelySetViewController(_ vc: UIViewController){
    super.setViewControllers([vc], direction: UIPageViewController.NavigationDirection.forward, animated: false)
    guard let first = viewControllers?.first else { return }
    self.title = first.title
  }
  
  override func setViewControllers(_ viewControllers: [UIViewController]?, direction: UIPageViewController.NavigationDirection, animated: Bool, completion: ((Bool) -> Void)? = nil) {
    super.setViewControllers(viewControllers, direction: direction, animated: animated, completion: completion)
    
    guard let first = viewControllers?.first else { return }
    
    self.newDelegate?.didTransition(to: first, within: self)
    
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
    guard let first =  pageViewController.viewControllers?.first  else { return }
    guard let pgVC = pageViewController as? PageController else { return }

    self.newDelegate?.didTransition(to: first, within: pgVC)
    
    self.title = first.title
  }
  
  
}

extension PageController : PageControllerDelegate {
  func didTransition(to viewController: UIViewController, within pageController: PageController) {
    self.newDelegate?.didTransition(to: viewController, within: pageController)
    self.title = viewController.title
  }
  
}
