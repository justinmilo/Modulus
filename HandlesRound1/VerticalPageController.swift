//
//  ViewController.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/14/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit


 

class VerticalPageController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  typealias ContentType = HorizontalPageHolder
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
    self.content.forEach { (horizontal) in
      horizontal.delegate = self
    }
    
    super.viewDidLoad()
    
    self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: nil)
    self.pageViewController.dataSource = self
    self.pageViewController.delegate = self
    self.pageViewController.setViewControllers([self.viewControllerAtIndex(index: 0)], direction: .forward, animated: true, completion: nil)
    self.addChild(self.pageViewController)
    self.view.addSubview(pageViewController.view)
    self.pageViewController.didMove(toParent: self)
    
    for c in content { c.pageViewController.delegate = self }
  }

  
  func viewControllerAtIndex(index: Int) -> UIViewController {
    return self.content[index]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
   
   
    if pageViewController == content[0].pageViewController, // if caller is the first (top) controller
      completed == true, // and completed (didn't fall back)
      let first = content[0].pageViewController.viewControllers?.first, // get the sub
      let index = content[0].content.index(of: first) // grab the current subindex
    {
      let target = content[1].content[index]
      content[1].pageViewController.setViewControllers([target], direction: .forward, animated: true, completion: nil)
    }
    
    if pageViewController == content[1].pageViewController,
      completed == true,
      let first = content[1].pageViewController.viewControllers?.first,
      let index = content[1].content.index(of: first)
    {
      let target = content[0].content[index]
      content[0].pageViewController.setViewControllers([target], direction: .forward, animated: true, completion: nil)
    }
    
    guard completed else { return}
    guard let first =  pageViewController.viewControllers?.first else { return }
    print(navigationController?.title, "TAGG1-V")
    self.title = first.title
    first.navigationController?.title = first.title
    self.navigationItem.title = first.title
    self.navigationController?.title = first.title
    
    
    print(first.title, "TAGG-V")
  }
  
  // Data Source
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    print(content)
    return content.previousElement(at: content.firstIndex(of: viewController as! ContentType)! )
  }
  // Data Source
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    let con = content.nextElement(at: content.firstIndex(of: viewController as! ContentType)! )
    return con
  }
  
  
}

extension VerticalPageController : HorizontalDelegate {
  func didTransitionToViewController(vc: UIViewController) {
    self.title = vc.title
    self.navigationItem.title = vc.title
    self.navigationController?.title = vc.title
  }
  
  
}





extension Array {
  func previous(index: Index) -> Index? {
    return index == startIndex
    ?  nil
    : index - 1
  }
  func next(index: Index) -> Index? {
    return index == endIndex - 1
      ?  nil
      : index + 1
  }
  func previousElement(at index: Index) -> Element? {
    guard let prevI = self.previous(index: index) else { return nil}
    return self[prevI]
  }

  func nextElement(at index: Index) -> Element? {
    guard let nextI = self.next(index: index) else { return nil}
    return self[nextI]
  }
}


















