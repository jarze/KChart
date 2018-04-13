//
//  NYLineStyle.swift
//  KChart
//
//  Created by jarze on 2018/2/27.
//  Copyright © 2018年 jarze. All rights reserved.
//

import Foundation
import UIKit

public let RiseColor = UIColor(red: 242/255, green: 73/255, blue: 87/255, alpha: 1) // 涨 red
public let FallColor = UIColor(red: 29/255, green: 191/255, blue: 96/255, alpha: 1) // 跌 green

struct NYLineStyle {
    
//    var uperChartHeightScale: CGFloat = 0.7 // 70% 的空间是上部分的走势图
    
//    var lineWidth: CGFloat = 1
//    var frameWidth: CGFloat = 0.25
//
//    var xAxisHeitht: CGFloat = 30
//
//
//    var viewMinYGap: CGFloat = 15
//    var volumeGap: CGFloat = 10
    
    var candleWidth: CGFloat = 5
    var candleGap: CGFloat = 2
    var candleMinHeight: CGFloat = 0.5
    var candleMaxWidth: CGFloat = 30
    var candleMinWidth: CGFloat = 2
    
//    var ma5Color = UIColor(red: 134/255, green: 149/255, blue: 166/255, alpha: 1)
//    var ma10Color = UIColor(red: 111/255, green: 168/255, blue: 167/255, alpha: 1)
//    var ma20Color = UIColor(red: 111/255, green: 168/255, blue: 167/255, alpha: 1)
    
    var bgLineWidth:CGFloat = 0.25
    
    var nowVaueIndicatorColor = UIColor.blue
    
    var borderColor = UIColor(red: 228/255, green: 228/255, blue: 228/255, alpha: 1)
    
    var crossLineColor = UIColor(red: 84/255, green: 102/255, blue: 121/255, alpha: 1)
    
    var textColor = UIColor(red: 134/255, green: 149/255, blue: 166/255, alpha: 1)
    var riseColor = UIColor(red: 242/255, green: 73/255, blue: 87/255, alpha: 1) // 涨 red
    var fallColor = UIColor(red: 29/255, green: 191/255, blue: 96/255, alpha: 1) // 跌 green
    
    
    var priceLineColor = UIColor(red: 0/255, green: 149/255, blue: 252/255, alpha: 1)
    var avgLineColor = UIColor(red: 255/255, green: 192/255, blue: 4/255, alpha: 1)
    var fillColor = UIColor(red: 227/255, green: 239/255, blue: 255/255, alpha: 1)
    
    
   
    var baseFont = UIFont.systemFont(ofSize: 10)
    
    var lineColors: [String: UIColor] = [
        "ma5": UIColor(red: 134/255, green: 149/255, blue: 166/255, alpha: 1),
        "ma10": UIColor.red,
        "ma20": UIColor.blue,
        "k": UIColor.green,
        "d": UIColor.cyan,
        "j": UIColor.darkGray,
        "diff": RiseColor,
        "dea": FallColor,
        "close": UIColor.blue
    ]
    
    func getTextSize(text: String) -> CGSize {
        let size = text.size(withAttributes: [NSAttributedStringKey.font: baseFont])
        let width = ceil(size.width) + 5
        let height = ceil(size.height)
        return CGSize(width: width, height: height)
    }
    
    func getEQTextSize(text: String) -> CGSize {
        
        let size = "A".size(withAttributes: [NSAttributedStringKey.font: baseFont])
        let width = ceil(size.width * CGFloat(text.count)) + 1
        let height = ceil(size.height)
        return CGSize(width: width, height: height)
    }
    
    public func getLineColor(_ lineName: String) -> UIColor {
        return lineColors[lineName] ?? UIColor.black
    }
}
