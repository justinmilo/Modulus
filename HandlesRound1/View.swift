//
//  View.swift
//  HandlesRound1
//
//  Created by Justin Smith on 2/7/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation




struct View<D, N: Monoid> {
  let view: (D) -> N
  
  init(_ view: @escaping (D) -> N) {
    self.view = view
  }
}


