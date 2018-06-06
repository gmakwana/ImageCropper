//
//  ⚡️Created by Generatus⚡️ on 28.05.2018
// 
//  ImageCropperViewController.swift
//
//  Created by NickKopilovskii
//  Copyright © NickKopilovskii. All rights reserved.
//

import UIKit

public class ImageCropperViewController: UIViewController {
  //MARK: Static initializer
  static public func initialize(with configuration:ImageCropperConfiguration, completionHandler: @escaping ImageCropperCompletion) -> ImageCropperViewController {
//    let bundle = Bundle(for: self.classForCoder()).loadNibNamed("ImageCropper", owner: nil, options: nil)?.first
    let cropper = ImageCropperViewController(nibName: "ImageCropper", bundle: Bundle(for: self.classForCoder()))
    ImageCropperConfiguratorImplementation.configure(for: cropper, with: configuration, completionHandler: completionHandler)
  
    return cropper
  }

  //MARK: Private properties & IBOutlets
  @IBOutlet fileprivate weak var imgCropping: UIImageView!
  @IBOutlet fileprivate weak var mask: UIView!
  @IBOutlet fileprivate weak var grid: UIView!
  @IBOutlet fileprivate weak var btnDone: UIButton!
  @IBOutlet fileprivate weak var btnCancel: UIButton!
  @IBOutlet fileprivate weak var bottomBar: UIView!
  
  var presenter: ImageCropperPresenter?

  
  
  
  //MARK:  Lifecicle
  override public func viewDidLoad() {
    super.viewDidLoad()
    presenter?.viewDidLoad()
  }
  
  override public func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    presenter?.viewDidLayoutSubviews(in: view.bounds)
  }
  
  override public var prefersStatusBarHidden: Bool {
    return true
  }
  
}

//MARK: - Private
//MARK: Actions
extension ImageCropperViewController {
  @IBAction func btnCancelPressed(_ sender: UIButton) {
    presenter?.cancel()
  }
  
  @IBAction func btnDonePressed(_ sender: UIButton) {
    presenter?.crop()
  }
  
  @IBAction func actionPan(_ sender: UIPanGestureRecognizer) {
    switch sender.state {
    case .began:
      presenter?.userInteraction(true)
      
    case .changed:
      presenter?.didDrag(to: sender.location(in: grid))
      
    case .ended:
      presenter?.userInteraction(false)
      
    default:
      return
    }
  }
  
  @IBAction func actionPinch(_ sender: UIPinchGestureRecognizer) {
    switch sender.state {
    case .began:
      presenter?.userInteraction(true)
      
    case .changed:
      presenter?.didScale(with: sender.scale)
      
    case .ended:
      presenter?.userInteraction(false)
    default:
      return
    }
  }
  
  @IBAction func actionDoubleTap(_ sender: UITapGestureRecognizer) {
    presenter?.centerImage()
  }
}

//MARK: - ImageCropperView

extension ImageCropperViewController: ImageCropperView {
  func set(_ image: UIImage) {
    imgCropping.image = image
  }
  
  func setImageFrame(_ frame: CGRect) {
    imgCropping.frame = frame
  }
  
  func transformImage(with frame: CGRect) {
    UIView.animate(withDuration: 0.2) {
      self.imgCropping.frame = frame
    }
  }
  
  func clearMask() {
    mask.layer.mask = nil
    mask.layer.sublayers?.forEach({ (sublayer) in
      sublayer.removeFromSuperlayer()
    })
  }
  
  func drawMask(by path: CGPath, with fillColor: UIColor) {
    let hole = CAShapeLayer()
    hole.frame = mask.bounds
    hole.path = path
//    hole.fillColor = fillColor
    hole.fillRule = kCAFillRuleEvenOdd
    mask.layer.mask = hole
    mask.backgroundColor = fillColor
  }
  
  func clearBorderAndGrid() {
    grid.layer.sublayers?.forEach({ (sublayer) in
      sublayer.removeFromSuperlayer()
    })
  }
  
  func drawBorber(by path: CGPath, with strokeColor: CGColor) {
    let border = CAShapeLayer()
    border.frame = grid.bounds
    border.path = path
    border.fillColor = UIColor.clear.cgColor
    border.strokeColor = strokeColor
    border.lineWidth = 4
    grid.layer.addSublayer(border)
  }
  
  func drawGrid(with lines: [CGPath], with strokeColor: CGColor) {
    lines.forEach { line in
      let lineLayer = CAShapeLayer()
      lineLayer.path = line
      lineLayer.fillColor = nil
      lineLayer.opacity = 1
      lineLayer.lineWidth = 1
      lineLayer.strokeColor = strokeColor
      grid.layer.insertSublayer(lineLayer, at: 0)
    }
  }

  
  func setDone(_ title: String?) {
    guard let t = title else { return }
    btnDone.setTitle(t, for: .normal)
  }
  
  func setCancel(_ title: String?) {
    guard let t = title else { return }
    btnCancel.setTitle(t, for: .normal)
  }
  
  func showBottomButtons(_ show: Bool) {
    let alpha = show ? 1 : 0
    UIView.animate(withDuration: 0.1) {
      self.bottomBar.alpha = CGFloat(alpha)
    }
  }
  
}
