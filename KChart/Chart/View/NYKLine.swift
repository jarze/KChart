//
//  NYKLine.swift
//  KChart
//
//  Created by jarze on 2018/2/27.
//  Copyright © 2018年 jarze. All rights reserved.
//

import UIKit

class HSCAShapeLayer: CAShapeLayer {
    
    // 关闭 CAShapeLayer 的隐式动画，避免滑动时候或者十字线出现时有残影的现象(实际上是因为 Layer 的 position 属性变化而产生的隐式动画)
    override func action(forKey event: String) -> CAAction? {
        return nil
    }
}

// chart 区域划分
class ChartArea {
    
    // 标记区域
    var areaId: String = ""
    
    // 区域范围
    var xStart:CGFloat = 0
    var xEnd:CGFloat = 1
    var yStart:CGFloat = 0
    var yEnd:CGFloat = 1
    
    var yScale:CGFloat = 1
    var xScale:CGFloat = 1
    
    // y间隙
    var startOff:CGFloat = 0
    var endOff:CGFloat = 0
    
    //纵轴
    var yCloumn: Int = 4
    // 横轴
    var xCloumn: Int = 5
    
    // 区域值范围
    var maxValue:CGFloat = 0
    var minValue:CGFloat = 0
    
    // 区域值范围
    var xMaxVa:CGFloat = 0
    var xMinVa:CGFloat = 0
    
    // 实际画线区域
    var startY: CGFloat {
        get {
            return yStart + startOff
        }
    }
    
    var endY: CGFloat {
        get {
            return yEnd - endOff
        }
    }
    
    var vaUnit:CGFloat {
        get {
            if (maxValue - minValue) > 0 {
                return (endY - startY) / (maxValue - minValue)
            }
            return 0
        }
        set {}
    }
    
    var xUnit:CGFloat {
        get {
            if (maxValue - xMinVa) > 0 {
                return (xStart - xEnd) / (xMaxVa - xMinVa)
            }
            return 0
        }
        set {}
    }
    
    // 区域最小 y坐标
    var yMin:CGFloat {
        get {
            return (1 - yStart) * yScale
        }
        set {}
    }
    // 区域最小最大 y坐标
    var yMax:CGFloat {
        get {
            return (1 - yEnd) * yScale
        }
        set {}
    }
    
    /// 获取纵轴坐标
    ///
    /// - Parameter n: 坐标点数
    /// - Returns: [[坐标位置， 坐标值]]
    public func getYColumn(_ n: Int = 0) -> [[CGFloat]] {
        let num = n == 0 ? yCloumn : n
        var yc:[[CGFloat]] = [[CGFloat]]()
        let spe = (yEnd - yStart) / CGFloat(num)
        if num > 2 {
            for i in 1 ..< num {
                let va = yStart + CGFloat(i) * spe
                yc.append([(1 - va) * yScale,getYP(va)])
            }
        } else {
            for i in 0 ... num {
                let va = yStart + CGFloat(i) * spe
                yc.append([(1 - va) * yScale,getYP(va)])
            }
        }
        
        return yc
    }
    
    var contentSize: CGSize {
        get {
            return CGSize.init(width: (xEnd - xStart) * xScale, height: (yEnd - yStart) * yScale)
        }
        set {}
    }
    
    public init(areaId: String, yStart: CGFloat, yEnd: CGFloat, yCloumn:Int = 4, startGap:CGFloat = 0.1, endGap:CGFloat = 0.1) {
        
        self.areaId = areaId
        self.yStart = yStart
        self.yEnd = yEnd
        self.yCloumn = yCloumn
        
        self.startOff = (self.yEnd - self.yStart) * startGap
        self.endOff = (self.yEnd - self.yStart) * endGap
    }
    
    // 根据值大小 获取y坐标值
    public func getYValue(_ value: CGFloat) -> CGFloat {
        let yVAlue = startY + (value - minValue) * vaUnit
        return (1 - yVAlue) * yScale
    }
    
