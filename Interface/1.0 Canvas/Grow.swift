//
//  Grow.swift
//  CanvasTester
//
//  Created by Justin Smith  on 12/17/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI
import Geo
import ComposableArchitecture
import Combine


struct GrowUI : UIViewControllerRepresentable {
  typealias UIViewControllerType = GrowVC

  /// Creates a `UIViewController` instance to be presented.
  func makeUIViewController(context: Context) -> GrowVC {
    GrowVC()
  }

  /// Updates the presented `UIViewController` (and coordinator) to the latest
  /// configuration.
  func updateUIViewController(_ uiViewController: GrowVC, context: Context) {
  }
}

public struct ReadScrollState : Equatable {
  var contentSize: CGSize
  var contentOffset: CGPoint
  var rootContentFrame : CGRect
  var areaOfInterest : CGRect
  var zoomScale: CGFloat
}

struct GrowState : Equatable {
  var read: ReadScrollState
  var drag: Drag
  var zoom: Zoom
}

enum Drag {
  case dragging
  case decelerating
  case none
}


enum Zoom {
  case zooming
  case none
}

public enum GrowAction {
  case onZoomBegin( scrollState : ReadScrollState, pinchLocations:(CGPoint,CGPoint) )
  case onZoom(scrollState : ReadScrollState, pinchLocations: (CGPoint,CGPoint) )
  case onZoomEnd( scrollState : ReadScrollState )
  case onDragBegin( scrollState: ReadScrollState)
  case onDrag(scrollState: ReadScrollState)
  case onDragEnd(scrollState: ReadScrollState, willDecelerate: Bool)
  case onDecelerate(scrollState: ReadScrollState)
  case onDecelerateEnd(scrollState: ReadScrollState)
}
struct GrowEnvironment {
   
}
let growReducer = Reducer<GrowState, GrowAction, GrowEnvironment>.combine(
   Reducer{(state: inout GrowState, action: GrowAction, env: GrowEnvironment) -> Effect<GrowAction, Never> in
  switch action {
  case .onZoomBegin(let scrollState, _),
       .onZoom(let scrollState, _),
       .onZoomEnd(let scrollState),
       .onDragBegin(let scrollState),
       .onDrag(let scrollState),
       .onDragEnd(let scrollState, _),
       .onDecelerate(let scrollState),
       .onDecelerateEnd(let scrollState):
    state.read = scrollState
  }
      return .none
},
 Reducer{(state: inout GrowState, action: GrowAction, env: GrowEnvironment) -> Effect<GrowAction, Never> in
  switch action {
  case .onDragBegin:
    state.drag = .dragging
  case .onDrag: break
  case .onDragEnd(_, let willDecelerate):
    state.drag = willDecelerate ? Drag.decelerating : Drag.none
  case .onDecelerate: break
  case .onDecelerateEnd:
    state.drag = .none
  case .onZoomBegin:
    state.zoom = .zooming
  case .onZoom:
    state.zoom = .zooming
  case .onZoomEnd:
    state.zoom = .none
  }
   return .none
}
)



final class ScrollViewCA : UIScrollView, UIScrollViewDelegate
{
  var store : Store<GrowState, GrowAction>
   var viewStore : ViewStore<GrowState, GrowAction>
   var cancellables : Set<AnyCancellable> = []

  var rootContent : UIView
  var areaOfInterest = NoHitView()
  
