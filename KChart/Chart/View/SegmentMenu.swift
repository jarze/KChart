//
//  SegmentMenu.swift
//  KChart
//
//  Created by jarze on 2018/3/8.
//  Copyright © 2018年 jarze. All rights reserved.
//

import UIKit

@objc protocol SegmentMenuDelegate {
    func menuButtonDidClick(index: Int)
}

class SegmentMenu: UIView {
    
    weak var delegate: SegmentMenuDelegate?
    
    var scrollView: UIScrollView!
    
    var bottomIndicator: UIView!
    var bottomLine: UIView!
    var buttonWidth: CGFloat = 0
    var menuButtonArray: [UIButton] = []
    
    var menuTitleArray: [String] = [] {
        willSet (newMenuNameArray) {
            self.addMenuButton(menuNameArray: newMenuNameArray)
        }
    }
    
    var selectedButton: UIButton? {
        willSet (newSelectButton) {
            if newSelectButton == selectedButton {
                return
            }
            selectedButton?.setTitleColor(UIColor.black, for: .normal)
            newSelectButton?.setTitleColor(UIColor.hschart.color(rgba: "#1782d0"), for: .normal)
            let x = self.buttonWidth * CGFloat((newSelectButton?.tag)!)
            UIView.animate(withDuration: 0.3) {
                self.bottomIndicator.frame.origin.x = x
            }
            
            scrollView.scrollRectToVisible(CGRect(x: x - 2 * buttonWidth, y:0, width: scrollView.bounds.width, height: scrollView.bounds.height), animated: true)
        }
    }
    
    var indicatorHeight: CGFloat = 2
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        scrollView = UIScrollView(frame: bounds)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        bottomIndicator = UIView()
        bottomIndicator.backgroundColor = UIColor.hschart.color(rgba: "#1782d0")
        bottomLine = UIView(frame: CGRect(x: 0, y: frame.height - 0.5, width: frame.width, height: 0.5))
        bottomLine.backgroundColor = UIColor.hschart.color(rgba: "#e4e4e4")
        
//        self.addSubview(bottomIndicator)
//        self.addSubview(bottomLine)
        
        self.addSubview(scrollView)
        
        scrollView.addSubview(bottomIndicator)
        self.addSubview(bottomLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - add segment button
    
    fileprivate func addMenuButton(menuNameArray: [String]) {
        self.menuButtonArray.forEach() {$0.removeFromSuperview()}
        self.menuButtonArray.removeAll()
        
        buttonWidth = max(scrollView.bounds.width / CGFloat(menuNameArray.count), 50)
        var x: CGFloat = 0
        for index in 0 ..< menuNameArray.count {
            let button = UIButton()
            button.setTitle(menuNameArray[index], for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.setTitleColor(UIColor.black, for: .normal)
            button.addTarget(self, action: #selector(menuButtonDidClick(_:)), for: .touchUpInside)
            button.tag = index
            button.frame = CGRect(x: x, y: 0, width: buttonWidth, height: self.bounds.height)
            x += buttonWidth
            scrollView.addSubview(button)
            menuButtonArray.append(button)
        }
        bottomIndicator.frame = CGRect(x: 0, y: scrollView.bounds.height - indicatorHeight, width: buttonWidth, height: indicatorHeight)
        
        let cw = buttonWidth * CGFloat(menuNameArray.count)
        scrollView.contentSize = CGSize(width:cw, height: scrollView.bounds.height)
    }
    
    // MARK: - segment button 点击事件
    @objc func menuButtonDidClick(_ button: UIButton) {
        setSelectButton(index: button.tag)
    }
    
    func setSelectButton(index: Int) {
        if (self.menuButtonArray.count > 0){
            self.selectedButton = self.menuButtonArray[index]
            delegate?.menuButtonDidClick(index: index)
        }
    }
}

