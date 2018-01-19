//
//  MarginLayout.swift
//  Control
//
//  Created by Justin Smith on 9/19/16.
//  Copyright © 2016 Justin Smith. All rights reserved.
//

import CoreGraphics



public struct MarginLayout<Child: Layout> : Layout {
    var content : Child
    var margin : CGFloat
    
    
    public var contents: [Child.Content] { return content.contents }
    public typealias Content = Child.Content
    
    public mutating func layout(in rect:CGRect)
    {
        let rect2 = rect.insetBy(dx: margin, dy: margin)
        content.layout(in: rect2)
    }
}

