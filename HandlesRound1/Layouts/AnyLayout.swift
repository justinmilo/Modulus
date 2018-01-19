//
//  AnyLayout.swift
//  Deploy
//
//  Created by Justin Smith on 1/18/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import CoreGraphics

struct AnyLayout <B> : Layout {
  let contents: [B]
  typealias Content = B
  mutating func layout(in rect: CGRect) {
    layoutCall(rect)
  }
  var layoutCall : (CGRect) -> ()
  init<Base: Layout>(_ base: Base) where Base.Content == B  {
    self.contents = base.contents
    var mutBase = base
    layoutCall = { rect in mutBase.layout(in: rect) }
  }
}


extension Layout {
  var asAny : AnyLayout<Self.Content> { return AnyLayout(self) }
}

