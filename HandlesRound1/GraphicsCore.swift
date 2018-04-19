//
//  GraphicsCore.swift
//  HandlesRound1
//
//  Created by Justin Smith on 4/14/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics


//struct Email: Decodable, RawRepresentable { let rawValue: String }
// {"email": String}
enum SKTag {}
typealias SKRect = Tagged<SKTag, CGRect>
typealias SKPoint = Tagged<SKTag, CGPoint>

extension Tagged where RawValue == CGPoint {
  init (x: CGFloat, y:CGFloat) { self.init(rawValue: CGPoint.init(x:x,y:y)) }
  init (_ x: CGFloat, _ y:CGFloat) { self.init(rawValue: CGPoint.init(x:x,y:y)) }
}

// Func translate between two sibling coordiante systems
// point lives in _UISibling_
func translate(from uisibling: CGRect, to sksibling: CGRect) -> (CGPoint) -> SKPoint
{
  let xDelta = uisibling.origin.x - sksibling.origin.x
  let yDelta = uisibling.origin.y - sksibling.origin.y
  
  return { sibPoint in
    SKPoint( x: sibPoint.x + xDelta, y: sksibling.size.height - (sibPoint.y + yDelta))
  }
}

func translateToCGPointInSKCoordinates(from uisibling: CGRect, to sksibling: CGRect) -> (CGPoint) -> CGPoint
{
  let xDelta = uisibling.origin.x - sksibling.origin.x
  let yDelta = uisibling.origin.y - sksibling.origin.y
  
  return { sibPoint in
    CGPoint( x: sibPoint.x + xDelta, y: sksibling.size.height - (sibPoint.y + yDelta))
  }
}


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