    // 获取y坐标对应值
    public func getYP(_ value: CGFloat) -> CGFloat {
        if vaUnit > 0 {
            let yPoint = minValue + (value - startY) / vaUnit
            if abs(minValue) > 1 && maxValue > 10 || (maxValue - minValue) >= 100 {
                return yPoint.toDeciFormat(2)
            }
            return yPoint.toDeciFormat(8)
        }
        return 0
    }
}


class NYKLine: UIView, NYDrawLayerProtocol {
   
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 坐标区域设置
    let mainArea = ChartArea.init(areaId: "main1", yStart: 0.4, yEnd: 1)
    var areaSet: [NYChartKey: ChartArea] = [NYChartKey: ChartArea]()

    //获取各图坐标系
    func getAllChartArea() -> [NYChartKey: ChartArea] {
        self.drawLines.forEach { (lineKey) in
            _ = getChartArea(lineKey)
        }
        return areaSet
    }
    
    func getChartArea(_ lineKey: NYChartKey) -> ChartArea {
        let area = areaSet[lineKey]
        if (area == nil) {
            switch (lineKey) {
            case .MACD, .KDJ:
                areaSet[lineKey] = ChartArea.init(areaId: "main2", yStart: 0, yEnd: 0.25, yCloumn: 2)
                break
            case .VOL:
                areaSet[lineKey] = ChartArea.init(areaId: "main2", yStart: 0, yEnd: 0.25, yCloumn: 2, startGap: 0, endGap: 0.1)
                break
            default:
                areaSet[lineKey] = mainArea
                break
            }
        }
        return areaSet[lineKey] ?? mainArea
    }
    
    var theme = NYLineStyle()
    
    
    //  当前多图
    var drawLines: [NYChartKey] = [NYChartKey.KLine, NYChartKey.VOL] {
        didSet {
            self.drawKLineView()
        }
    }
   
    
    var stairLayers: [String: HSCAShapeLayer] = [String: HSCAShapeLayer]()
    
    // 获取各图layer // 不需要每次重新创建
    func getChartLayer(_ chartName: String) -> HSCAShapeLayer {
        let layer = stairLayers[chartName]
        if (layer == nil) {
            let newlay = HSCAShapeLayer()
            stairLayers[chartName] = newlay
        }
        return stairLayers[chartName] ?? HSCAShapeLayer()
    }
    
    // 长按活动
    var highLightLayer: HSCAShapeLayer = HSCAShapeLayer()
    var isHighLight: Bool = false {
        didSet {
            if isHighLight {
                
            } else {
                highLightLayer.removeFromSuperlayer()
                self.drawIndicatorLayer(index: startIndex, charts: self.drawLines)
            }
        }
    }
    var highLightIndex: Int = 0 {
        didSet {
            isHighLight = true
            drawHighLightLayer()
        }
    }
    
    // 参数指标数值
    var indicatorLayer: HSCAShapeLayer = HSCAShapeLayer()
    var bgLineLayer: HSCAShapeLayer = HSCAShapeLayer()
    
    var dataK: [NYKLineModel] = []
    var positionModels: [NYCandle] = []
    var klineModels: [NYKLineModel] = []
    
    // k线
    var highMax: CGFloat = 0
    var lowMin: CGFloat = 0
    
    
    var contentOffsetX: CGFloat = 0
    
    var renderRect: CGRect = CGRect.zero
    var renderWidth: CGFloat = 0
    // 计算处于当前显示区域左边隐藏的蜡烛图的个数，即为当前显示的初始 index
    var startIndex: Int {
        get {
            let scrollViewOffsetX = contentOffsetX < 0 ? 0 : contentOffsetX
            var leftCandleCount = Int(abs(scrollViewOffsetX) / (theme.candleWidth + theme.candleGap))

            if leftCandleCount > dataK.count {
                leftCandleCount = dataK.endIndex
                return leftCandleCount
            } else if leftCandleCount == 0 {
                return leftCandleCount
            } else {
                return leftCandleCount + 1
            }
        }
    }
    
