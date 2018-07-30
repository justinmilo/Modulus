//
//  PageViewController.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
  

  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    if viewController == controller2 { return  controller1 }
    else if viewController == controller1 { return  nil }
    return nil
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    if viewController == controller1 { return  controller2 }
    else if viewController == controller1 { return  nil }
    return nil
  }
  
  func presentationCount(for pageViewController: UIPageViewController) -> Int // The number of items reflected in the page indicator.
  {
    return 2
  }
  
  func presentationIndex(for pageViewController: UIPageViewController) -> Int // The selected item reflected in the page indicator.
  {
    return index
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard completed else { return }
    
    if let first = viewControllers?.first, first == controller1 {
      index = 0
    }
    else if let second = viewControllers?.first, second == controller2 {
      index = 1
    }
    
  }
 
  var index = 0
  var controller1 : UIViewController!
  var controller2 : UIViewController!
  
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      self.delegate = self
      self.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
