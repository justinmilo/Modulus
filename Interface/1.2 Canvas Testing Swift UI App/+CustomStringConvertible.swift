//
//  +CustomStringConvertible.swift
//  GrippableView
//
//  Created by Justin Smith  on 12/26/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation


extension AreaOfInterestAction : CustomStringConvertible {
  public var description: String {
    switch self {
    case .scroll(let a): return ".scroll(\(a))"
    }
  }
}


extension CenteredGrowAction : CustomStringConvertible {
  public var description: String {
    switch self {
    case .grow(let a): return ".grow(\(a))"
    }
  }
}

extension GrowAction : CustomStringConvertible {
  public var description: String {
    switch self {
    case .onDecelerate(scrollState: let rst): return "onDecelerate(\(rst))"
    case .onZoomBegin(let scrollState, let pinchLocations):
      return "onZoomBegin(\(scrollState), \(pinchLocations.0.rounded(places: 2)), \(pinchLocations.1.rounded(places: 2)))"
    case .onZoom(let scrollState, let pinchLocations):
       return "onZoom(\(scrollState), \(pinchLocations.0.rounded(places: 2)), \(pinchLocations.1.rounded(places: 2)))"
    case .onZoomEnd(let scrollState):
       return "onZoomEnd(\(scrollState))"
    case .onDragBegin(let scrollState):
       return "onDragBegin(\(scrollState))"
    case .onDrag(let scrollState):
       return "onDrag(\(scrollState))"
    case .onDragEnd(let scrollState, let willDecelerate):
       return "onDragEnd(\(scrollState), willDecelerate:\(willDecelerate)"
    case .onDecelerateEnd(let scrollState):
       return "onDecelerateEnd(\(scrollState))"
    }
  }
}


/*
extension ReadScrollState : CustomStringConvertible {
public var description: String {
  let seperator = ",\n"
  return
    "\n" +
      "aoi:\(self.areaOfInterest.rounded(places: 2))" + seperator +
      "cSize:\(self.contentSize.rounded(places: 2))" + seperator +
      "cOffset:\(self.contentOffset.rounded(places: 2))" + seperator +
      "rFrame:\(self.rootContentFrame.rounded(places: 2))" + seperator +
  "zoomS:\(self.zoomScale.rounded(places: 2))"
  
  }
  
}
 */
