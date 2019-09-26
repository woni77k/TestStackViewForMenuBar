//
//  ViewController.swift
//  TestStackView
//
//  Created by SEUNG-WON KIM on 2019/08/30.
//  Copyright © 2019 SEUNG-WON KIM. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  
  let titles = ["2323232", "323", "99999999999", "5656", "333", "555555555", "2222222"]
  let spacing: CGFloat = 20
  
  lazy var stackScrollView: StackScrollView = {
    let ssv = StackScrollView()
    ssv.translatesAutoresizingMaskIntoConstraints = false
    ssv.showsHorizontalScrollIndicator = false
    return ssv
  }()
  
  lazy var collectionView: UICollectionView = {
    let layer = UICollectionViewFlowLayout()
    layer.scrollDirection = .horizontal
    layer.minimumLineSpacing = 0
    
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layer)
    cv.translatesAutoresizingMaskIntoConstraints = false
    cv.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
    cv.scrollIndicatorInsets = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
    cv.backgroundColor = .white
    cv.delegate = self
    cv.dataSource = self
    cv.isPagingEnabled = true
    cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
    return cv
  }()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do anyadditional setup after loading the view.

    view.addSubview(stackScrollView)
    view.addSubview(collectionView)
    
    stackScrollView.configure(titles: titles, index: 0, textColor: .darkGray, selectedTextColor: .red, font: UIFont.systemFont(ofSize: 18), selectedFont: UIFont.systemFont(ofSize: 18))
    
    
    NSLayoutConstraint.activate([
      stackScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
      stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
      stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
      stackScrollView.heightAnchor.constraint(equalToConstant: 50)
      ])

    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: stackScrollView.bottomAnchor, constant: 10),
      collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
      collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      ])
    
  
  }
  
  @objc func tapHandle() {
    let indexPath = IndexPath(item: 4, section: 0)
    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
}

extension ViewController: UICollectionViewDelegate {
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//    let index = targetContentOffset.pointee.x / view.frame.width
 
    print("** willEndDragging")
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    print("** DidEndDragging")
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    print("** scrollViewDidScroll \(collectionView.isDragging), \(collectionView.isTracking), \(collectionView.isDecelerating)")
    
    guard collectionView.isDragging, collectionView.isTracking, !collectionView.isDecelerating else { return }
    
//     stackView.leftAnchorConstraint?.constant = scrollView.contentOffset.x * (stackView.currentSize() / view.bounds.size.width)
  }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.bounds.size.width, height: 300)
  }
}

extension ViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return titles.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath)
    cell.backgroundColor = indexPath.item % 2 == 0 ? .red : .blue
    return cell
  }
}

//
class StackScrollView: UIScrollView {
  lazy var stackView: UIStackView = {
    let sv = UIStackView()
    sv.translatesAutoresizingMaskIntoConstraints = false
    sv.axis = .horizontal
    sv.alignment = .center
    
    sv.distribution = .equalSpacing
    sv.spacing = 10
    sv.setNeedsLayout()
    return sv
  }()
  