    // 当前显示区域起始横坐标 x
    var startX: CGFloat {
        get {
            let scrollViewOffsetX = contentOffsetX < 0 ? 0 : contentOffsetX
            return scrollViewOffsetX
        }
    }
    
    // 当前显示区域最多显示的蜡烛图个数
    var countOfshowCandle: Int {
        get{
            if renderWidth > 0 {
                return Int((renderWidth - theme.candleWidth) / ( theme.candleWidth + theme.candleGap))
            }
            return 0
        }
    }
    
    // 横轴
    var xCloumn: Int {
        get {
            let cl = mainArea.xCloumn
            let cc = countOfshowCandle / cl + 1
            return (countOfshowCandle / cc > 3) ? countOfshowCandle / cc : countOfshowCandle
        }
    }
    
    var kLineType: NYChartType = NYChartType.timeLineForDay
    
    func drawKLineView() {
        calcMaxAndMinData()
        convertToPositionModel(data: dataK)
        clearLayer()
        self.drawxAxisTimeMarkLayer()
        self.drawBgLine()

        self.drawLines.forEach { (lineKey) in
            switch (lineKey) {
            case .KLine:
                drawCandleChartLayer(array: positionModels)
            case .MA:
                drawMALayer(array: positionModels)
            case .MACD:
                drawMacdLayer(array: positionModels)
            case .VOL:
                drawVolumeLayer(array: positionModels)
            case .KDJ:
                drawKDJLayer(array: positionModels)
            case .CLOSE:
                drawCloseLayer(array: positionModels)
                break
            }
        }
        self.drawYAxisValueMarkLayer()
        self.drawIndicatorLayer(index: startIndex, charts: self.drawLines)
        self.drawNowVaueIndicatorLayer(value: 11250)
    }
    
    // 画背景坐标线
    func drawBgLine() {
        bgLineLayer.sublayers?.removeAll()
        let linePath = UIBezierPath()
        
        var yAxis:[String: Bool] = [String: Bool]()
        self.drawLines.forEach { (chart) in
            let area = self.getChartArea(chart)
            if !(yAxis[area.areaId] ?? false) {
                area.getYColumn().forEach { (yv) in
                    linePath.move(to: CGPoint(x: contentOffsetX, y: yv[0]))
                    linePath.addLine(to: CGPoint(x: startX + renderWidth,  y: yv[0]))
                }
            }
        }
        
        let lineLayer = self.getLineLayer(path: linePath, lineWidth: theme.bgLineWidth, color: theme.borderColor)
        bgLineLayer.addSublayer(lineLayer)
        if bgLineLayer.superlayer == nil {
            self.layer.insertSublayer(bgLineLayer, at: 0)
        }
    }
    
    func getLineLayer(path: UIBezierPath, lineWidth:CGFloat, color: UIColor) ->HSCAShapeLayer {
        let lineLayer = HSCAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.lineWidth = lineWidth
        lineLayer.strokeColor = color.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        return lineLayer
    }
    
    // 画x坐标轴
    func drawxAxisTimeMarkLayer() {
        if xCloumn == 0 {
            return
        }
        let xAxisTimeMarkLayer = getChartLayer("XA")
        xAxisTimeMarkLayer.sublayers?.removeAll()
        let cc = Int(countOfshowCandle / xCloumn)
        
//        for i in startIndex ... min((startIndex + countOfshowCandle), self.dataK.count) {
//            let index = startIndex - i
//            if (index - Int(cc / 2)) % cc == 0 {
//                xAxisTimeMarkLayer.addSublayer(drawXaxisTimeMark(xPosition: positionModels[index].closePoint.x, dateString: getTimeStr(klineModels[index])))
//            }
//        }
        
        for (index, position) in positionModels.enumerated() {
            if (index - Int(cc / 2)) % cc == 0 {
                xAxisTimeMarkLayer.addSublayer(drawXaxisTimeMark(xPosition: position.closePoint.x, dateString: getTimeStr(klineModels[index])))
            }
        }
        self.layer.addSublayer(xAxisTimeMarkLayer)
    }
    
