//
//  NYKLineModel.swift
//  KChart
//
//  Created by jarze on 2018/2/27.
//  Copyright © 2018年 jarze. All rights reserved.
//

import UIKit

public class NYKLineModel: NSObject {

    var open: CGFloat = 0
    var close: CGFloat = 0
    var high: CGFloat = 0
    var low: CGFloat = 0
    var volume: CGFloat = 0
    var timesTamp: Double = 0
    
    //标志第几个数据
//    var index: Int = 0
//    var timeX:Double = 0
    
    var isAvailable: Bool = true
    
    var date:Date {
        get {
            return Date.init(timeIntervalSince1970: TimeInterval(timesTamp))
        }
    }
    
    // 各指标值
    var indicators:[String: CGFloat] = [String: CGFloat]()
    
    public func getInVal(_ chartKey: String) -> CGFloat {
        return indicators[chartKey] ?? 0
    }
    
    public func getDate(format: String = "HH:mm") -> String {
        let dformatter = DateFormatter()
        dformatter.dateFormat = format
        return dformatter.string(from: date)
    }

}
