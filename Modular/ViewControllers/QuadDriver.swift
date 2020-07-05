//
//  QuadDriver.swift
//  Modular
//
//  Created by Justin Smith on 8/22/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation


public struct PageState : Equatable {
  var currentlyTop = true
  var currentlyLeft = true
  var horizontalIndex : Int { return currentlyLeft ? 0 : 1  }
  var verticalIndex : Int { return currentlyTop ? 0 : 1  }
  
  public var currentQuadrant : Quadrant {
    switch (currentlyTop, currentlyLeft) {
    case (true, true): return .topLeft
    case (true, false): return .topRight
    case (false, true): return .bottomLeft
    case (false, false): return .bottomRight
    }
  }
  public enum Quadrant{
    case topLeft, topRight, bottomLeft, bottomRight
  }
}

public enum PageAction {
  case didPageVertically
  case didPageHorizontally
}

public struct PageEnvironment {
   
}

import Combine
import Singalong
let pageReducer =  Reducer<PageState, PageAction, PageEnvironment>{
   (state: inout PageState, action: PageAction, env: PageEnvironment) in
  switch action {
  case .didPageVertically:
    state.currentlyTop.toggle()
  case .didPageHorizontally:
    state.currentlyLeft.toggle()
  }
   return .none
}

import ComposableArchitecture


class QuadDriverCA : NSObject{

  public var store: Store<PageState,PageAction>
   public var viewStore: ViewStore<PageState,PageAction>
   private var cancellables : Set<AnyCancellable> = []

  private var upperPVC : UIPageViewController
  private var lowerPVC : UIPageViewController
  private var groupPVC : UIPageViewController
  public var group : UIViewController { groupPVC }
  
  public var upper : [UIViewController]
  public var lower : [UIViewController]
  private var groupMatrix : [[UIViewController]] { return [upper, lower] }
  
  init (store: Store<PageState,PageAction>, upper:[UIViewController],
        lower:[UIViewController]){
    self.store = store
   self.viewStore = ViewStore(self.store)
    let hor1 = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    let hor2 = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    let vert = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical)
    (self.upperPVC, self.lowerPVC, self.groupPVC) = (hor1, hor2, vert)
    self.upperPVC.setViewControllers([upper[0]], direction: .forward, animated: false, completion: {_ in})
    self.lowerPVC.setViewControllers([lower[0]], direction: .forward, animated: false, completion: {_ in})
    self.groupPVC.setViewControllers([upperPVC], direction: .forward, animated: false, completion: {_ in})
    self.upper = upper
    self.lower = lower
    super.init()
    hor1.delegate = self
    hor1.dataSource = self
    hor2.delegate = self
    hor2.dataSource = self
    vert.delegate = self
    vert.dataSource = self
    viewStore.publisher.sink {
      [weak self] state in
      guard let self = self else { return }
      self.groupPVC.title = self.groupMatrix[state.verticalIndex][state.horizontalIndex].title
      //TODO : confirm if this is really the right way to avoid the pageview bug
      // https://stackoverflow.com/questions/24000712/pageviewcontroller-setviewcontrollers-crashes-with-invalid-parameter-not-satisf
      DispatchQueue.main.async {
        if state.currentlyTop {
          self.lowerPVC.setViewControllers([lower[state.horizontalIndex]], direction: .forward, animated: false, completion: {_ in})
        } else {
          self.upperPVC.setViewControllers([upper[state.horizontalIndex]], direction: .forward, animated: false, completion: {_ in})
        }
      }
    }.store(in: &self.cancellables)
  }
}
extension QuadDriverCA : UIPageViewControllerDelegate, UIPageViewControllerDataSource {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    print(pageViewController)
    switch  pageViewController {
    case upperPVC:
      switch viewController{
      case upper[0]: return nil
      case upper[1]: return upper[0]
      default: fatalError()
      }
    case lowerPVC:
      switch viewController{
      case lower[0]: return nil
      case lower[1]: return lower[0]
      default: fatalError()
      }
    case groupPVC:
      switch viewController {
      case upperPVC: return nil
      case lowerPVC: return upperPVC
      default: fatalError("Only meant for three viewControllers")
      }
    default: fatalError("Only meant for three viewControllers")
    }
  }

  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    switch  pageViewController {
    case upperPVC:
      switch viewController{
      case upper[0]: return upper[1]
      case upper[1]: return nil
      default: fatalError()
      }
    case lowerPVC:
      switch viewController{
      case lower[0]: return lower[1]
      case lower[1]: return nil
      default: fatalError()
      }
    case groupPVC:
      switch viewController {
      case upperPVC: return lowerPVC
      case lowerPVC: return nil
      default: fatalError("Only meant for three viewControllers")
      }
    default: fatalError("Only meant for three viewControllers")
    }
  }
  
  // Sent when a gesture-initiated transition begins.
  func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    
  }

     
     // Sent when a gesture-initiated transition ends. The 'finished' parameter indicates whether the animation finished, while the 'completed' parameter indicates whether the transition completed or bailed out (if the user let go early).
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if completed && (pageViewController == lowerPVC || pageViewController == upperPVC) {
      self.viewStore.send(.didPageHorizontally)
    } else if completed && pageViewController == groupPVC{
      self.viewStore.send(.didPageVertically)
    }
  }
}
  
  
