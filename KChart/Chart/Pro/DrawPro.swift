//
//  DrawPro.swift
//  KChart
//
//  Created by jarze on 2018/2/27.
//  Copyright © 2018年 jarze. All rights reserved.
//

import Foundation
import UIKit


public enum NYChartType: Int {
    case timeLineForDay
    case timeLineForFiveday
    case kLineForDay
    case kLineForWeek
    case kLineForMonth
}


public enum NYChartKey: String {
    case KLine = "kline"
    case MA = "ma"
    case MACD = "macd"
    case VOL = "volume"
    case KDJ = "kdj"
    case CLOSE = "close"
    
    
    // 各类型图指标点
    func params() -> [String] {
        switch self {
        case .KLine:
            return ["open", "close", "high", "low"]
        case .MACD:
            return ["diff", "dea", "macd"]
        case .VOL:
            return ["volume"]
        case .KDJ:
            return ["k", "d", "j"]
        case .MA:
            return ["ma5", "ma10", "ma20"]
        case .CLOSE:
            return ["close"]
        }
    }
    
    // 各类型图坐标点
    func pKeys() -> [String] {
        switch self {
        case .KLine:
            return ["open", "close", "high", "low"]
        case .MACD:
            return ["diff", "dea", "macd", "macdZero"]
        case .VOL:
            return ["volume", "zero"]
        case .KDJ:
            return ["k", "d", "j"]
        case .MA:
            return ["ma5", "ma10", "ma20"]
        case .CLOSE:
            return ["close"]
        }
    }
    
    // 各类型图线
    func lineKeys() -> [String] {
        switch self {
        case .KLine:
            return []
        case .MACD:
            return ["diff", "dea"]
        case .VOL:
            return ["volume"]
        case .KDJ:
            return ["k", "d", "j"]
        case .MA:
            return ["ma5", "ma10", "ma20"]
        case .CLOSE:
            return ["close"]
        }
    }
    
    // 各类型图线
    func barKey() -> [String] {
        switch self {
        case .KLine:
            return ["open", "close"]
        case .MACD:
            return ["macdZero", "macd"]
        case .VOL:
            return ["zero", "volume"]
        case .KDJ:
            return []
        case .MA:
            return []
        case .CLOSE:
            return ["close"]
        }
    }
}

//public enum NYKLineNonus: String {
//    public typealias RawValue = ""
//
//    case: k
//
//}

protocol NYDrawLayerProtocol {
    
//    var theme: HSTimeLineStyle { get }
    func getLinesPath(lines: [[CGPoint]]) -> UIBezierPath
    
//    func drawLineInLayer(layer: CAShapeLayer?, lineWidth: CGFloat, points: [CGPoint], strokeColor: UIColor, fillColor: UIColor, isDash: Bool, isAnimate: Bool)

//    func drawLine(lineWidth: CGFloat, points: [CGPoint], strokeColor: UIColor, fillColor: UIColor, isDash: Bool, isAnimate: Bool) -> CAShapeLayer

    func drawCloseLine(lineWidth: CGFloat,points: [CGPoint],strokeColor: UIColor,closeY: CGFloat,gradSize:CGSize) -> CAShapeLayer
    
    func drawTextLayer(frame: CGRect, text: String, foregroundColor: UIColor, backgroundColor: UIColor, fontSize: CGFloat) -> CATextLayer

//    func getCrossLineLayer(frame: CGRect, pricePoint: CGPoint, volumePoint: CGPoint, model: AnyObject?) -> CAShapeLayer
    func drawIntermittentLine(lineWidth: CGFloat,lines: [[CGPoint]],strokeColor: UIColor,layer: CAShapeLayer?, fillColor: UIColor, isDash: Bool, isAnimate: Bool) -> CAShapeLayer
    
}

extension NYDrawLayerProtocol {
    
