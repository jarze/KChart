//
//  NYData.swift
//  KChart
//
//  Created by jarze on 2018/2/28.
//  Copyright © 2018年 jarze. All rights reserved.
//

import Foundation
import UIKit

public struct NYData {
    
    public static func calIndicators(ticks: [NYKLineModel], charts:[NYChartKey]) -> [NYKLineModel] {
        
        var datas:[String: [CGFloat]] = [:]
        charts.forEach { (chart) in
            switch(chart) {
            case .MA:
                datas["ma5"] = ma(ticks: ticks, days: 5)
                datas["ma10"] = ma(ticks: ticks, days: 10)
                datas["ma20"] = ma(ticks: ticks, days: 20)
            case .MACD:
                let data = macd(ticks: ticks)
                for key in data.keys {
                    datas[key] = data[key]
                }
            case .KDJ:
                let data = kdj(ticks: ticks)
                for key in data.keys {
                    datas[key] = data[key]
                }
            default:
                break
            }
        }
        
        var data = ticks
        for (i, _):(Int, NYKLineModel) in ticks.enumerated() {
            data[i].indicators["high"] = data[i].high
            data[i].indicators["low"] = data[i].low
            data[i].indicators["open"] = data[i].open
            data[i].indicators["close"] = data[i].close
            data[i].indicators["volume"] = data[i].volume
            datas.forEach({ (key, values) in
                data[i].indicators[key] = values[i]
            })
        }
        return data
    }
    
    public static func ema(lastEma: CGFloat, close: CGFloat, n: Int) -> CGFloat {
        let a = 2.0 / CGFloat(n + 1)
        return a * close + (1 - a) * lastEma
    }
    
    public static func dea(lasDea: CGFloat, curDiff: CGFloat) -> CGFloat {
        return (lasDea * 8.0 + curDiff * 2.0) / 10.0
    }
    
    public static func macd(ticks: [NYKLineModel]) ->  [String: [CGFloat]]{
        var ema12:[CGFloat] = [],
        ema26:[CGFloat] = [],
        diffs:[CGFloat] = [],
        deas:[CGFloat] = [],
        bars:[CGFloat] = []
        
        for (i, t):(Int, NYKLineModel) in ticks.enumerated() {
            let c = t.close
            if (i == 0) {
                ema12.append(c)
                ema26.append(c)
                deas.append(0)
            } else {
                if t.isAvailable {
                    ema12.append(ema(lastEma: ema12[i - 1], close: c, n: 12))
                    ema26.append(ema(lastEma: ema26[i - 1], close: c, n: 26))
                } else {
                    ema12.append(ema(lastEma: 0, close: 0, n: 12))
                    ema26.append(ema(lastEma: 0, close: 0, n: 26))
                }
            }
            diffs.append(ema12[i] - ema26[i])
            if (i != 0) {
                deas.append(dea(lasDea: deas[i - 1], curDiff: diffs[i]))
            }
            bars.append((diffs[i] - deas[i]) * 2)
        }
        
        let data = [
            "diff": diffs,
            "dea": deas,
            "macd": bars
        ]
        return data
    }
    
    public static func ma(ticks: [NYKLineModel], days: Int) ->  [CGFloat] {
        var mas:[CGFloat] = []
        var nma:[CGFloat] = []
        for (_, t):(Int, NYKLineModel) in ticks.enumerated() {
            nma.append(t.close)
            if !t.isAvailable {
                nma.removeAll()
            }
            if (nma.count == days) {
                let nowMa = nma.reduce(0, { (sum, item) -> CGFloat in
                    return sum + item
                }) / CGFloat(days)
                mas.append(nowMa)
                nma.removeFirst()
            } else {
                mas.append(t.close)
            }
        }
        return mas
    }
    
    public static func kdj(ticks: [NYKLineModel]) ->  [String: [CGFloat]] {
        var nineDaysTicks: [NYKLineModel] = [],
        days = 9,
        rsvs:[CGFloat] = []
        var ks:[CGFloat] = [],
        ds:[CGFloat] = [],
        js:[CGFloat] = []
        
        for (i, t):(Int, NYKLineModel) in ticks.enumerated() {
            let close = t.close
            nineDaysTicks.append(t)
            let maxAndMin = nineDaysTicks.reduce([CGFloat.leastNormalMagnitude, CGFloat.greatestFiniteMagnitude], { (result, item) -> [CGFloat] in
                var res = result
                if item.isAvailable {
                    res[0] = item.high > res[0] ? item.high : res[0]
                    res[1] = item.low < res[1] ? item.low : res[1]
                }
                return res
            })
            if maxAndMin.count > 1 {
                let max = maxAndMin[0]
                let min = maxAndMin[1]
                if (max == min || !t.isAvailable) {
                    rsvs.append(0)
                } else {
                    rsvs.append((close - min) / (max - min) * 100.0)
                }
            } else {
                rsvs.append(0)
            }
            if (nineDaysTicks.count == days) {
                nineDaysTicks.removeFirst()
            }
            if (i == 0) {
                let k = rsvs[i]
                ks.append(k)
                let d = k
                ds.append(d)
                let j = 3.0 * k - 2.0 * d
                js.append(j)
            } else {
                let k = 2.0 / 3.0 * ks[i - 1] + 1.0 / 3.0 * rsvs[i]
                ks.append(k)
                let d = 2.0 / 3.0 * ds[i - 1] + 1.0 / 3.0 * k
                ds.append(d)
                let j = 3.0 * k - 2.0 * d
                js.append(j)
            }
        }
        return [
            "k": ks,
            "d": ds,
            "j": js,
            "rsv": rsvs
        ]
    }
}
