import Foundation

public enum VerticalPosition {
    case top
    case center
    case bottom
}

extension VerticalPosition {
    var oposite : VerticalPosition { // FIXME Spelling
        switch self {
        case .top : return .bottom
        case .bottom : return .top
        case .center : return .center
        }
    }
}

public enum HorizontalPosition {
    case left
    case center
    case right
    
    var oposite : HorizontalPosition {
        switch self {
        case .left : return .right
        case .right : return .left
        case .center : return .center
        }
    }
}

public struct DualPosition {
    public var horizontal : HorizontalPosition
    public var vertical : VerticalPosition
  
  var oposite : DualPosition {
    return DualPosition(horizontal.oposite, vertical.oposite)
  }
}

public extension DualPosition {
    init(_ h : HorizontalPosition,
         _ v : VerticalPosition)
    {
        self.init(horizontal: h, vertical:v )
    }
}

typealias Position2D = (VerticalPosition,HorizontalPosition)

let opposite : (Position2D) -> Position2D = { ($0.0.oposite ,$0.1.oposite) }

let clockwise : (Position2D) -> Position2D =
{
  switch $0
  {
  
  case (.center, .center): return (.center, .center)
  
  case (.bottom, .right): return (.bottom, .center)
  case (.bottom, .center): return (.bottom, .left)
  case (.bottom, .left): return (.center, .left)
  case (.center, .left): return (.top, .left)
  case (.top, .left): return (.top, .center)
  case (.top, .center): return (.top, .right)
  case (.top, .right): return (.center, .right)
  case (.center, .right): return (.bottom, .right)

}
}

let counterClockwise : (Position2D) -> Position2D =
{
  switch $0
  {
    
  case (.center, .center): return (.center, .center)
    
  case (.bottom, .right):  return (.center, .right)
  case  (.center, .right): return (.top, .right)
  case (.top, .right): return (.top, .center)
  case (.top, .center): return (.top, .left)
  case (.top, .left): return (.center, .left)
  case (.center, .left) : return (.bottom, .left)
  case (.bottom, .left) : return (.bottom, .center)
  case (.bottom, .center) : return (.bottom, .right)
    
  }
}


import CoreGraphics
let positionsToPoint : (Position2D, CGRect) -> CGPoint =
{
  switch $0 {
  case (.top, .center): return $1.topCenter
  case (.top, .left): return $1.topLeft
  case (.top, .right): return $1.topRight
    
  case (.center, .center): return $1.center
  case (.center, .left): return $1.centerLeft
  case (.center, .right): return $1.centerRight
    
  case (.bottom, .center): return $1.bottomCenter
  case (.bottom, .left): return $1.bottomLeft
  case (.bottom, .right): return $1.bottomRight
  }
}
let positionsToPointCurried = curry(positionsToPoint)

