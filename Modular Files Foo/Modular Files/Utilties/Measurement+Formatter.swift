//
//  Measurement+Formatter.swift
//  Deploy
//
//  Created by Justin Smith on 11/20/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation


typealias Length = Measurement<UnitLength>

func feet(_ len: Length) -> (Int, Length) {
  let feetLen = len.converted(to: .feet)
  let roundedDown = feetLen.value.rounded(.down)
  return  (Int( roundedDown ), Length(value: feetLen.value - roundedDown, unit: .feet))
}

func inches(_ len: Length) -> (Int, Length) {
  let inchLen = len.converted(to: .inches)
  let roundedDown = inchLen.value.rounded(.down)
  return  (Int( roundedDown ), Length(value: inchLen.value - roundedDown, unit: .inches))
}

func inchesFraction(_ len: Length) -> ((Int, Int), Length) {
  let base = 8.0
  let inchLen = len.converted(to: .inches)
  let rounded = (inchLen.value*base).rounded()
  return  ( (Int( rounded ), Int( base )) , Length(value: inchLen.value - rounded/base, unit: .inches))
}

func gcd(_ a:Int, _ b:Int) -> Int {
  func mod(_ a: Int, _ b: Int) -> Int {
    return a - b * abs( a/b )
  }
  if b == 0 { return a }
  else {
    return gcd(b, mod(a, b) )
  }
}

func simplify( numerator:Int, denominator:Int)  -> (Int, Int)? {
  if numerator == 0 { return nil }
  else {
    let divsor = gcd(numerator, denominator)
    return (numerator/divsor, denominator/divsor)
  }
}

// CGFloat -> Measurement
func centimeters(from cent: CGFloat)->Measurement<UnitLength> {
  return Measurement(value: Double(cent), unit: .centimeters)
}

let imperialFormatter : (Measurement<UnitLength>) -> String = {
  let ft = feet($0)
  let i = inches(ft.1)
  let fr = inchesFraction(i.1)
  let sim = simplify(numerator: fr.0.0, denominator: fr.0.1)
  // if simplifies to 1 over 1 aka 1, return inches + 1
  if let (num, den) = sim, num == 1 && den == 1 {
    if i.0 + 1 == 12 {
      return "\(ft.0 + 1)'"
    }
    return "\(ft.0)'-\(i.0 + 1)\""
  }
  let simS = sim.map { return " \($0.0)/\($0.1)" }
  return "\(ft.0)'-\(i.0)\(simS ?? "")\""
}

let metricFormatter : (Measurement<UnitLength>) -> String = {
  let meters = $0.converted(to: .meters)
  return "\( String(format: "%.2f", meters.value) ) m"
}

import Singalong
public let archFormat = centimeters >>> imperialFormatter
public let meterFormat = centimeters >>> metricFormatter
