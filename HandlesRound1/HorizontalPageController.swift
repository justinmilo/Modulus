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

protocol HorizontalDelegate : class {
  func didTransitionToViewController(vc: UIViewController)
}

class HorizontalPageHolder: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  
  typealias ContentType = UIViewController
  
  var pageViewController: UIPageViewController
  var content : [UIViewController]!
  var pageControl: UIPageControl!
  weak var delegate: HorizontalDelegate?
  
  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  init(content: [UIViewController]) {
    self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    super.init(nibName: nil, bundle: nil)
    self.content = content
  }
  
  
  override func viewDidLoad() {
    
    
    self.pageViewController.dataSource = self
    self.restartAction(sender: self)
    self.addChild(self.pageViewController)
    self.view.addSubview(pageViewController.view)

    self.pageViewController.didMove(toParent: self)
    self.pageViewController.delegate = self
    
//    // Setup pagecontrol
//    pageControl = UIPageControl(frame:
//      CGRect(origin: self.view.frame.bottomLeft,
//             size: CGSize (self.view.frame.width, -88))
//        .standardized
//    )
//    m_stylePageControl(self.pageControl)
//    pageControl.numberOfPages = content.count
//    pageControl.currentPage = 0
//    self.view.addSubview(pageControl)
    
    super.viewDidLoad()
  }
  
  lazy var vis : ()->UIVisualEffectView = {
    let v2 = UIVisualEffectView(effect: UIBlurEffect(style:.dark))
    v2.frame = self.view.frame.bottomLeft + (self.view.frame.bottomRight - unitY * 108.0)
    return v2
  }
  lazy var myVis : UIVisualEffectView = vis()
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    safeAddbarToController(viewControllers: content)
    
    
//    self.pageViewController.gestureRecognizers.forEach { (ges) in
//      myVis.addGestureRecognizer(ges)
//    }
//    pageViewController.view.addSubview(myVis)
  }
  
  func restartAction(sender: AnyObject) {
    safeAddbarToController(viewControllers: [self.viewControllerAtIndex(index: 0)])

    self.pageViewController.setViewControllers([self.viewControllerAtIndex(index: 0)], direction: .forward, animated: true, completion: nil)
  }
  
  func viewControllerAtIndex(index: Int) -> UIViewController {
    return self.content[index]
  }
  
  // Data Source
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    return content.previousElement(at: content.firstIndex(of: viewController as! ContentType)! )
  }
  // Data Source
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    return content.nextElement(at: content.firstIndex(of: viewController as! ContentType)! )
  }
  
  func safeAddbarToController(viewControllers: [UIViewController]){
    
    viewControllers.forEach { first in
      let tagID = 5000
      if nil != first.view?.subviews.first(where: {$0.tag == tagID}){
        return
      }
      
      let copy = vis()
      copy.tag = tagID
      first.view?.addSubview( copy )
    }
  }
  
  
  func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    safeAddbarToController(viewControllers: pendingViewControllers)
    
  }
  
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard completed else { return}
    guard let first =  pageViewController.viewControllers?.first else { return }
    
    self.delegate?.didTransitionToViewController(vc: first)
    print(navigationController?.title, "TAGG1")
    self.title = first.title
    first.navigationController?.title = first.title
    self.navigationItem.title = first.title
    self.navigationController?.title = first.title
    
    print(navigationController?.title, "TAGG2")
    
    print(first.title, "TAGG")
  }
  
}