  // MARK: - Init
  init(frame: CGRect, store: Store<GrowState, GrowAction>, rootContent:UIView) {
    self.store = store
   self.viewStore = ViewStore(store)
    self.rootContent = rootContent
    super.init(frame: frame)
    self.delegate = self
    self.contentSize = viewStore.read.contentSize
    self.contentOffset = viewStore.read.contentOffset
    self.contentInsetAdjustmentBehavior = .never
    self.rootContent.frame = viewStore.read.rootContentFrame
    self.addSubview(self.rootContent)
    self.areaOfInterest.frame = viewStore.read.areaOfInterest
    self.rootContent.addSubview(areaOfInterest)
    self.maximumZoomScale = 3.0
    self.minimumZoomScale = 0.5
    self.showsVerticalScrollIndicator = false
    self.showsHorizontalScrollIndicator = false
    viewStore.publisher.sink { [weak self] in
      guard let self = self else { return }
      
      self.set(state: $0.read)
     
    }.store(in: &self.cancellables)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.viewStore.send((.onDragBegin(scrollState: self.scrollState)))
  }
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if self.viewStore.drag == .dragging {
      self.viewStore.send((.onDrag(scrollState: self.scrollState)))
    }
    if self.viewStore.drag == .decelerating {
      self.viewStore.send(.onDecelerate(scrollState: self.scrollState))
    }
  }
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    self.viewStore.send(.onDragEnd(scrollState: self.scrollState, willDecelerate: decelerate))
  }
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.viewStore.send(.onDecelerateEnd(scrollState: self.scrollState))
  }
  func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
    guard let pinch = scrollView.pinchGestureRecognizer, pinch.numberOfTouches >= 2 else { return }
    let pinches = (pinch.location(ofTouch: 0, in: scrollView), pinch.location(ofTouch: 1, in: scrollView))
    self.viewStore.send(.onZoomBegin(scrollState: self.scrollState, pinchLocations: pinches))
  }
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    guard let pinch = scrollView.pinchGestureRecognizer, pinch.numberOfTouches >= 2 else { return }
    let pinches = (pinch.location(ofTouch: 0, in: scrollView), pinch.location(ofTouch: 1, in: scrollView))
    self.viewStore.send(.onZoom(scrollState: self.scrollState, pinchLocations: pinches))
  }
  func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    self.viewStore.send(.onZoomEnd(scrollState: self.scrollState))
  }
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    self.rootContent
  }
  
}



extension ScrollViewCA {
  var scrollState: ReadScrollState {
    ReadScrollState(contentSize: self.contentSize,
                    contentOffset: self.contentOffset,
                    rootContentFrame: self.rootContent.frame,
                    areaOfInterest: self.areaOfInterest.frame,
                    zoomScale: self.zoomScale)
  }
  
  func set(state: ReadScrollState ) {
    rootContent.transform = .init(scale: CGScale(factor: state.zoomScale))
    self.rootContent.frame = state.rootContentFrame
    self.contentSize = state.contentSize
    self.bounds.origin = state.contentOffset
    self.areaOfInterest.frame = state.areaOfInterest
  }
}


import Singalong
class GrowVC : UIViewController {
   var store : Store<GrowState,GrowAction>! {
      didSet {
         self.viewStore = ViewStore(self.store)
      }
   }
   var viewStore : ViewStore<GrowState,GrowAction>!

  private var cancellables: Set<AnyCancellable> = []
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
    
    self.store = Store(
      initialState: grow,
      reducer: growReducer,
      environment: GrowEnvironment()
    )
    let frame = CGRect(self.view.frame.size)
    let scrollView = ScrollViewCA(frame: frame, store: self.store!, rootContent: NoHitView())
    self.view.addSubview(scrollView )
    
    addBorder(view: scrollView.areaOfInterest, width: 2, color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1))
    
    let (l1,l2,l3,l4,l5) = (UILabel(),UILabel(),UILabel(),UILabel(),UILabel())
    let stackView = UIStackView(frame: CGRect(x:0,
                                              y: self.view.frame.midX - 50,
                                              width: self.view.frame.width,
                                              height: 100)
    )
    stackView.addArrangedSubview(l1)
    stackView.addArrangedSubview(l2)
    stackView.addArrangedSubview(l3)
    stackView.addArrangedSubview(l4)
    stackView.addArrangedSubview(l5)
    stackView.alignment = .center
    stackView.distribution = .equalSpacing
    stackView.axis = .vertical
    self.view.addSubview(stackView)
    
   self.viewStore.publisher.sink {
      l1.text = "size: \($0.read.contentSize.rounded(places: 2))"
      l2.text = "offset: \($0.read.contentOffset.rounded(places: 2))"
      l3.text = "content: \($0.read.rootContentFrame.rounded(places: 2))"
      l5.text = "scale: \($0.read.zoomScale.rounded(places: 2))"
   }.store(in: &self.cancellables)
  }
}