    /// 横坐标单个时间标签
    func drawXaxisTimeMark(xPosition: CGFloat, dateString: String) -> HSCAShapeLayer {
        
        let area = getChartArea(NYChartKey.KLine)
        let linePath = getLinesPath(lines: [[CGPoint(x: xPosition, y: area.yMin), CGPoint(x: xPosition,  y: area.yMax)]])
        let lineLayer = self.getLineLayer(path: linePath, lineWidth: theme.bgLineWidth, color: theme.borderColor)
        let textSize = theme.getTextSize(text: dateString)
        
        let shaperLayer = HSCAShapeLayer()
        shaperLayer.addSublayer(lineLayer)
        
        var labelX: CGFloat = 0
        let maxX = frame.maxX - textSize.width
        labelX = xPosition - textSize.width / 2.0
        if labelX > maxX {
            labelX = maxX
        } else if labelX < startX {
            labelX = startX
        } else {
            let timeLayer = drawTextLayer(frame: CGRect(x: labelX, y: area.yMin, width: textSize.width, height: textSize.height),
                                          text: dateString,
                                          foregroundColor: theme.textColor)
            
            shaperLayer.addSublayer(timeLayer)
        }
        
        return shaperLayer
    }
    
    // 画y坐标轴
    func drawYAxisValueMarkLayer() {
        var yAxis:[String: Bool] = [String: Bool]()
        self.drawLines.forEach { (chart) in
            let area = self.getChartArea(chart)
            let layer = getChartLayer(area.areaId)
            if !(yAxis[area.areaId] ?? false) {
                layer.sublayers?.removeAll()
                yAxis[area.areaId] = true
                area.getYColumn().forEach({ (yv) in
                    let text = "\(yv[1])"
                    let textSize = theme.getTextSize(text: text)
                    
                    var pointy = yv[0]
                    if pointy + textSize.height  > area.yMin {
                        pointy = area.yMin - textSize.height
                    } else if pointy < area.yMax {
                        pointy = area.yMax
                    } else {
                        pointy = pointy - textSize.height/2.0
                    }
                    let textLayer = drawTextLayer(frame: CGRect.init(x: contentOffsetX + renderWidth - textSize.width, y: pointy, width: textSize.width, height: textSize.height), text: text, foregroundColor: theme.textColor)
                    layer.addSublayer(textLayer)
                })
                if (layer.superlayer == nil) {
                    self.layer.addSublayer(layer)
                }
            }
        }
    }
    
    // 画指标实时值
    func drawIndicatorLayer(index: Int, charts: [NYChartKey]) {
        guard index > -1 else {
            return
        }
        let entity = self.dataK[min(index, self.dataK.endIndex)]

        indicatorLayer.sublayers?.removeAll()
        charts.forEach { (chart) in
            let areaMain = self.getChartArea(chart)
            let layer = getChartLayer("\(areaMain.areaId)Indicator")
            layer.sublayers?.removeAll()
            
            var sx = contentOffsetX
            chart.params().forEach { (line) in
                let str = "\(line.uppercased()):\(entity.getInVal(line).toDeciFormat(2))"
                let textSize = theme.getEQTextSize(text: str)
                let textLayer = drawTextLayer(frame: CGRect.init(x: sx, y: max(areaMain.yMax - textSize.height, 0), width: textSize.width, height: textSize.height),
                                              text: str,
                                              foregroundColor: theme.getLineColor(line))
                sx += textSize.width
                layer.addSublayer(textLayer)
            }
            indicatorLayer.addSublayer(layer)
        }
        if indicatorLayer.superlayer == nil {
            self.layer.addSublayer(indicatorLayer)
        }
    }
    
