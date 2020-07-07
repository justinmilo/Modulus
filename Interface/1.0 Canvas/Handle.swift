//
//  SimpleHandleViewTester.swift
//  CanvasTester
//
//  Created by Justin Smith  on 12/14/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import UIKit
import SwiftUI


struct SimpleHandleViewTesterUI : UIViewControllerRepresentable {  
  typealias UIViewControllerType = SimpleHandleViewTester

  /// Creates a `UIViewController` instance to be presented.
  func makeUIViewController(context: Context) -> SimpleHandleViewTester {
   SimpleHandleViewTester(store: Store(initialState: HandleState(point: CGPoint(100,100)), reducer: handleReducer, environment: HandleEnvironment()))
  }

  /// Updates the presented `UIViewController` (and coordinator) to the latest
  /// configuration.
  func updateUIViewController(_ uiViewController: SimpleHandleViewTester, context: Context) {
    
  }
  
}

struct HandleState : Equatable{
  var point: CGPoint
  var animating: Bool = false
  var hidden: Bool = false
  var delta : CGVector { point - previousLocation }
  init(point: CGPoint) {
    self.point = point
  }
  fileprivate var initialOffset = CGVector.zero // delta between touchDown center and handle center
  var previousLocation = CGPoint.zero
}

public enum HandleAction {
  case didPress(CGPoint)
  case didMoveFinger(CGPoint)
  case didLetGo
  case animationComplete
}

public struct HandleEnvironment {
   
}

import Geo
import ComposableArchitecture

let handleReducer = Reducer<HandleState, HandleAction, HandleEnvironment>
{(state: inout HandleState, action: HandleAction, env: HandleEnvironment) -> Effect<HandleAction,Never> in
  switch action {
  case .didPress(let loc):
    state.initialOffset = state.point - loc
    state.previousLocation = loc + state.initialOffset
   break
  case .didMoveFinger(let loc):
    state.previousLocation = state.point
    let newLocation = loc + state.initialOffset
    state.point = newLocation
    return .none
  case .didLetGo:
    break
  case .animationComplete: state.animating = false
  }
  return .none
}
import Combine
class SimpleHandleViewTester : UIViewController {
  var store : Store<HandleState,HandleAction>
  init(store : Store<HandleState,HandleAction> ) {
    self.store = store
    super.init(nibName: nil, bundle: nil)
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    self.view.addSubview(HandleViewCA(store: self.store))
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

import AudioToolbox

class HandleViewCA : UIView {
  private var store : Store<HandleState,HandleAction>
   private var viewStore : ViewStore<HandleState,HandleAction>

  private var cancellables: Set<AnyCancellable> = []
  var interiorView = UIView()
  var deepPressRecognized = false
  var movingGestureRecognizer : UIGestureRecognizer
  let sizeChange : CGFloat = 30.0
  let beganFrame : CGRect
  let endedFrame : CGRect
  let endedRadius : CGFloat
  let beganRadius : CGFloat
  var dontRefire : Bool = false
  
  init(store : Store<HandleState,HandleAction> ) {
    self.store = store
   self.viewStore = ViewStore(self.store)

    self.movingGestureRecognizer = UIPanGestureRecognizer()
    self.movingGestureRecognizer.isEnabled = false
    let frame = CGRect(CGSize(44, 44))
    let bounds = CGRect(origin:CGPoint.zero, size: frame.size)
    let interiorFrame = bounds.insetBy(dx: bounds.size.width/4, dy: bounds.size.height/4)
    beganFrame = interiorFrame.insetBy(dx: -sizeChange, dy: -sizeChange)
    endedFrame = interiorFrame
    beganRadius = CGFloat(frame.size.width/4) + sizeChange
    endedRadius = CGFloat(frame.size.width/4)
      
    super.init(frame: frame)
    self.interiorView.frame = interiorFrame
    interiorView.layer.cornerRadius = endedRadius
    interiorView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    interiorView.layer.opacity = 0.6

    self.addSubview(interiorView)
    self.addGestureRecognizer(movingGestureRecognizer)
    
   self.viewStore.publisher.sink{ [weak self] state in
      guard let self = self else { return }
      if state.animating && !self.dontRefire {
        self.dontRefire = true
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.allowUserInteraction, animations: { self.center = state.point }, completion: { _ in
          self.dontRefire = false
         self.viewStore.send(.animationComplete)
        })}
      else {
        self.center = state.point
      }
      if state.hidden {
        self.interiorView.isHidden = true
      }
      else {
        self.interiorView.isHidden = false
      }
    }
   .store(in: &self.cancellables)
  }
  
  public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    self.setupGesturesBased(onTrait: self.traitCollection)
  }
  override public func didMoveToSuperview() {
    self.setupGesturesBased(onTrait: self.traitCollection)
  }
  func setupGesturesBased(onTrait: UITraitCollection) {
//    if(onTrait.forceTouchCapability == UIForceTouchCapability.available) {
//      let deep = DeepPressGestureRecognizer(
//        target: self,
//        action: #selector(ButtonView.press(_:)),
//        threshold: 0.25)
//
//      self.addGestureRecognizer(deep)
//    }
//    else {
     let hold = UILongPressGestureRecognizer(target: self, action: #selector(ButtonView.press(_:)))
      self.addGestureRecognizer(hold)
      deepPressRecognized = true
//    }
  }
  
  @objc func deepPressHandler(value: DeepPressGestureRecognizer) {
    if value.state == UIGestureRecognizer.State.began {
      deepPressRecognized = true
    }
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  @objc func press( _ gesture:UIGestureRecognizer )
  {
    let loc = gesture.location(in: gesture.view!.superview!)
    
    switch gesture.state
    {
    // set initial offset and frozenB
    case .began:
      self.viewStore.send(.didPress(loc))
    // When starting a new handle move first get offset from center of ui handle button
    case .changed:
      self.viewStore.send(.didMoveFinger(loc))
    case .ended, .cancelled, .failed:
      self.viewStore.send(.didLetGo)
    default:
      return
    }
    
    switch gesture.state
    {
    case .began:
      AudioServicesPlaySystemSound(1519) // Actuate `Peek` feedback (weak boom)
      //AudioServicesPlaySystemSound(1520) // Actuate `Pop` feedback (strong boom)
      let h = self.interiorView
      h.frame = beganFrame
      h.layer.cornerRadius = beganRadius
      h.layer.opacity = 0.5
    case .ended:
      let h = self.interiorView
      h.layer.cornerRadius = endedRadius
      h.frame = endedFrame
      h.layer.opacity = 1.0
      self.deepPressRecognized = false
      return
    default:
      return
    }
  }
}
