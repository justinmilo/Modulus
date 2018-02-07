//
//  ViewController.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/14/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit

class VerticalController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  var pageViewController: UIPageViewController!
  var content : [HorizontalHolder]!
  
  override func viewDidLoad() {
    
    let size = CGSize3(width: 150, depth: 150, elev: 820)
    let graph = createSegments(with: size)
    let specialCase = SpriteScaffViewController()
    let geometry = C2Edge2DView().modelToLinework(edges: graph.frontEdgesNoZeros)
    specialCase.twoDView.geometries.append( [ geometry ])
    specialCase.twoDView.redraw(0)
    
    print(graph.frontEdgesNoZeros)
    self.content = [
      HorizontalHolder(content:  [specialCase, SpriteScaffViewController()]),
      HorizontalHolder(content:  [SpriteScaffViewController(), SpriteScaffViewController()])
    ]
    
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
    
    
    for c in content { c.pageViewController.delegate = self }
  }
  
  func restartAction(sender: AnyObject) {
    self.pageViewController.setViewControllers([self.viewControllerAtIndex(index: 0)], direction: .forward, animated: true, completion: nil)
  }
  
  func viewControllerAtIndex(index: Int) -> UIViewController {
    return self.content[index]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
   
    print("Got here")
    
    if pageViewController == content[0].pageViewController, completed == true
    {
        if let first = content[0].pageViewController.viewControllers?.first, let index = content[0].content.index(of: first)
        {
          let b = content[1]
          let target = b.content[index]
          content[1].pageViewController.setViewControllers([target],
                                                           direction: UIPageViewControllerNavigationDirection.forward,
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
                                                         direction: UIPageViewControllerNavigationDirection.forward,
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




















class HorizontalHolder: UIViewController, UIPageViewControllerDataSource  {

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
    self.addChildViewController(self.pageViewController)
    self.view.addSubview(pageViewController.view)
    self.pageViewController.didMove(toParentViewController: self)
    
    
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