    //  当前价格指示图
    func drawNowVaueIndicatorLayer(value: CGFloat) {
        let layer = getChartLayer("VA")
        layer.sublayers?.removeAll()
        
        let text = "\(value)"
        let textSize = theme.getTextSize(text: text)
        
        var pointy = mainArea.getYValue(value)
        if value < mainArea.minValue {
            pointy = mainArea.yMin - textSize.height / 2.0
        } else if(value > mainArea.maxValue) {
            pointy = mainArea.yMax + textSize.height / 2.0
        }
        
        layer.addSublayer(drawLine(lineWidth: 1, points: [CGPoint.init(x: contentOffsetX, y: pointy), CGPoint.init(x: contentOffsetX + renderWidth - textSize.width, y: pointy)], strokeColor: theme.nowVaueIndicatorColor, fillColor: UIColor.clear, isDash: true, isAnimate: false))
        
        let textLayer = drawTextLayer(frame: CGRect.init(origin: CGPoint.init(x: contentOffsetX + renderWidth - textSize.width, y: pointy - textSize.height / 2.0), size: textSize), text: text, foregroundColor: theme.nowVaueIndicatorColor)
        
        layer.addSublayer(textLayer)
        if layer.superlayer == nil {
            self.layer.addSublayer(layer)
        }
    }
    
    /// 清除图层
    func clearLayer() {
        self.layer.sublayers?.removeAll()
    }
    
    /// 计算当前显示各坐标系区域的最大最小值
    fileprivate func calcMaxAndMinData() {
        if dataK.count > 0 {
            // 重置各坐标系
            self.getAllChartArea().forEach({ (chartKay, area) in
                area.maxValue = CGFloat.leastNormalMagnitude
                area.minValue = CGFloat.greatestFiniteMagnitude
                area.yScale = self.frame.height
                area.xScale = self.frame.width
            })
            
            self.highMax = CGFloat.leastNormalMagnitude
            self.lowMin = CGFloat.greatestFiniteMagnitude

            var startIndex = self.startIndex

            // 比计算出来的多加一个，是为了避免计算结果的取整导致少画
            let count = min((startIndex + countOfshowCandle + 1), dataK.count)
            if count == dataK.count && dataK.count > countOfshowCandle {
                startIndex = dataK.count - countOfshowCandle
            }

            if startIndex < count {
                // 计算指标值
//                let st = max(startIndex - 20, 0)
//                let data = NYData.calIndicators(ticks: Array(dataK[st ..< count]), charts: self.drawLines)
//                dataK[st ..< count] = ArraySlice(data)
                
                for i in startIndex ..< count {
                    let entity = dataK[i]
                    
                    if !entity.isAvailable {
                        continue
                    }
                    
                    self.drawLines.forEach({ (key) in
                        let area = self.getChartArea(key)
                        switch (key) {
                        case .KLine:
                            let ma = max(area.maxValue, entity.high)
                            let mi = min(area.minValue, entity.low)
                            highMax = ma
                            lowMin = mi
                            area.maxValue = ma
                            area.minValue = mi
                            break;
                        case NYChartKey.MA:
                            let tempMAMax = max(entity.getInVal("ma5"), entity.getInVal("ma10"), entity.getInVal("ma20"))
                            let tempMAMin = min(entity.getInVal("ma5"), entity.getInVal("ma10"), entity.getInVal("ma20"))
                            area.maxValue = max(area.maxValue, tempMAMax)
                            if tempMAMin > 0 {
                                area.minValue = min(area.minValue, tempMAMin)
                            }
                            break;
                        case .VOL:
                            area.maxValue = max(area.maxValue, entity.volume)
                            area.minValue = 0
                            break;
                        case .MACD:
                            let tempMax = max(abs(entity.getInVal("diff")), abs(entity.getInVal("entity.dea")), abs(entity.getInVal("macd")))
                            area.maxValue = max(area.maxValue , tempMax)
                            area.minValue = min(area.minValue, -tempMax)
                            break;
                        case .KDJ:
                            let tempMax = max(abs(entity.getInVal("k")), abs(entity.getInVal("d")), abs(entity.getInVal("j")))
                            let tempMin = min(abs(entity.getInVal("k")), abs(entity.getInVal("d")), entity.getInVal("j"))
                            area.maxValue = max(area.maxValue, tempMax)
                            area.minValue = min(area.minValue, tempMin)
                            break;
//                        case .CLOSE:
//                            area.maxValue = max(area.maxValue, entity.getInVal("close"))
//                            area.minValue = min(area.minValue, entity.getInVal("close"))
//                            break;
                        default:
                            let vals = key.params().map({ (par) -> CGFloat in
                                return entity.getInVal(par)
                            })
                            area.maxValue = max(area.maxValue,vals.max()!)
                            area.minValue = min(area.minValue ,vals.min()!)
                            break
                        }
                    })
                }
            }
        }
    }
    