    func drawIntermittentLine(lineWidth: CGFloat,
                              lines: [[CGPoint]],
                              strokeColor: UIColor,
                              layer: CAShapeLayer? = nil,
                              fillColor: UIColor = UIColor.clear,
                              isDash: Bool = false,
                              isAnimate: Bool = false) -> CAShapeLayer {

        let lineLayer = layer ?? CAShapeLayer()
        let linePath = self.getLinesPath(lines: lines)
        
        lineLayer.path = linePath.cgPath
        lineLayer.lineWidth = lineWidth
        lineLayer.strokeColor = strokeColor.cgColor
        lineLayer.fillColor = fillColor.cgColor
        
        if isDash {
            lineLayer.lineDashPattern = [3, 3]
        }

        if isAnimate {
            let path = CABasicAnimation(keyPath: "strokeEnd")
            path.duration = 1.0
            path.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            path.fromValue = 0.0
            path.toValue = 1.0
            lineLayer.add(path, forKey: "strokeEndAnimation")
            lineLayer.strokeEnd = 1.0
        }
        return lineLayer
    }
    
    func drawLine(lineWidth: CGFloat,
                  points: [CGPoint],
                  strokeColor: UIColor,
                  fillColor: UIColor,
                  isDash: Bool = false,
                  isAnimate: Bool = false) -> CAShapeLayer {

        let lineLayer = CAShapeLayer()
        return drawIntermittentLine(lineWidth: lineWidth, lines: [points], strokeColor: strokeColor, layer: lineLayer, fillColor: fillColor, isDash:isDash, isAnimate: isAnimate)
    }
    
    func drawCloseLine(lineWidth: CGFloat,
                  points: [CGPoint],
                  strokeColor: UIColor,
                  closeY: CGFloat = 0,
                  gradSize:CGSize = CGSize.zero) -> CAShapeLayer {
        if points.count < 2 {
            return CAShapeLayer()
        }
        let linePath = getPath(points: points)
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.lineWidth = lineWidth
        lineLayer.strokeColor = strokeColor.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        
        if (gradSize != CGSize.zero) {
            let gradientLayer = CAGradientLayer.init()
            gradientLayer.frame = CGRect.init(origin: CGPoint.zero, size: gradSize)
            gradientLayer.colors = [UIColor.init(red: 0, green: 0, blue: 255, alpha: 1).cgColor, UIColor.init(red: 0, green: 0, blue: 255, alpha: 0).cgColor]
            gradientLayer.locations = [0, 1]
            let ll = CAShapeLayer()
            
            linePath.addLine(to: CGPoint.init(x: (points.last?.x)!, y: closeY))
            linePath.addLine(to: CGPoint.init(x: points[0].x, y: closeY))
            ll.path = linePath.cgPath
            gradientLayer.mask = ll
            lineLayer.addSublayer(gradientLayer)
        }
        return lineLayer
    }
    
    func drawTextLayer(frame: CGRect,
                       text: String,
                       foregroundColor: UIColor,
                       backgroundColor: UIColor = UIColor.clear,
                       fontSize: CGFloat = 10) -> CATextLayer {
        
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.string = text
        textLayer.fontSize = fontSize
        textLayer.foregroundColor = foregroundColor.cgColor
        textLayer.backgroundColor = backgroundColor.cgColor
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }
    
    func getPath(points: [CGPoint]) -> UIBezierPath {
        let linePath = UIBezierPath()
        for index in 0 ..< points.count {
            if (index == 0) {
                linePath.move(to: points[index])
            } else {
                linePath.addLine(to: points[index])
            }
        }
        return linePath
    }
    
    func getLinesPath(lines: [[CGPoint]] = []) -> UIBezierPath {
        let linePath = UIBezierPath()
        lines.forEach { (points) in
            for index in 0 ..< points.count {
                if (index == 0) {
                    linePath.move(to: points[index])
                } else {
                    linePath.addLine(to: points[index])
                }
            }
        }
        return linePath
    }
}

