import CoreGraphics

public struct LayoutLogger <Child:Layout> : Layout {
    var child : Child
    mutating public func layout(in rect:CGRect) {
        print("——————————————————————————")
        print("Child: \(Child.self)")
        print("Content: \(Content.self)")
        print("to Layout(in: \(rect)")
        print("——————————————————————————\n")
        child.layout(in: rect)
    }
    /// The type of the leaf content elements in this layout.
    public typealias  Content = Child.Content
    
    /// Return all of the leaf content elements contained in this layout and its descendants.
    public var contents: [Content] { return child.contents }
}

extension Layout {
    public func log() -> LayoutLogger<Self> {
        return LayoutLogger(child: self)
    }
}



