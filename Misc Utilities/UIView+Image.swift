//
//  UIView+Image.swift
//  Modular
//
//  Created by Justin Smith on 12/21/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit

func image(with view: UIView) -> UIImage? {
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
  defer { UIGraphicsEndImageContext() }
  // Captures SpriteKit content!
  
  view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
  let image = UIGraphicsGetImageFromCurrentImageContext()
  return image
}

func cropToBounds(image: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
  
  let cgimage = image.cgImage!
  let contextImage: UIImage = UIImage(cgImage: cgimage)
  let contextSize: CGSize = contextImage.size
  var posX: CGFloat = 0.0
  var posY: CGFloat = 0.0
  var cgwidth: CGFloat = width
  var cgheight: CGFloat = height
  
  // See what size is longer and create the center off of that
  if contextSize.width > contextSize.height {
    posX = ((contextSize.width - contextSize.height) / 2)
    posY = 0
    cgwidth = contextSize.height
    cgheight = contextSize.height
  } else {
    posX = 0
    posY = ((contextSize.height - contextSize.width) / 2)
    cgwidth = contextSize.width
    cgheight = contextSize.width
  }
  
  let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
  
  // Create bitmap image from context using the rect
  let imageRef: CGImage = cgimage.cropping(to: rect)!
  
  // Create a new image based on the imageRef and rotate back to the original orientation
  let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
  
  return image
}
