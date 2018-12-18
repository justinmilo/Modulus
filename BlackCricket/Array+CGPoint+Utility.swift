//
//  Array+CGPoint+Utility.swift
//  HandlesRound1
//
//  Created by Justin Smith on 2/7/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics




public func edges(in rect: CGRect) -> [CGPoint]
{
  return  [rect.topCenter,
           rect.centerRight,
           rect.bottomCenter,
           rect.centerLeft]
}


// return edges from top left clockwise
func corners(of rect: CGRect)-> [CGPoint]
{
  return [rect.topLeft, rect.topRight, rect.bottomRight, rect.bottomLeft]
}
// return edges from top center clockwise
func edgeCenters(of rect: CGRect)->[CGPoint]
{
  return [rect.topCenter, rect.centerRight, rect.bottomCenter, rect.centerLeft]
}


func segments<T>(array:[CGPoint], transform: (CGPoint, CGPoint) -> T) -> [T]
{
  return zip(array, array.dropFirst()).map
    {
      return transform($0.0, $0.1)
  }
}

let lineCreate = { segments(array: $0, transform: Line.init) }

extension Array where Element == CGPoint
{
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

