//
//  CenteredGrow.swift
//  CanvasTester
//
//  Created by Justin Smith  on 12/17/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import ComposableArchitecture
import Geo
import Combine

struct CenteredGrowState : Equatable {
  let portSize : CGSize
  var grow : GrowState
  var currentScale : CGFloat
  var setter : Setter

   enum Setter : Equatable {
    case beginZoom(initalOffset: CGVector)
    case interimZoom(initalOffset: CGVector, pinch1: CGPoint, pinch2: CGPoint, center: CGPoint)
    case finalZoom(childDelta: CGPoint)
    case none
  }
  
  init(portSize: CGSize, grow: GrowState, currentScale: CGFloat, setter: Setter) {
    self.portSize = portSize
    self.grow = grow
    self.currentScale = currentScale
    self.setter = setter
    self.clip()
  }
}

extension CenteredGrowState {
  var scale : CGFloat {
    get {
      return  self.grow.read.zoomScale * self.currentScale
    }
    set {
      self.grow.read.zoomScale = newValue
    }
  }
}

import OffsetableCore
extension CenteredGrowState {
  mutating func clip() {
    let yUnits = O1(bounds: portSize.height, outerOrigin: -grow.read.contentOffset.y, outerSize: grow.read.contentSize.height, origin: grow.read.areaOfInterest.origin.y, size: grow.read.areaOfInterest.size.height)
    let xUnits = O1(bounds: portSize.width, outerOrigin: -grow.read.contentOffset.x, outerSize: grow.read.contentSize.width, origin: grow.read.areaOfInterest.origin.x, size: grow.read.areaOfInterest.size.width)
    
    let insets : (top:CGFloat, bottom:CGFloat, left:CGFloat, right:CGFloat) = ( 120, 100, 0, 0)
    let padding : CGFloat = 30
    let yUnitsClipped = clipSeperate(yUnits, insets.top + padding, insets.bottom + padding) |> S3.init
    let xUnitsClipped = clipSeperate(xUnits, insets.left + padding, insets.right + padding) |> S3.init
    
    let s2D = (xUnitsClipped |> S2.init, yUnitsClipped |> S2.init) |> zipS2
    self.grow.read.areaOfInterest = s2D.master
    self.grow.read.contentOffset =  s2D.offset
    self.grow.read.contentSize = s2D.size
    self.grow.read.rootContentFrame.size = s2D.size
  }
}

public enum CenteredGrowAction {
  case grow( GrowAction)
}

public struct CenteredGrowEnvironment {
}

import Singalong

//MARK: __________ Reducer __________
let centeredGrowReducer = Reducer<CenteredGrowState, CenteredGrowAction, CenteredGrowEnvironment>
   .combine (
      growReducer.pullback(state: \.grow, action: /CenteredGrowAction.grow, environment: {_ in GrowEnvironment()} ),
      Reducer{ (state: inout CenteredGrowState, action: CenteredGrowAction, env:CenteredGrowEnvironment ) ->  Effect<CenteredGrowAction,Never> in
     switch action {
     case .grow(.onDragBegin(_)):
      guard case let .finalZoom(tup) = state.setter else { return .none }
      
      state.setter = .none
      
      break
     
     case .grow(.onZoomBegin(_, let pinchLocations)):
             let rectFromPinches = pinchLocations.0 + pinchLocations.1
             let initialOffset = state.grow.read.rootContentFrame.center - rectFromPinches.center
             let pinch1 = pinchLocations.0
             let pinch2 = pinchLocations.1
      
             state.setter = .beginZoom(initalOffset: initialOffset)

     case .grow(.onZoom(_, let pinchLocations)):
      
      let initialOffset : CGVector
      if case .beginZoom(let iO) = state.setter {
        initialOffset = iO
      } else if case .interimZoom(let iO,_,_,_) = state.setter {
        initialOffset = iO
      }
      else { fatalError() }
      
      let newFrameCenter = (pinchLocations.0 + pinchLocations.1).center + initialOffset * state.grow.read.zoomScale
      let contentFrame = CGRect.around(newFrameCenter, size: state.grow.read.rootContentFrame.size)
      
      let pinch1 = pinchLocations.0
      let pinch2 = pinchLocations.1
      let center = newFrameCenter
      
      state.setter = .interimZoom(initalOffset: initialOffset, pinch1: pinch1, pinch2: pinch2, center: newFrameCenter)
      
      state.grow.read.rootContentFrame.center = newFrameCenter
      
     case .grow(.onZoomEnd):
      
      let setterScale = state.grow.read.zoomScale
      let oldFrame = state.grow.read.rootContentFrame
      let oldOffset = state.grow.read.contentOffset
      let portSize = state.portSize
      
      let (newOffset,newDelta) = factorOutNegativeScrollviewOffsets(scaledRootFrame: oldFrame, contentOffset: oldOffset)
      let newSize = CGSize(width: oldFrame.width + newDelta.x, height: oldFrame.height + newDelta.y)
      let additionalSizeDelta = additionalDeltaToExtendContentSizeToEdgeOfBounds(newOffset, newSize, portSize)
      let setterSize = newSize + additionalSizeDelta
      let setterContent = CGRect(origin: .zero, size:  setterSize)

      state.grow.read.rootContentFrame = setterContent
      state.grow.read.contentOffset = newOffset
      state.grow.read.contentSize = setterSize
      state.grow.read.areaOfInterest = state.grow.read.areaOfInterest.scaled(by: setterScale) + newDelta.asVector()
      state.grow.read.zoomScale = 1.0
      state.currentScale = state.currentScale * setterScale
      state.setter = .finalZoom(childDelta: newDelta)
      
      return .none
     case .grow(.onDrag(_)):
      break
     case .grow(.onDragEnd(_, let willDecelerate)):
      break
     case .grow(.onDecelerate(_)):
      break
     case .grow(.onDecelerateEnd(_)):
              
      break

    }
         return .none
  }
  
)


