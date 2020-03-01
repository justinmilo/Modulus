//
//  Item.swift
//  Deploy
//
//  Created by Justin Smith on 11/20/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation
import GrapheNaked
import Singalong



struct ScaffoldingGridSizes : Codable { let label: String; let length: Length }
extension ScaffoldingGridSizes {
  var centimeters : CGFloat {  get  {  return CGFloat(length.converted(to: .centimeters).value)}  }
}

extension ScaffoldingGridSizes : Hashable {
  var hashValue : Int { return label.hashValue }
//  func hash(into hasher: inout Hasher) {
//    hasher.combine(label.hashValue)
//  }
}

extension ScaffoldingGridSizes {
  static let _50 = ScaffoldingGridSizes(label: "50cm", length: Length(value: 50.0, unit: .centimeters))
  static let _100 = ScaffoldingGridSizes(label: "100cm", length: Length(value:  100, unit: .centimeters))
  static let _150 = ScaffoldingGridSizes(label: "150cm", length: Length(value:  150, unit: .centimeters))
  static let _200 = ScaffoldingGridSizes(label: "200cm", length: Length(value:  200, unit: .centimeters))
  static let _250 = ScaffoldingGridSizes(label: "250cm", length: Length(value:  250, unit: .centimeters))
  static let _300 = ScaffoldingGridSizes(label: "300cm", length: Length(value:  300, unit: .centimeters))
  static let f1 = ScaffoldingGridSizes(label: "1ft", length: Length(value: 1, unit: .feet))
  static let f2 = ScaffoldingGridSizes(label: "2ft", length: Length(value: 2, unit: .feet))
  static let f3 = ScaffoldingGridSizes(label: "3ft", length: Length(value: 3, unit: .feet))
  static let f4 = ScaffoldingGridSizes(label: "4ft", length: Length(value: 4, unit: .feet))
  static let f5 = ScaffoldingGridSizes(label: "5ft", length: Length(value: 5, unit: .feet))
  static let f6 = ScaffoldingGridSizes(label: "6ft", length: Length(value: 6, unit: .feet))
  static let f7 = ScaffoldingGridSizes(label: "7ft", length: Length(value: 7, unit: .feet))
  static let f8 = ScaffoldingGridSizes(label: "8ft", length: Length(value: 8, unit: .feet))
  static let f9 = ScaffoldingGridSizes(label: "9ft", length: Length(value: 9, unit: .feet))
  static let f10 = ScaffoldingGridSizes(label: "10ft", length: Length(value: 10, unit: .feet))

  static let all : [ScaffoldingGridSizes] = ScaffoldingGridSizes.eventMetric + ScaffoldingGridSizes.us
  static let eventMetric : [ScaffoldingGridSizes] = [
    _50,
    _100,
    _150,
    _200,
    _250,
    _300]
  static let us : [ScaffoldingGridSizes] = [
    f1 ,
    f2 ,
    f3 ,
    f4 ,
    f5 ,
    f6 ,
    f7 ,
    f8 ,
    f9 ,
    f10,
    ]
  static let mock : [ScaffoldingGridSizes] = [
    _50, _100, _150, _200
  ]
}

struct Item<Content:Equatable> : Equatable {
  typealias ID = String
  
  let content: Content
  let id: String
  var name: String
  var sizePreferences: Set<ScaffoldingGridSizes> = []
  var isEnabled: Bool = true
  var thumbnailFileName : String?
  
}

extension Set where Element == ScaffoldingGridSizes {
  var mostlyMetric : Bool {
    let metricItems = self.filter({ (size) -> Bool in
      return ScaffoldingGridSizes.eventMetric.contains(size)
    })
    let impItems = self.filter({ (size) -> Bool in
      return ScaffoldingGridSizes.us.contains(size)
    })
    return metricItems.count >= impItems.count
  }
  var toCentimeterFloats : [CGFloat] {
    self.map{CGFloat($0.length.converted(to: .centimeters).value)}
  }
}



extension Item where Content : ScaffGraph {
  static var template : [ScaffoldingGridSizes] {  get { return [ScaffoldingGridSizes._50, ScaffoldingGridSizes._150] } }
}

extension Item {
  init(content: Content, id: String, name: String) {
    self.init(content: content, id: id, name: name, sizePreferences: Set(ScaffoldingGridSizes.mock), isEnabled: true, thumbnailFileName: nil)
  }
}

extension Set where Element == ScaffoldingGridSizes {
  var text : String {
    let values = self.map{$0.length.value}.sorted().map{String($0)}
    return values.dropFirst().reduce(values.first ?? "None") {
      return $0 + ", " + $1
    }
  }
}

extension Item : Codable where Content : Codable { }





typealias ScaffItem = Item<ScaffGraph>

