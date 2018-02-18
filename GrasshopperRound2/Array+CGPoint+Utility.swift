//
//  Array+CGPoint+Utility.swift
//  HandlesRound1
//
//  Created by Justin Smith on 2/7/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics




func segments<T>(array:[CGPoint], transform: (CGPoint, CGPoint) -> T) -> [T]
{
  return zip(array, array.dropFirst()).map
    {
      return transform($0.0, $0.1)
  }
}

let lineCreate = { segments(array: $0, transform: Line.init) }
let texturedLinesCreate = { segments(array: $0, transform: TextureLine.init) }

extension Array where Element == CGPoint
{
  var texturedLines : [TextureLine]
  {
    return segments(connectedBy: TextureLine.init)
  }
  
  func segments<T>(connectedBy transform: (CGPoint, CGPoint) -> T) -> [T]
  {
    return zip(self, self.dropFirst()).map
      {
        return transform($0.0, $0.1)
    }
  }
}

func segments(_ array: [CGPoint]) -> [(CGPoint, CGPoint)]
{
  return Array( zip(array, array.dropFirst()) )
}

