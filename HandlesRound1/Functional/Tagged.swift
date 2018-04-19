//
//  Tagged.swift
//  HandlesRound1
//
//  Created by Justin Smith on 4/19/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation

import Foundation


struct Tagged<Tag, RawValue> {
  let rawValue: RawValue
}

extension Tagged: Decodable where RawValue: Decodable {
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.init(rawValue: try container.decode(RawValue.self))
  }
}

extension Tagged: Equatable where RawValue: Equatable {
  static func == (lhs: Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }
  
}

extension Tagged: ExpressibleByIntegerLiteral where RawValue: ExpressibleByIntegerLiteral {
  
  init(integerLiteral value: RawValue.IntegerLiteralType) {
    self.init(rawValue: RawValue(integerLiteral: value))
  }
  
  typealias IntegerLiteralType = RawValue.IntegerLiteralType
  
  
}

extension Tagged : Hashable where RawValue : Hashable
{
  var hashValue: Int {
    return rawValue.hashValue
  }
}

extension Tagged : Numeric where RawValue : Numeric
{

  init?<T>(exactly source: T) where T : BinaryInteger {
    guard let rawValue = RawValue.init(exactly: source) else { return nil}
  
    self.rawValue = rawValue
  }
  
  var magnitude: RawValue.Magnitude {
    return rawValue.magnitude
  }
  
  
  typealias Magnitude = RawValue.Magnitude
  
  static func + (lhs: Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) -> Tagged<Tag, RawValue> {
    return Tagged(rawValue: lhs.rawValue + rhs.rawValue)
  }
  
  static func += (lhs: inout Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) {
    lhs = lhs + rhs
  }
  
  static func - (lhs: Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) -> Tagged<Tag, RawValue> {
    return Tagged(rawValue: lhs.rawValue - rhs.rawValue)
  }
  
  static func -= (lhs: inout Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) {
    lhs = lhs - rhs
  }
  
  
  static func * (lhs: Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) -> Tagged<Tag, RawValue> {
    return Tagged(rawValue: lhs.rawValue * rhs.rawValue)
  }
  
  static func *= (lhs: inout Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) {
    lhs = lhs * rhs
  }
  
}



