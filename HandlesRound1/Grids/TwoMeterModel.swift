//
//  TwoMeterModel.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/21/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics

func twoMeterModel(
  availableInventory : [CGFloat] = [25, 50, 100, 150, 200],
  targetSize : CGSize
  )
  -> (x:[CGFloat], y:[CGFloat])
{
  
  func maximumRepeated(availableInventory : [CGFloat], targetMaximum: CGFloat) -> [CGFloat]
  {
    let orderedInventory = availableInventory.sorted(by: >)
    let (remaining, standards) : (CGFloat , [CGFloat]) = orderedInventory.reduce((targetMaximum, []))
    {
      (balance :(heightRemain : CGFloat, standards : [CGFloat]), heightToTry) in
    
      guard balance.heightRemain >= heightToTry else { return (balance.heightRemain, balance.standards) }
      
      let times = Int( floor( balance.heightRemain / heightToTry))
      let remaining = balance.heightRemain.truncatingRemainder(dividingBy: heightToTry)
      
      let array = Array<CGFloat>(repeating: heightToTry, count: times)
      
      return (remaining, balance.standards + array)
    }
    return standards
  }
  
  
  return (
    x: maximumRepeated(availableInventory: availableInventory, targetMaximum: targetSize.width),
    y: maximumRepeated(availableInventory: availableInventory, targetMaximum: targetSize.height)
  )
}


func twoMeterModelCounts(x:[CGFloat], y:[CGFloat]) -> (x:Int, y: Int)
{
  let count200s = { (res :Int , flo:CGFloat) -> Int in
    return flo == 200.0 ? res + 1 : res
  }
  return (
    x: x.reduce(0, count200s),
    y: y.reduce(0, count200s)
  )
}