    /// 转换为坐标 model
    ///
    /// - Parameter data: [HSKLineModel]
    fileprivate func convertToPositionModel(data: [NYKLineModel]) {
        guard data.count > 0 else {
            return
        }
        self.positionModels.removeAll()
        self.klineModels.removeAll()
        let count = min((startIndex + countOfshowCandle + 1), data.count)
        
        if startIndex < count {
            for index in startIndex ..< count {
                let model = data[index]
                
                let leftPosition = startX + CGFloat(index - startIndex) * (theme.candleWidth + theme.candleGap)
                let xPosition = leftPosition + theme.candleWidth / 2.0

                let positionModel = NYCandle()
                
                positionModel.isAvailable = model.isAvailable
                
                self.drawLines.forEach({ (key) in
                    let area = self.getChartArea(key)
                        if area.vaUnit > 0 {
                            // 值转坐标
                            key.pKeys().forEach({ (pKey) in
                                positionModel.points[pKey] = CGPoint(x: xPosition, y: area.getYValue(model.getInVal(pKey)))
                            })
                            if (area === mainArea) {
                                positionModel.highPoint = CGPoint(x: xPosition, y: area.getYValue(model.high))
                                positionModel.lowPoint = CGPoint(x: xPosition, y: area.getYValue(model.low))
                                positionModel.openPoint = CGPoint(x: xPosition, y: area.getYValue(model.open))
                                positionModel.closePoint = CGPoint(x: xPosition, y: area.getYValue(model.close))
                            }
                            if key == NYChartKey.KLine {
                                var fillCandleColor = UIColor.black
                                if(model.open < model.close) {
                                    fillCandleColor = theme.riseColor
                                } else if(model.open > model.close) {
                                    fillCandleColor = theme.fallColor
                                } else {
                                    if(index > 0) {
                                        let preKLineModel = data[index - 1]
                                        fillCandleColor = model.open > preKLineModel.close ? theme.riseColor : theme.fallColor
                                    }
                                }
                                positionModel.candleFillColor = fillCandleColor
                            }
                        }
                    })
                self.positionModels.append(positionModel)
                self.klineModels.append(model)
            }
        }
    }
    
    /// 画蜡烛图
    func drawCandleChartLayer(array: [NYCandle]) {
        let layer = getChartLayer(NYChartKey.KLine.rawValue)
        layer.sublayers?.removeAll()
        
        var highIndex:Int = -1
        var lowIndex:Int = -1

        for (i, object):(Int, NYCandle) in array.enumerated() {
            let mo = self.klineModels[i]
            if mo.isAvailable {
                let candleLayer = getCandleLayer(model: object)
                layer.addSublayer(candleLayer)
            }
            if highMax == mo.high {
                highIndex = i
            } else if lowMin == mo.low {
                lowIndex = i
            }
        }
        if highIndex > -1  {
            layer.addSublayer(getKlineHighLowIndicatorLayer(obj: array[highIndex], isHigh: true))
        }
        if lowIndex > -1 {
            layer.addSublayer(getKlineHighLowIndicatorLayer(obj: array[lowIndex], isHigh: false))
        }
        self.layer.addSublayer(layer)
    }
    
