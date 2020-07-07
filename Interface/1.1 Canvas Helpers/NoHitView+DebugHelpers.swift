//
//  DebugScrollView.swift
//  ScrollViewGrower
//
//  Created by Justin Smith on 5/3/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit
import Singalong
import Geo

 class NoHitView : UIView {
   override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let view = super.hitTest(point, with: event)
    return view == self ? nil : view
  }
}

func format(size: CGSize) -> String
{
  return "width:\(size.width.format(f:".2") |> trimZeros), height:\(size.height.format(f:".2") |> trimZeros)"
}


func format(point: CGPoint) -> String
{
  return "x:\(point.x.format(f:".2") |> trimZeros), y:\(point.y.format(f:".2") |> trimZeros)"
}


func format(vec: CGVector) -> String
{
  return "dx:\(vec.dx.format(f:".2") |> trimZeros), dy:\(vec.dy.format(f:".2") |> trimZeros)"
}

func format(rect: CGRect) -> String
{
  return rect.origin |> format + ", " +  rect.size |> format
}



func trimZeros( str: String) -> String
{
  var str = str
  if str.last == "0"
  {
     str.removeLast()
    return str |> trimZeros
  }
  else {
    return str
  }
}

