//
//  NYCandle.swift
//  KChart
//
//  Created by jarze on 2018/2/27.
//  Copyright © 2018年 jarze. All rights reserved.
//

import UIKit

class NYCandle: NSObject {
    
    var isAvailable: Bool = true

//    var index:Int = 0
    
    var candleFillColor: UIColor = UIColor.black
//    var candleRect: CGRect = CGRect.zero
    var openPoint: CGPoint = .zero
    var closePoint: CGPoint = .zero
    var highPoint: CGPoint = .zero
    var lowPoint: CGPoint = .zero
    
    var points: [String: CGPoint] = [String: CGPoint]()
    
    var lineColors: [String: UIColor] = [String: UIColor]()
    
    
    public func getPoint(_ pName: String) -> CGPoint {
        return points[pName] ?? CGPoint.zero
    }
    
    public func getLineColor(_ lineName: String) -> UIColor {
        return lineColors[lineName] ?? UIColor.black
    }
}
