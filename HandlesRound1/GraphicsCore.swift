//
//  GraphicsCore.swift
//  HandlesRound1
//
//  Created by Justin Smith on 4/14/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics


func uiToSprite(height: CGFloat, rect: CGRect) -> CGRect
{
  return CGRect(x:rect.x ,
                y: height - rect.y,
                width: rect.width,
                height: -rect.height).standardized
}
func uiToSprite(height: CGFloat, y: CGFloat ) -> CGFloat
{
  return height - y
}
func uiToSprite(height: CGFloat, point: CGPoint) -> CGPoint {
  return CGPoint(x: point.x, y: height - point.y )
}

func mirrorVertically(point: CGPoint, along y: CGFloat) -> CGPoint {
  let delta = y - point.y
  let newOriginY = y + delta
  return CGPoint(x: point.x, y: newOriginY)
}
func mirrorVertically(rect: CGRect, along y: CGFloat) -> CGRect {
  let delta = y - rect.origin.y
  let newOriginY = y + delta
  let newRect = CGRect(x: rect.x, y: newOriginY, width: rect.width, height: -rect.height)
  return newRect.standardized
}
func mirrorOrtho(from mirrorPos: CGPoint) -> (CGPoint) -> CGPoint
{
  return {
    return CGPoint( x: mirrorPos.x - ($0.x - mirrorPos.x),
                    y: mirrorPos.y - ($0.y - mirrorPos.y)
    )
  }
}
