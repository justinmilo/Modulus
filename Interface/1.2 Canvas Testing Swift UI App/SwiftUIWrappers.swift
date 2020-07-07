//
//  SwiftUIWrappers.swift
//  CanvasTester
//
//  Created by Justin Smith  on 12/26/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation
@testable import GrippableView
import SwiftUI




struct GrowCenteredUI : UIViewControllerRepresentable {
  typealias UIViewControllerType = GrowCenteredVC

  /// Creates a `UIViewController` instance to be presented.
  func makeUIViewController(context: Context) -> GrowCenteredVC {
    GrowCenteredVC()
  }

  /// Updates the presented `UIViewController` (and coordinator) to the latest
  /// configuration.
  func updateUIViewController(_ uiViewController: GrowCenteredVC, context: Context) {
  }
}


struct ContentScrollUI : UIViewControllerRepresentable {
  typealias UIViewControllerType = ContentScrollVC

  /// Creates a `UIViewController` instance to be presented.
  func makeUIViewController(context: Context) -> ContentScrollVC {
    ContentScrollVC()
  }

  /// Updates the presented `UIViewController` (and coordinator) to the latest
  /// configuration.
  func updateUIViewController(_ uiViewController: ContentScrollVC, context: Context) {
  }
}

struct CanvasSelectionUI : UIViewControllerRepresentable {
  typealias UIViewControllerType = CanvasSelectionVC

  /// Creates a `UIViewController` instance to be presented.
  func makeUIViewController(context: Context) -> CanvasSelectionVC {
    CanvasSelectionVC()
  }

  /// Updates the presented `UIViewController` (and coordinator) to the latest
  /// configuration.
  func updateUIViewController(_ uiViewController: CanvasSelectionVC, context: Context) {
  }
  
}


