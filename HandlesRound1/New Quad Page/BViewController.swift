//
//  ViewController.swift
//

import UIKit
import Geo

protocol InnerDelegate : class {
  func didStartScroll()
  func didEndScroll()
  func didStartDrag()
  func didEndDrag()
  func dragDelta(offset :CGFloat)
}

class BViewController: UIViewController {
  
  var color: UIColor?
  var drawer : UIView!
  var scroll : UIScrollView!
  weak var delegate : InnerDelegate?
  
  init(color: UIColor?) {
    super.init(nibName: nil, bundle: nil)
    self.color = color
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    self.view = UIView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = color
    
    let size = CGSize(500, 1200)
    let overlay = GridView(frame: size.asRect())
    
    self.scroll = UIScrollView(frame: self.view.frame)
    scroll.addSubview(overlay)
    scroll.contentSize = size
    scroll.contentInsetAdjustmentBehavior = .never
    scroll.delegate = self
    view.addSubview( scroll )
    
    self.drawer = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    
    view.addSubview(drawer)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    self.scroll.frame = self.view.frame.size.asRect()
    
    let drawerSize = CGSize(view.frame.width, 88.0)
    let frame = CGRect(origin: view.bounds.bottomLeft + unitY * -drawerSize.height, size: drawerSize)
    drawer.frame = frame
  }

  enum State {
    case scrolling(dragging: Bool)
    case inert
  }
  var state : State  = .inert
}

extension BViewController : UIScrollViewDelegate{
  public func scrollViewDidScroll(_ scrollView: UIScrollView){
    
    let previousState = state
    let isDragging : Bool = outOfBounds(scrollView: scrollView) ?  true : false
    self.state = .scrolling(dragging: isDragging)
    
    if case .inert = previousState {
      self.delegate?.didStartScroll()
      
      if isDragging {
        self.delegate?.didStartDrag()
      }
    }
    
    
    
    
    
    if case let .scrolling(dragging: wasDragging) = previousState {
      switch (wasDragging, isDragging){
      case (true, true), (false, false): break
      case (true, false): self.delegate?.didEndDrag()
      case (false, true): self.delegate?.didStartDrag()
      }
      
      
    }
    
    if isDragging {
      let offset = offsetBy(scrollView: scrollView)!
      //scrollView.contentOffset.x = scrollView.contentOffset.x +
      scrollView.transform = CGAffineTransform(translationX: offset, y: 0)
      self.delegate?.dragDelta(offset: offset)
    }
   
  }
  

  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      self.delegate?.didEndScroll()
      self.state = .inert
    }
  }
  
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
   
    self.delegate?.didEndScroll()
    self.state = .inert
  }
  
}

func outOfBounds(scrollView: UIScrollView) -> Bool {
  if scrollView.contentOffset.x < 0.0 {
    return true
  }
  else if (scrollView.contentOffset.x - (scrollView.contentSize.width - scrollView.frame.width)) > 0.0 {
    return true
  }
  return false
}

func offsetBy(scrollView: UIScrollView) -> CGFloat? {
  if scrollView.contentOffset.x < 0.0 {
    return scrollView.contentOffset.x
  }
  else if (scrollView.contentOffset.x - (scrollView.contentSize.width - scrollView.frame.width)) > 0.0 {
    return scrollView.contentOffset.x - (scrollView.contentSize.width - scrollView.frame.width)
  }
  return nil
}