    func getKlineHighLowIndicatorLayer(obj:NYCandle, isHigh:Bool) ->CATextLayer {
        let text = isHigh ? "\(highMax)" : "\(lowMin)"
        var point = isHigh ? obj.highPoint : obj.lowPoint
        let textSize = theme.getTextSize(text: text)
        if (point.x + textSize.width * 2) > startX + renderWidth {
            point.x = point.x - textSize.width
        }
        return drawTextLayer(frame: CGRect.init(origin: point, size: textSize), text: text, foregroundColor: UIColor.black, backgroundColor: UIColor.lightGray)
    }
    
    /// 获取单个蜡烛图的layer
    fileprivate func getCandleLayer(model: NYCandle) -> HSCAShapeLayer {
        // K线
        let oc = model.openPoint.y - model.closePoint.y
        let candleRect = CGRect(x: (model.openPoint.x - theme.candleWidth / 2.0), y: oc > 0 ? model.closePoint.y : model.openPoint.y, width: theme.candleWidth, height: abs(oc))
        
        let linePath = UIBezierPath(rect: candleRect)
        // 影线
        linePath.move(to: model.lowPoint)
        linePath.addLine(to: model.highPoint)
        
        let klayer = HSCAShapeLayer()
        klayer.path = linePath.cgPath
        klayer.strokeColor = model.candleFillColor.cgColor
        klayer.fillColor = model.candleFillColor.cgColor
        return klayer
    }
    
    /// 画交均线图
    func drawMALayer(array: [NYCandle]) {
        NYChartKey.MA.lineKeys().forEach { (key) in
            let layer = getChartLayer(key)
            drawChartLayerIn(layer: layer, array: array, lines: [key], isSub: false)
        }
    }
    
    /// 画交易量图
    func drawVolumeLayer(array: [NYCandle]) {
        let layer = getChartLayer(NYChartKey.VOL.rawValue)
        layer.sublayers?.removeAll()
        let bars = NYChartKey.VOL.barKey()
        
//        var lines:[[CGPoint]] = []
        
        if bars.count == 2 {
            for object in array.enumerated() {
                let model = object.element
                if !model.isAvailable {
                    continue
                }
//                lines.append([model.getPoint(bars[0]), model.getPoint(bars[1])])
                
                let volLayer = drawLine(lineWidth: theme.candleWidth,
                                        points: [model.getPoint(bars[0]), model.getPoint(bars[1])],
                                        strokeColor: model.candleFillColor,
                                        fillColor: model.candleFillColor)
                layer.addSublayer(volLayer)
            }
        }
//        _ = drawIntermittentLine(lineWidth: theme.candleWidth, lines: lines, strokeColor: model.candleFillColor, layer: layer, fillColor: model.candleFillColor)
        
        self.layer.addSublayer(layer)
    }
    
    /// 画macd图
    func drawMacdLayer(array: [NYCandle]) {
        drawNYChartLayer(chartKay: NYChartKey.MACD, array: array)
        let layer = getChartLayer(NYChartKey.MACD.rawValue)
        let bars = NYChartKey.MACD.barKey()
        if bars.count == 2 {
            for object in array.enumerated() {
                let model = object.element
                if !model.isAvailable {
                    continue
                }
                let p0 = model.getPoint(bars[0])
                let p1 = model.getPoint(bars[1])
                let isUp = (p0.y - p1.y) > 0
                let volLayer = drawLine(lineWidth: theme.candleWidth,
                                        points: [p0, p1],
                                        strokeColor: isUp ? theme.riseColor : theme.fallColor,
                                        fillColor: isUp ? theme.riseColor : UIColor.clear)
                layer.addSublayer(volLayer)
            }
        }
    }
    
    /// 画kdj图
    func drawKDJLayer(array: [NYCandle]) {
        drawNYChartLayer(chartKay: NYChartKey.KDJ, array: array)
    }
    
