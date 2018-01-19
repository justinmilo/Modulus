//
//  BackgroundLayout.swift
//  Control
//
//  Created by Justin Smith on 9/19/16.
//  Copyright © 2016 Justin Smith. All rights reserved.
//

import CoreGraphics


public struct BackgroundLayout<Child1, Child2> : Layout where Child1.Content == Child2.Content, Child1: Layout, Child2 : Layout {
    
    
    public var contents: [Child1.Content] { return  background.contents + foreground.contents}
    public typealias Content = Child1.Content
    
    
    var background : Child1
    var foreground : Child2
    
    public mutating func layout(in rect:CGRect)
    {
        background.layout(in: rect)
        foreground.layout(in: rect)
    }
}




