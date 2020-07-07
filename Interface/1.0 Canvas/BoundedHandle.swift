//
//  BoundedHandle.swift
//  CanvasTester
//
//  Created by Justin Smith  on 12/15/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation

//
//  SimpleHandleViewTester.swift
//  CanvasTester
//
//  Created by Justin Smith  on 12/14/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import UIKit
import SwiftUI
import Singalong

struct BoundedHandleViewTesterUI : UIViewControllerRepresentable {
  typealias UIViewControllerType = BoundedHandleViewTester

  /// Creates a `UIViewController` instance to be presented.
  func makeUIViewController(context: Context) -> BoundedHandleViewTester {
    BoundedHandleViewTester(
      store: Store(initialState: BoundedState(boundary: CGRect(20, 50, 300, 300),
                                              handle: HandleState(point: CGPoint(100,100))),
                   reducer: boundedReducer, environment: BoundedEnvironment()))
  }

  /// Updates the presented `UIViewController` (and coordinator) to the latest
  /// configuration.
  func updateUIViewController(_ uiViewController: BoundedHandleViewTester, context: Context) {
    
  }
  
}

struct BoundedState : Equatable {
   static func == (lhs: BoundedState, rhs: BoundedState) -> Bool {
      if lhs.boundary == rhs.boundary,
         lhs.handle == rhs.handle,
         lhs.status.0 == rhs.status.0,
      lhs.status.1 == rhs.status.1,
      lhs.status.2 == rhs.status.2,
         lhs.timerFiring == rhs.timerFiring {
         return true
      } else { return false}
   }
   
  var boundary : CGRect
  var handle : HandleState
  var status : (Hor, Ver, CGVector)
   enum Hor : Equatable{
    case leftOf
    case rightOf
    case within
  }
  enum Ver : Equatable{
    case above
    case below
    case within
  }
  fileprivate var timerFiring : Bool = false
  init(boundary: CGRect, handle: HandleState) {
    self.boundary = boundary
    self.handle = handle
    let (h, v, d, _)  = withinStatus(boundary: boundary, point: handle.point)
    self.status = (h, v, d)
  }
}

func withinStatus(boundary: CGRect, point: CGPoint) -> (BoundedState.Hor, BoundedState.Ver, CGVector, clampedPoint: CGPoint) {
  let hor : BoundedState.Hor
  if point.x < boundary.minX {
    hor = .leftOf
  } else if point.x > boundary.maxX {
    hor = .rightOf
  } else {
    hor = .within
  }
  
  let ver : BoundedState.Ver
  if point.y < boundary.minY {
    ver = .above
  } else if point.y > boundary.maxY {
    ver = .below
  } else {
    ver = .within
  }
  
  let clampedPoint = point.clamp(to: boundary)
  let delta = point - clampedPoint

  return ( hor,
           ver,
           delta, clampedPoint: clampedPoint )
}

public enum BoundedAction {
  case timerUpdate
  case handle(HandleAction)
}

public struct BoundedEnvironment {
   
}

import Geo
import ComposableArchitecture

let boundedReducer = Reducer<BoundedState,BoundedAction, BoundedEnvironment>.combine(
   handleReducer.pullback(state: \.handle, action: /BoundedAction.handle, environment: {_ in HandleEnvironment() }),
   Reducer{(state: inout BoundedState, action: BoundedAction, env: BoundedEnvironment) -> Effect<BoundedAction,Never> in
    switch action {
    case .handle(.didMoveFinger):
      let stats = withinStatus(boundary: state.boundary, point: state.handle.point)
      state.status = (stats.0, stats.1, stats.2)
      
      if stats.0 == .leftOf || stats.0 == .rightOf ||
        stats.1 == .above || stats.1 == .below {
        state.timerFiring = true
        
        func otherSlope(_ x:CGFloat, lowerBounds:CGFloat)->CGFloat {
          return ((x<lowerBounds) ? 1 : -1) * pow((abs(x-lowerBounds)),1/2)*2
        }
        let y = stats.clampedPoint.y - otherSlope(state.handle.point.y, lowerBounds: stats.clampedPoint.y)
        let x = stats.clampedPoint.x - otherSlope(state.handle.point.x, lowerBounds: stats.clampedPoint.x)
        state.handle.point = CGPoint(x, y)

      } else {
        state.handle.animating = false
        state.timerFiring = false
      }
    case .handle(.didLetGo):
      state.handle.animating = true
      state.handle.point = state.handle.point.clamp(to: state.boundary)
      state.timerFiring = false
      break
    case .timerUpdate:
      break
    default: break
    }
    
      return .none
}
)

import Combine
class BoundedHandleViewTester : UIViewController {
  var store : Store<BoundedState,BoundedAction>
  private var cancellable: Cancellable!
  private var driver : BoundedHandleDriver!
  init(store : Store<BoundedState,BoundedAction> ) {
    self.store = store
    super.init(nibName: nil, bundle: nil)
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    self.driver = BoundedHandleDriver(store: self.store, view: self.view, boundaryColor: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class BoundedHandleDriver {
  private var store : Store<BoundedState,BoundedAction>
   private var viewStore : ViewStore<BoundedState,BoundedAction>

  private var cancellables: Set<AnyCancellable> = []
  var timer : Timer?
  private var outline : UIView?

  init(store : Store<BoundedState,BoundedAction>, view: UIView, boundaryColor: UIColor? = nil ) {
    self.store = store
   self.viewStore = ViewStore(self.store)
    let handleV = HandleViewCA(store: store.scope(state: {$0.handle}, action: {.handle($0)}))
    view.addSubview(handleV)
    if let bColor = boundaryColor {
      outline = NoHitView()
      addBorder(view: outline!, width: 1.0, color: bColor)
      view.addSubview(outline!)
    }
   // TO FIX
   self.viewStore.publisher.sink {  [weak self, view, handleV] in
                 guard let self = self else { return }
                   if let outlineV = self.outline {
                     outlineV.frame = $0.boundary
                     view.bringSubviewToFront(outlineV)
                     view.bringSubviewToFront(handleV)
                   }
                   
                   if $0.timerFiring {
                     if self.timer == nil || self.timer!.isValid == false {
                       self.timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true, block: { timer in
                         self.viewStore.send(.timerUpdate)
                       })
                     }
                   }
                   else {
                     self.timer?.invalidate();
                   }
                 
   }
   .store(in: &self.cancellables)
   
   // TO DELETE
   /*self.cancellable = self.viewStore.$state.sink { [weak self, view, handleV] in
      guard let self = self else { return }
      if let outlineV = self.outline {
        outlineV.frame = $0.boundary
        view.bringSubviewToFront(outlineV)
        view.bringSubviewToFront(handleV)
      }
      
      if $0.timerFiring {
        if self.timer == nil || self.timer!.isValid == false {
          self.timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true, block: { timer in
            self.viewStore.send(.timerUpdate)
          })
        }
      }
      else {
        self.timer?.invalidate();
      }
    }*/
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  
   
}
