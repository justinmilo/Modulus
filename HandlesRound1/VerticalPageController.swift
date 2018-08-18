//
//  ViewController.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/14/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit


 




extension Array {
  func previous(index: Index) -> Index? {
    return index == startIndex
    ?  nil
    : index - 1
  }
  func next(index: Index) -> Index? {
    return index == endIndex - 1
      ?  nil
      : index + 1
  }
  func previousElement(at index: Index) -> Element? {
    guard let prevI = self.previous(index: index) else { return nil}
    return self[prevI]
  }

  func nextElement(at index: Index) -> Element? {
    guard let nextI = self.next(index: index) else { return nil}
    return self[nextI]
  }
}


