/// return the greater float of each point component
func takeGreaterParts(_ p1:CGPoint, _ p2: CGPoint) -> CGPoint {
  CGPoint(x: (p1.x, p2.x) |> takeGreater, y: (p1.y, p2.y) |> takeGreater)
}

/// return the greater float of each point component
func takeGreaterParts(_ s1:CGSize, _ s2: CGSize) -> CGSize {
  CGSize(width: (s1.width, s2.width) |> takeGreater, height: (s1.height, s2.height) |> takeGreater)
}

/// return the greater float
func takeGreater(_ f1: CGFloat, f2: CGFloat) -> CGFloat {
  return f1 > f2 ? f1 : f2
}
   

/// After scaling `scrollView`'s content  by setting the `rootContent.frame`
/// it's possible that the `frame.origin`is negative. When translating that to scrollView
/// offsets it is necessary to make the `offset` only positive or zero
func factorOutNegativeScrollviewOffsets(scaledRootFrame: CGRect, contentOffset: CGPoint ) -> (
  newOffset : CGPoint,
  newDelta : CGPoint
  ){
    let xOriginRel = CGPoint( -contentOffset.x  + scaledRootFrame.x, -contentOffset.y + scaledRootFrame.y)
    return (newOffset: takeGreaterParts( -xOriginRel, .zero), newDelta: takeGreaterParts( xOriginRel, .zero))
}

func additionalDeltaToExtendContentSizeToEdgeOfBounds( _ newOffset: CGPoint, _ newSize: CGSize,  _ portSize: CGSize) -> CGSize {
  let covered = newSize - newOffset.asSize()
  return ((portSize - covered), CGSize.zero) |> takeGreaterParts
}


import Singalong
import Geo
class GrowCenteredVC : UIViewController {
  var store : Store<CenteredGrowState,CenteredGrowAction>!
   var viewStore : ViewStore<CenteredGrowState,CenteredGrowAction>!
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
    let centered = CenteredGrowState(portSize: self.view.frame.size,
                                     grow: grow,
                                     currentScale:1.0 ,
                                     setter: .none)
    self.store = Store(
      initialState: centered,
      reducer: centeredGrowReducer,
      environment: CenteredGrowEnvironment()
    )
    let frame = CGRect(self.view.frame.size)
   let storeView = self.store!.scope(state: {$0.grow}, action: {.grow($0)})
    let scrollView = ScrollViewCA(frame: frame, store: storeView, rootContent: NoHitView())
    self.view.addSubview(scrollView )
    
    let aFrame = self.view.frame.inset(by: UIEdgeInsets(top: 50, left: 10, bottom: 50, right: 10))
    addBorder(view: scrollView.areaOfInterest, width: 2, color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1))
    scrollView.areaOfInterest.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 0.3021841989)
    addBorder(view: scrollView.rootContent, width: 2, color: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1))
    
    let handleV = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36) )
    handleV.layer.cornerRadius = 18
    handleV.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
    handleV.layer.opacity = 0.6
    scrollView.addSubview(handleV)
    
    let handleV2 = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36) )
    handleV2.layer.cornerRadius = 18
    handleV2.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
    handleV2.layer.opacity = 0.6
    scrollView.addSubview(handleV2)
    
    let handleV3 = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44) )
    handleV3.layer.cornerRadius = 22
    handleV3.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
    handleV3.layer.opacity = 0.3
    scrollView.addSubview(handleV3)
    
    let handleV4 = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44) )
    handleV4.layer.cornerRadius = 22
    handleV4.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
    handleV4.layer.opacity = 0.5
    scrollView.addSubview(handleV4)
    
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
      l1.text = "size: \($0.grow.read.contentSize.rounded(places: 2))"
      l2.text = "offset: \($0.grow.read.contentOffset.rounded(places: 2))"
      l3.text = "content: \($0.grow.read.rootContentFrame.rounded(places: 2))"
      l5.text = "scale: \($0.grow.read.zoomScale.rounded(places: 2))"
      
      if case let .interimZoom(tup) = $0.setter {
        handleV.center = tup.center
        handleV2.center = tup.pinch1
        handleV3.center = tup.pinch2
        handleV4.center = tup.center + tup.initalOffset
      }
   }.store(in: &self.cancellables)
  }
}

