//
//  ContentScroll.swift
//  CanvasTester
//
//  Created by Justin Smith  on 12/21/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import CoreGraphics

struct AreaOfInterestState : Equatable {
  var centered: CenteredGrowState
}
extension AreaOfInterestState {
  var canvasOffset : CGPoint { self.centered.grow.read.contentOffset }
  var canvasSize : CGSize { self.centered.grow.read.contentSize }
}
extension AreaOfInterestState {
  var scrollAreaofInterest : CGRect {
    set {
      self.centered.grow.read.areaOfInterest = newValue
    }
    get {
      self.centered.grow.read.areaOfInterest
    }
  }
  var viewAreaOfInterest: CGRect {
    set {
      let origin = newValue.origin - centered.grow.read.rootContentFrame.origin.asVector()
      let scrollAOI1 = CGRect(origin: origin, size: newValue.size)
      let scrollAOI2 = fromViewCordToScrollContent(scroll: scrollAOI1, contentOffset: canvasOffset)
      self.scrollAreaofInterest = scrollAOI2
    }
    get {
      let origin = scrollAreaofInterest.origin + centered.grow.read.rootContentFrame.origin.asVector()
      let scrollAOI = CGRect(origin: origin, size: scrollAreaofInterest.size)
      return fromScrollContentToViewCord(scroll: scrollAOI, contentOffset: canvasOffset)
    }
  }
  var scale : CGFloat {
    get {
      return  self.centered.grow.read.zoomScale * self.centered.currentScale
    }
    set {
      let dif = newValue / self.centered.currentScale
      let pattern = self.scrollAreaofInterest.scaled(by: dif)
      self.scrollAreaofInterest = pattern
      self.centered.currentScale = newValue
    }
  }
}

public enum AreaOfInterestAction {
  case scroll(CenteredGrowAction)
}

public struct AreaOfInterestEnvironment { }


import ComposableArchitecture

let contentScrollReducer = Reducer<AreaOfInterestState, AreaOfInterestAction, AreaOfInterestEnvironment>
   .combine (
      centeredGrowReducer.pullback(state: \.centered, action: /AreaOfInterestAction.scroll, environment: {_ in CenteredGrowEnvironment()})
)

import Singalong
import Geo
import Combine

class AreaOfInterestView : UIView {
  var store : Store<AreaOfInterestState,AreaOfInterestAction>
   var viewStore : ViewStore<AreaOfInterestState,AreaOfInterestAction>

  var rootContent : UIView
  init(frame: CGRect, store: Store<AreaOfInterestState,AreaOfInterestAction>, rootContent: UIView) {
    self.store = store
   self.viewStore = ViewStore(self.store)
    self.rootContent = rootContent
    super.init(frame: frame)
    self.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
   
    let frame = CGRect(self.frame.size)
   let storeView = self.store.scope(state: {$0.centered.grow}, action: {.scroll(.grow($0))})
    let scrollView = ScrollViewCA(frame: frame, store: storeView, rootContent: rootContent)
    self.addSubview(scrollView )
    //addBorder(view: rootContent, width: 1, color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1))
    //addBorder(view: scrollView.areaOfInterest, width: 2, color: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
    scrollView.areaOfInterest.backgroundColor = #colorLiteral(red: 0.6456619488, green: 0.7539917827, blue: 0.7306177563, alpha: 0.1608100551)
      
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}



class ContentScrollVC : UIViewController {
  var store : Store<AreaOfInterestState,AreaOfInterestAction>!
  private var cancellable: Cancellable!
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    let sizeBiggerThanView = self.view.bounds.size.insetBy(dx: -40, dy: -100)
    let grow = GrowState(
      read: ReadScrollState(
        contentSize: sizeBiggerThanView,
        contentOffset: CGPoint(0,0),
        rootContentFrame: CGRect(sizeBiggerThanView),
        areaOfInterest: CGRect(origin: CGPoint(50,50), size: CGSize(200,200)),
        zoomScale: 1.0),
      drag: .none,
      zoom: .none)
    let centered = CenteredGrowState(portSize: self.view.frame.size,
                                                    grow: grow,
                                                    currentScale:1.0 ,
                                                    setter: .none)
    let initialSubRect = self.view.frame.inset(by: UIEdgeInsets(top: 50, left: 10, bottom: 50, right: 10))
    let contentState = AreaOfInterestState(centered: centered)
    self.store = Store(
      initialState: contentState,
      reducer: contentScrollReducer, environment: AreaOfInterestEnvironment()
    )
    
    let frame = CGRect(self.view.frame.size)
    let scrollView = AreaOfInterestView(frame: frame, store: store, rootContent: NoHitView())
    self.view.addSubview(scrollView )
  }
    }
    
  