  let bar: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.backgroundColor = .red
    return v
  }()
  
  var spacing: CGFloat = 0 {
    didSet {
      stackView.spacing = spacing
    }
  }
  
  var tapHander: ((Int) -> ())?
  
  private var textColor: UIColor?
  private var selectedTextColor: UIColor?
  
  private var font: UIFont?
  private var selectedFont: UIFont?
  private var currentIndex = 0

  var leftAnchorConstraint: NSLayoutConstraint!
  private var widthAnchorConstraint: NSLayoutConstraint!

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(stackView)
    addSubview(bar)

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.leftAnchor.constraint(equalTo: leftAnchor),
      stackView.rightAnchor.constraint(equalTo: rightAnchor),
      stackView.bottomAnchor.constraint(equalTo: bar.topAnchor, constant: -4)
      ])
    
    
    leftAnchorConstraint = bar.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
    leftAnchorConstraint.isActive = true
    widthAnchorConstraint = bar.widthAnchor.constraint(equalToConstant: 0)
    widthAnchorConstraint.isActive = true
    
    NSLayoutConstraint.activate([
      bar.bottomAnchor.constraint(equalTo: bottomAnchor),
      bar.heightAnchor.constraint(equalToConstant: 3)
      ])
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()

    contentSize = stackView.frame.size
  }
  
  func configure(titles: [String], index: Int, textColor: UIColor, selectedTextColor: UIColor, font: UIFont, selectedFont: UIFont) {
    self.currentIndex = index
    self.textColor = textColor
    self.selectedTextColor = selectedTextColor
    self.font = font
    self.selectedFont = selectedFont
    setButtons(titles: titles)
    
    let isOverSize = bounds.size.width - (totalSiz() + CGFloat(titles.count - 1) * 50)
    
    // set contents Size
    layoutIfNeeded()
    
    //
    update()
  }
  
  func update() {
    stackView.arrangedSubviews.forEach({
      let isSelected = $0.tag == currentIndex
      ($0 as? UIButton)?.setTitleColor(isSelected ? selectedTextColor : textColor, for: .normal)
      ($0 as? UIButton)?.titleLabel?.font = isSelected ? selectedFont : font
      
      if isSelected {
        leftAnchorConstraint.constant = $0.frame.origin.x
        widthAnchorConstraint.constant = $0.bounds.size.width
      }
      
      UIView.animate(withDuration: 0.3, animations: {
        self.layoutIfNeeded()
      }, completion: { (_) in
      })
    })
  }
  
  private func setButtons(titles: [String]) {
    for (i, title) in titles.enumerated() {
      let btn = UIButton()
      btn.addTarget(self, action: #selector(tapHandler), for: .touchUpInside)
      btn.setTitle(title, for: .normal)
      btn.tag = i
      stackView.addArrangedSubview(btn)
    }
  }
  
  @objc private func tapHandler(_ sender: UIButton) {
    currentIndex = sender.tag
    tapHander?(currentIndex)
    update()
  }
  
  private func totalSiz() -> CGFloat {
    return stackView.arrangedSubviews.map { $0.bounds.width }.reduce(0, +)
  }
}


//final class CStackView: UIStackView {
//  var tapHander: ((Int) -> ())?
//
//  private var textColor: UIColor?
//  private var selectedTextColor: UIColor?
//
//  private var font: UIFont?
//  private var selectedFont: UIFont?
//  private var currentIndex = 0
//
//  override init(frame: CGRect) {
//    super.init(frame: frame)
//  }
//
//  required init(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//
//  override func layoutSubviews() {
//    super.layoutSubviews()
//
//    update()
//  }
//
//  func configure(titles: [String], index: Int, textColor: UIColor, selectedTextColor: UIColor, font: UIFont, selectedFont: UIFont) {
//
//    self.currentIndex = index
//    self.textColor = textColor
//    self.selectedTextColor = selectedTextColor
//    self.font = font
//    self.selectedFont = selectedFont
//    setButtons(titles: titles)
//    update()
//  }
//
//
//
//  func currentSize() -> CGRect {
//    print(currentIndex, arrangedSubviews[currentIndex].frame.size.width)
//    return arrangedSubviews.count > 0 ? arrangedSubviews[currentIndex].frame : CGRect()
//  }
//
//  func selected(index: Int) {
//    currentIndex = index
//    update()
//  }
//
//  private func update() {
//    let _  = arrangedSubviews.map {
//      let isSelected = $0.tag == currentIndex
//      ($0 as? UIButton)?.setTitleColor(isSelected ? selectedTextColor : textColor, for: .normal)
//      ($0 as? UIButton)?.titleLabel?.font = isSelected ? selectedFont : font
//      layoutIfNeeded()
//    }
//  }
//}
