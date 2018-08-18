//
//  ScrollableViewController.swift
//

import UIKit

class ScrollableViewController: UIViewController, UIScrollViewDelegate {
  
  private let scrollView = UIScrollView()
  private var controllers: Array<BViewController> = [
                  BViewController(color: .red),
    BViewController(color:.red),
    BViewController(color:.blue),
    BViewController(color:.red),
    BViewController(color:.red),
    BViewController(color:.blue)]
  
  private var isDragging = false
  
  override func loadView() {
    scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.delegate = self
    scrollView.backgroundColor = UIColor.white
    scrollView.showsHorizontalScrollIndicator = true
    scrollView.decelerationRate = UIScrollView.DecelerationRate.fast
    self.view = scrollView
  
    controllers[0].delegate = self

    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Scroll", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ScrollableViewController.didTapBarButton))
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let width: CGFloat = CGFloat(controllers.count) * self.view.bounds.size.width
    scrollView.contentSize = CGSize(width, self.view.bounds.size.height)
    layoutViewController(fromIndex: 0, toIndex: 0)
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let fromIndex = floor(scrollView.bounds.origin.x  / scrollView.bounds.size.width)
    let toIndex = floor(((scrollView.bounds.maxX) - 1) / scrollView.bounds.size.width)
    
    layoutViewController(fromIndex: Int(fromIndex), toIndex: Int(toIndex))
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    isDragging = true
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let offset = round(targetContentOffset.pointee.x / self.view.bounds.size.width) * self.view.bounds.size.width
    targetContentOffset.pointee.x = offset
    isDragging = false
  }
  
  
  @objc func didTapBarButton() {
    // Scroll mid-view
    scrollView.setContentOffset(CGPoint(2.5 * self.view.bounds.size.width, 0), animated: true)
  }
  
  
  private func layoutViewController(fromIndex: Int, toIndex: Int) {
    //print("layout from \(fromIndex) to \(toIndex)")
    
    for i in (0..<controllers.count) {
      // Remove views that should not be visible anymore
      if (controllers[i].view.superview != nil && (i < fromIndex || i > toIndex)) {
        print(NSString(format: "Hiding view controller at index: %i", i))
        controllers[i].willMove(toParent: nil)
        controllers[i].view.removeFromSuperview()
        controllers[i].removeFromParent()
      }
      
      // Add views that are now visible
      if (controllers[i].view.superview == nil && (i >= fromIndex && i <= toIndex)) {
        print(NSString(format: "Showing view controller at index: %i", i))
        var viewFrame = self.view.bounds
        viewFrame.origin.x = CGFloat(i) * self.view.bounds.size.width
        controllers[i].view.frame = viewFrame
        self.addChild(controllers[i])
        scrollView.addSubview(controllers[i].view)
        controllers[i].didMove(toParent: self)
      }
    }
  }
}

extension ScrollableViewController : InnerDelegate {
  func didStartScroll() {
    print("scrolling disabled")
    self.scrollView.isScrollEnabled = false

  }
  func didEndScroll() {
    print("scrolling enabled")

    self.scrollView.isScrollEnabled = true
  }
  
  func didStartDrag(){
    print("did Start Drag")
    print("scrolling disabled")

    self.scrollView.isScrollEnabled = false
    
  }
  func didEndDrag(){
    self.scrollView.isScrollEnabled = true

    print("didEnd Drag")
    print("scrolling enabled")

  }
  func dragDelta(offset :CGFloat){
    self.scrollView.contentOffset.x = offset
  }
}
