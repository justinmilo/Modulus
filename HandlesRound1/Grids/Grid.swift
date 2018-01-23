//
//  SizeGrid.swift
//  Control
//
//  Created by Justin Smith on 2/12/17.
//  Copyright © 2017 Justin Smith. All rights reserved.
//

import CoreGraphics


protocol GridBySizes {
  var sizes : [CGFloat] { get }
}

struct Grid : GridBySizes {
  var sizes : [CGFloat] // Extents?
}


extension GridBySizes {
  var positions : [CGFloat] {
    return sizes.reduce([0.0]) {
      (combined, value) -> [CGFloat] in
      return combined + [combined.last! + value]
    }
  }
  
  var positionsAndSizes : [(position: CGFloat, size: CGFloat)]
  {
    let sizesAndPositions = zip(positions, sizes)
    let final =  sizesAndPositions.map{ a -> (position: CGFloat, size: CGFloat) in
      let (v1, v2) = a
      return (position: v1, size:v2)
    }
    return final
  }
  var sum : CGFloat {
    return sizes.reduce(0.0) {
      (combined, value) -> CGFloat in
      return combined + value
    }
  }
  
}



extension Grid
{
  func union(with other: Grid) -> Grid
  {
    let (_, _) = self.sum >= other.sum ? (self, other) : (other, self)
    
    let pos1 = self.positions
    let pos2 = other.positions
    
    
    var combined = pos1
    
    for toAdd in pos2
    {
      if !combined.contains(toAdd) {
        combined.append(toAdd)
      }
    }
    
    let sorted = combined.sorted() 
    
    _ = sorted.count - 1
    let newSIzes = sorted.dropLast().enumerated().map{
      (arg) -> CGFloat in
      
      
      let (index, value) = arg
      return sorted[index+1] - value
      
    }
    
    return Grid(newSIzes)
  }
}

extension Grid : Equatable{
  static func ==(lhs: Grid, rhs: Grid) -> Bool
  {
    return lhs.sizes == rhs.sizes
  }

}

extension Grid : ExpressibleByArrayLiteral{
  typealias Element = CGFloat
  init(arrayLiteral elements: Grid.Element...)
  {
    sizes = elements
  }
}

extension Grid {
  init(_ elements: [Grid.Element])
  {
    sizes = elements
  }
}

extension Grid : Sequence
{
  typealias Iterator = Array<Element>.Iterator
  func makeIterator() -> Grid.Iterator {
    return self.sizes.makeIterator()
  }
}

extension Grid : Collection
{
  typealias Index = Int
  var startIndex: Int {
    return 0
  }
  func index(after i: Grid.Index) -> Grid.Index {
    return i + 1
  }
  
  var endIndex: Int {
    return self.sizes.count
  }
  
  subscript(i: Int) -> Element {
      get {
        return self.sizes[i]
      }
      set {
        self.sizes[i] = newValue
      }
  }
}

extension Grid
{
 mutating func insert(_ newElement: Grid.Element, at i: Int)
  {
    self.sizes.insert(newElement, at: i)
  }
}

extension Grid /// misc
{
  mutating func append(_ newElement: Grid.Element)
  {
    self.sizes.append(newElement)
  }
  
  @discardableResult mutating func removeLast() -> Grid.Element
  {
    return self.sizes.removeLast()
  }
}
