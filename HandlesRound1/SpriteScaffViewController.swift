//
//  TestViewController.swift
//  HandlesRound1
//
//  Created by Justin Smith on 1/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit








import SpriteKit


func zurry<B>(_ g: ()->B ) -> B
{
  return g()
}
func flip<A, C>(_ f: @escaping (A) -> () -> C) -> () -> (A) -> C {
  return { { a in f(a)() } }
}

let negatedVector = zurry(flip(CGPoint.asVector)) >>> zurry(flip(CGVector.negated))





class SpriteScaffViewController : UIViewController {
  // View and Model
  var handleView : HandleViewRound1!
  var rootView : UIView!
  var scrollView : UIScrollView!
  
  let graph : ScaffGraph
  
  // Drawing pure function
  var editingView : GraphEditingView
  var loadedViews : [GraphEditingView]
  
  // Eventually dependency injected
  var initialFrame : CGRect
  
  init(graph: ScaffGraph, mapping: [GraphEditingView] )
  {
    self.graph = graph
    
    editingView = mapping[0]
    loadedViews = mapping
    
    initialFrame = UIScreen.main.bounds
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  override func viewDidAppear(_ animated: Bool) {
    // Set view upon initial loading
    buildFromScratch()
  }
  
  func buildFromScratch()
  {
    //let size = self.graph |> self.editingView.size
    //let newRect = self.view.bounds.withInsetRect(ofSize: size, hugging: (.center, .center))
    //self.handleView.set(master: newRect)
    
    let size = self.graph |> self.editingView.size
    let newRect = self.handleView.bounds.withInsetRect(ofSize: size, hugging: (.center, .center))
    self.handleView.set(master: newRect)
  }
  
  var b: NSKeyValueObservation!
  
  override func loadView() {
    let originZeroFrame = CGPoint.zero + CGSize(width:372, height:500)
    
    handleView = HandleViewRound1(frame: originZeroFrame, outerBounds: originZeroFrame.insetBy(dx: 30, dy: 30), master: originZeroFrame.insetBy(dx: 60, dy: 60))
    handleView.layer.borderColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1).cgColor
    handleView.layer.borderWidth = 1.0
    

    rootView = UIView(frame: originZeroFrame)
    rootView.layer.borderColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor
    rootView.layer.borderWidth = 1.0
   
    [handleView].forEach{ v in rootView.addSubview(v) }
    
    scrollView = UIScrollView(frame: initialFrame)
    scrollView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    scrollView.layer.borderColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1).cgColor
    scrollView.layer.borderWidth = 1.0
    scrollView.addSubview(rootView)
    scrollView.contentSize = rootView.bounds.size
    scrollView.showsVerticalScrollIndicator = true
    scrollView.showsHorizontalScrollIndicator = true
    
    view = UIView(frame: initialFrame)
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SpriteScaffViewController.tap)))
    view.addSubview ( scrollView )
    
//    b = view.observe(\UIView.safeAreaInsets, options: NSKeyValueObservingOptions.new) { (a, b) in
//      print("From the observe!", self.view.safeAreaInsets)
//      self.scrollView.contentInset.bottom = b.newValue!.bottom + 4
//      //self.scrollView.contentSize = self.rootView.bounds.size.applying(edgeInsets: b.newValue!)
//    }
    
    self.handleView.handler =    {
      master, positions in
      // Create more space for everyone if it's getting tighter
//      let delta = self.handleView.frame.size - master.size
//      let limit : CGFloat = 100.0
//      if delta.width < limit
//      {
//        //self.handleView.frame.x += -limit
//        self.handleView.frame.width += limit * 2
//        self.handleView.outerBounds = self.handleView.frame.insetBy(dx: 20, dy: 20)
//        
//        self.scrollView.contentSize = self.handleView.frame.size
//        self.scrollView.contentOffset.x += limit
//        //self.twoDView.frame.width += limit
//        
//        self.rootView.frame.x += -limit
//        self.rootView.frame.width += limit * 2
//      }
      
      
       // Create New Model &  // Find Orirgin
      (self.graph.grid, self.graph.edges) = (master.size, self.graph.edges) |> self.editingView.build
      let size = self.graph |> self.editingView.size
      let newRect = (master, size, positions) |> centeredRect
      
    }
    
    self.handleView.completed = {
      master, positions in
      // Create New Model
      (self.graph.grid, self.graph.edges) = (master.size, self.graph.edges) |> self.editingView.build
      let size = self.graph |> self.editingView.size
      let  newRect = (master, size, positions) |> centeredRect
      
      self.handleView.set(master: newRect )
    }
    
  }
  
  @objc func tap(g: UIGestureRecognizer)
  {
    // if insideTGyg`1``1`q`1q`q1
    if self.handleView.lastMaster.contains(
      g.location(ofTouch: 0, in: self.view)
    ) {
    }
    else {
      changeCompositeStyle()
    }
  }
  
  private var swapIndex = 0
  func changeCompositeStyle ()
  {
    swapIndex = swapIndex+1 >= loadedViews.count ? 0 : swapIndex+1
    self.editingView = loadedViews[swapIndex]
    buildFromScratch()
  }
  
  private var swapIndex2 = 0
  
}

typealias PointIndex2D = (x:Int, y:Int)

