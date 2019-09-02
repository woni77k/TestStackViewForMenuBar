//
//  ViewController.swift
//  TestStackView
//
//  Created by SEUNG-WON KIM on 2019/08/30.
//  Copyright © 2019 SEUNG-WON KIM. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  
  let titles = ["2323232", "323", "99999999999", "5656"]
  let spacing: CGFloat = 20
  
  let scrollView: UIScrollView = {
    let sv = UIScrollView()
    sv.translatesAutoresizingMaskIntoConstraints = false
    sv.isScrollEnabled = true
    sv.alwaysBounceHorizontal = true
    sv.alwaysBounceVertical = false
    return sv
  }()
  
  lazy var stackView: CStackView = {
    let sv = CStackView()
    sv.translatesAutoresizingMaskIntoConstraints = false
    sv.axis = .horizontal
    sv.alignment = UIStackView.Alignment.center
    sv.distribution = UIStackView.Distribution.equalSpacing
    sv.spacing = spacing
    sv.setNeedsLayout()
    return sv
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
    
    view.addSubview(scrollView)
    scrollView.addSubview(stackView)
    view.addSubview(collectionView)
    
    stackView.configure(titles: titles, index: 0, textColor: .darkGray, selectedTextColor: .red, font: UIFont.systemFont(ofSize: 14), selectedFont: UIFont.boldSystemFont(ofSize: 14))
    stackView.tapHander = { [weak self] index in
      let indexPath = IndexPath(item: index, section: 0)
      self?.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
//    let button = UIButton()
//    button.translatesAutoresizingMaskIntoConstraints = false
//    button.backgroundColor = .red
//    button.setTitle("Go", for: .normal)
//    button.addTarget(self, action: #selector(tapHandle), for: .touchUpInside)
//    view.addSubview(button)
//    NSLayoutConstraint.activate([
//      button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
//      button.heightAnchor.constraint(equalToConstant: 20),
//      button.widthAnchor.constraint(equalToConstant: 100),
//      button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//      ])
    
//    var titleSizes = [CGFloat]()
//
//    for i in 0...8 {
//      let label = UILabel()
//      label.text = "Number:\(i)"
//      label.font = UIFont.systemFont(ofSize: 12)
//
//      stackView.addArrangedSubview(label)
//      label.sizeToFit()
//      titleSizes.append(label.bounds.size.width)
//    }
//
//    let totalSize =  titleSizes.reduce(0, +)//stackView.arrangedSubviews.map { $0.bounds.size.width }
    let conSize = stackView.totalSiz() + CGFloat(titles.count - 1) * spacing
    stackView.frame = CGRect(x: 0, y: 0, width: conSize, height: 50)
    scrollView.contentSize = CGSize(width: conSize, height: 50)
    
    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.heightAnchor.constraint(equalToConstant: 50),
      scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
      ])

    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 10),
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
    stackView.layoutIfNeeded()
  }
}

extension ViewController: UICollectionViewDelegate {
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let index = targetContentOffset.pointee.x / view.frame.width
    stackView.selected(index: Int(index))
    print("** willEndDragging")
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    print("** DidEndDragging")
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    print("** scrollViewDidScroll \(collectionView.isDragging), \(collectionView.isTracking), \(collectionView.isDecelerating)")
    
    guard collectionView.isDragging, collectionView.isTracking, !collectionView.isDecelerating else { return }
    
     stackView.leftAnchorConstraint?.constant = scrollView.contentOffset.x * (stackView.currentSize() / view.bounds.size.width)
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






final class CStackView: UIStackView {
  
  
  var tapHander: ((Int) -> ())?
  
  private var textColor: UIColor?
  private var selectedTextColor: UIColor?
  
  private var font: UIFont?
  private var selectedFont: UIFont?
  
  var leftAnchorConstraint: NSLayoutConstraint?
  private var widthAnchorConstraint: NSLayoutConstraint?
  private var currentIndex = 0
  
  private let barView: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.backgroundColor = .red
    v.setNeedsLayout()
    return v
  }()
  

  
//  init(titles: [String], index: Int, textColor: UIColor, selectedTextColor: UIColor, font: UIFont, selectedFont: UIFont) {
  
//    self.currentIndex = index
//    self.textColor = textColor
//    self.selectedTextColor = selectedTextColor
//    self.font = font
//    self.selectedFont = selectedFont
    
//    super.init(frame: .zero)
//    setupViews()
    
//    setButtons(titles: titles)
//    update()
//  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupViews()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(titles: [String], index: Int, textColor: UIColor, selectedTextColor: UIColor, font: UIFont, selectedFont: UIFont) {
    
    self.currentIndex = index
    self.textColor = textColor
    self.selectedTextColor = selectedTextColor
    self.font = font
    self.selectedFont = selectedFont
    setButtons(titles: titles)
    update()
  }
  
  private func setButtons(titles: [String]) {
    for (i, title) in titles.enumerated() {
      let b = UIButton()
      b.addTarget(self, action: #selector(tapHandler), for: .touchUpInside)
      b.setTitle(title, for: .normal)
      b.tag = i
      addArrangedSubview(b)
    }
  }
  
  private func update() {
    let _  = arrangedSubviews.map {
      let isSelected = $0.tag == currentIndex
      ($0 as? UIButton)?.setTitleColor(isSelected ? selectedTextColor : textColor, for: .normal)
      ($0 as? UIButton)?.titleLabel?.font = isSelected ? selectedFont : font
      
      if isSelected {
        leftAnchorConstraint?.constant = $0.frame.origin.x
        widthAnchorConstraint?.constant = $0.bounds.size.width
        
        UIView.animate(withDuration: 0.3, animations: {
          self.layoutIfNeeded()
        })
      }
    }
  }
  
  private func setupViews() {
    addSubview(barView)
    
    leftAnchorConstraint = barView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
    leftAnchorConstraint?.isActive = true
    widthAnchorConstraint = barView.widthAnchor.constraint(equalToConstant: 0)
    widthAnchorConstraint?.isActive = true
    
    NSLayoutConstraint.activate([
      barView.bottomAnchor.constraint(equalTo: bottomAnchor),
      barView.heightAnchor.constraint(equalToConstant: 3)
      ])
  }
  
  @objc private func tapHandler(_ sender: UIButton) {
    currentIndex = sender.tag
    tapHander?(currentIndex)
    update()
  }
  
  func currentSize() -> CGFloat {
    print(currentIndex, arrangedSubviews[currentIndex].frame.size.width)
    return arrangedSubviews.count > 0 ? arrangedSubviews[currentIndex].frame.size.width : 0
  }
  
  func totalSiz() -> CGFloat {
    return arrangedSubviews.map { $0.bounds.width }.reduce(0, +)
  }
  
  func selected(index: Int) {
    currentIndex = index
    update()
//    let subView = arrangedSubviews[index]
//    print(index, leftAnchorConstraint?.constant, subView.frame.origin.x, subView.frame, barView.frame)
    
//    for (i, subView) in arrangedSubviews.enumerated() {
//
//      if let con = leftAnchorConstraint, (subView.frame.origin.x == con.constant)  {
//        currentIndex = i
//        update()
//        print(i, con.constant, subView.frame.origin.x, subView.frame, barView.frame)
//        break
//      }
//    }
    
  }
  
  
}
