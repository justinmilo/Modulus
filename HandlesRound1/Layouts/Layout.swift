import CoreGraphics


public protocol Layout {
    mutating func layout(in rect:CGRect)
    /// The type of the leaf content elements in this layout.
    associatedtype Content
    
    /// Return all of the leaf content elements contained in this layout and its descendants.
    var contents: [Content] { get }
}