    func drawCloseLayer(array: [NYCandle]) {
        let layer = getChartLayer(NYChartKey.CLOSE.rawValue)
        layer.sublayers?.removeAll()
        let area = getChartArea(NYChartKey.CLOSE)
        let lineLayer = drawCloseLine(lineWidth: 1,
                      points: array.map({ (item) -> CGPoint in
                        return item.getPoint(NYChartKey.CLOSE.rawValue)
                      }),
                      strokeColor: theme.getLineColor(NYChartKey.CLOSE.rawValue), closeY: area.yMin, gradSize: area.contentSize)
        layer.addSublayer(lineLayer)
        self.layer.addSublayer(layer)
    }
    
    // 活动高亮
    func drawHighLightLayer() {
        if !isHighLight {
            return
        }
        highLightLayer.sublayers?.removeAll()
        let positionModelIndex = highLightIndex - startIndex
        let point = self.positionModels[positionModelIndex]
        let entity = self.dataK[highLightIndex]
        
        let lines = [[CGPoint(x: point.closePoint.x, y: 0), CGPoint(x: point.closePoint.x,  y: self.frame.height)], [CGPoint(x: contentOffsetX, y: point.closePoint.y), CGPoint(x: startX + renderWidth, y: point.closePoint.y)]]

        highLightLayer.addSublayer(drawIntermittentLine(lineWidth: 1, lines: lines, strokeColor: theme.crossLineColor))
        highLightLayer.addSublayer(drawXaxisTimeMark(xPosition: point.closePoint.x, dateString: getTimeStr(entity)))
        
        if highLightLayer.superlayer == nil {
            self.layer.addSublayer(highLightLayer)
        }
        self.drawIndicatorLayer(index: highLightIndex, charts: self.drawLines)
    }
    
    func getTimeStr(_ entity: NYKLineModel) ->String {
        var str = entity.getDate()
        switch kLineType {
        case .kLineForDay, .kLineForWeek, .kLineForMonth:
            str = entity.getDate(format: "yyyy-MM")
        default:
            break
        }
        return str
    }
 
    /// 画线图
    ///
    /// - Parameters:
    ///   - chartKay: 图表类型
    ///   - array: 数据
    func drawNYChartLayer(chartKay: NYChartKey, array: [NYCandle]) {
        let layer = getChartLayer(chartKay.rawValue)
        drawChartLayerIn(layer: layer, array: array, lines: chartKay.lineKeys())
    }
    
    /// 画线
    ///
    /// - Parameters:
    ///   - layer: 画布
    ///   - array: 数据
    ///   - lines: 画线keys
    ///   - isSub: 是否新建layer画线
    ///   - isClear: 是否清除子layer
    
    func drawChartLayerIn(layer: CAShapeLayer, array: [NYCandle], lines: [String] = [], isSub:Bool = true, isClear: Bool = true) {
        if isClear {
            layer.sublayers?.removeAll()
        }
        self.layer.addSublayer(layer)
        for lineKeys in lines {
            let lps = self.getLineLayerPoints(array: array, lineKey: lineKeys)
            if isSub {
                layer.addSublayer(drawIntermittentLine(lineWidth: 1, lines: lps, strokeColor: theme.getLineColor(lineKeys)))
            } else {
                _ = drawIntermittentLine(lineWidth: 1, lines: lps, strokeColor: theme.getLineColor(lineKeys), layer: layer)
            }
        }
    }
    
    /// 获取断续线线各点 (去掉无效点)
    func getLineLayerPoints(array: [NYCandle], lineKey: String, jumpValue: CGFloat? = nil) -> [[CGPoint]] {
        
        var linesPoints: [[CGPoint]] = []
        var moving:Bool = false
        
        for candle in array {
            if !candle.isAvailable {
                moving = false
                continue
            }

            if !moving {
                linesPoints.append([candle.getPoint(lineKey)])
                moving = true
            } else {
                linesPoints[linesPoints.endIndex - 1].append(candle.getPoint(lineKey))
            }
        }
        return linesPoints
    }
}
