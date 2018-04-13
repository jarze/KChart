//
//  NYLineView.swift
//  KChart
//
//  Created by jarze on 2018/2/28.
//  Copyright © 2018年 jarze. All rights reserved.
//

import UIKit

protocol NYDelegate {
    func loadMore() -> ()
    func highLight(model: NYKLineModel) -> ()
    
    func timeSegmentChange(timeType: NYChartType) -> ()

}

class NYLineView: UIView {

    var segmentMenu: SegmentMenu!

    var delegate:NYDelegate?

    var scrollView: UIScrollView!
    var kLine: NYKLine!
    
    var kLineType: NYChartType!
    var theme = NYLineStyle()
    
    var kLineViewWidth: CGFloat = 0
    
    var enableKVO: Bool = true
    
    var dataK: [NYKLineModel] = []
    
    var loadingView: UIActivityIndicatorView!
    
    var loadingMore: Bool = false {
        didSet {
            self.loadMoreState()
        }
    }
//    var allDataK: [NYKLineModel] = []
    
    func loadMoreState() {
        if loadingMore {
            loadingView.startAnimating()
        } else {
            loadingView.stopAnimating()
        }
        loadingView.isHidden = !loadingMore

    }
    
    public init(frame: CGRect, kLineType: NYChartType) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        scrollView = UIScrollView(frame: CGRect(x:0, y:40, width: frame.width, height:frame.height - 40))
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        //        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .new, context: nil)
        addSubview(scrollView)

        scrollView.delegate = self
//        scrollView.bounces = false
        
        loadingView = UIActivityIndicatorView(frame: CGRect.zero)
        loadingView.isHidden = true
        loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingView.center = CGPoint.init(x:frame.width/2.0, y: frame.height / 2.0)
        addSubview(loadingView)
        
        kLine = NYKLine()
        scrollView.addSubview(kLine)
        
        let pinGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinGestureAction(_:)))
        kLine.addGestureRecognizer(pinGesture)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureAction(_:)))
        kLine.addGestureRecognizer(longPressGesture)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 8) {
            self.kLine.drawLines = [NYChartKey.KLine, NYChartKey.MACD, NYChartKey.MA, NYChartKey.KDJ]
            self.handleKlineData()

        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 16) {
            self.kLine.drawLines = [NYChartKey.CLOSE, NYChartKey.KDJ]
            self.handleKlineData()

        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 24) {
            self.kLine.drawLines = [NYChartKey.CLOSE, NYChartKey.MA, NYChartKey.KDJ]
            self.handleKlineData()

        }
//
//        drawFrameLayer()
        
        
        segmentMenu = SegmentMenu(frame: CGRect(x: 0, y: 0, width: frame.width, height: 40))
        segmentMenu.menuTitleArray = ["分时", "五日", "日K", "周K", "月K", "dx", "fff", "分割", "cdvc", "dcs", "vdv", "cdc", "kmgbk"]
        segmentMenu.delegate = self
        
        self.addSubview(segmentMenu)
    }
    
    func configureView(data: [NYKLineModel]) {
        
        dataK = data
        kLine.dataK = dataK
        
        self.updateKlineViewWidth()
   
//        将 kLine 的右边和scrollview的右边对齐
        let contentOffsetX = kLine.frame.width - scrollView.frame.width
        scrollView.setContentOffset(CGPoint(x: contentOffsetX, y: 0), animated: false)
        kLine.contentOffsetX = scrollView.contentOffset.x
        kLine.drawKLineView()
    }
    
    
    func refreshMoreData(data: [NYKLineModel]) {
        let count: CGFloat = CGFloat(data.count + kLine.startIndex - min(kLine.countOfshowCandle / 2, data.count))
        dataK = data + dataK
        kLine.dataK = dataK
        
        self.updateKlineViewWidth()
        
        let contentOffsetX  = count * theme.candleWidth + (count + 1) * theme.candleGap - 40
        scrollView.setContentOffset(CGPoint(x: max(contentOffsetX, 0), y: 0), animated: false)
//        kLine.contentOffsetX = scrollView.contentOffset.x
//        kLine.drawKLineView()
        loadingMore = false
    }
    
    func handleKlineData(_ intervalGap: Double = 0) {
        guard dataK.count > 2 else {
            return
        }
        
        var interval: Double = intervalGap
        let start = dataK[0].timesTamp
        if interval == 0 {
            interval = dataK[1].timesTamp - dataK[0].timesTamp
        }
        let end = dataK[dataK.endIndex - 1].timesTamp
        let dataCount = Int((end - start) / interval)

        for i in 0 ..< dataCount {
            if Int((dataK[i].timesTamp - start) / interval) == i {
                continue
            } else {
                let mo = NYKLineModel()
                mo.close = dataK[i].close
                mo.high = dataK[i].high
                mo.low = dataK[i].low
                mo.open = dataK[i].open
                mo.isAvailable = false
                mo.timesTamp = Double(i) * interval + start
                dataK.insert(mo, at: i)
            }
        }
        dataK = NYData.calIndicators(ticks: dataK, charts: kLine.drawLines)
        kLine.dataK = dataK
//        kLine.dataK = dataK
    }
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
        scrollView.delegate = nil
        segmentMenu.delegate = nil
    }
    
//    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == #keyPath(UIScrollView.contentOffset) && enableKVO && scrollView.contentOffset.x >= 0 {
////            print("in klineview scrollView?.contentOffset.x " + "\(scrollView.contentOffset.x)")
//
//            // 拖动 ScrollView 时重绘当前显示的 klineview
////            kLine.contentOffsetX = scrollView.contentOffset.x
////            kLine.renderWidth = scrollView.frame.width
////            kLine.drawKLineView()
//
//            //            upFrontView.configureAxis(max: kLine.maxPrice, min: kLine.minPrice, maxVol: kLine.maxVolume)
//        }
//    }
    
    // 捏合缩放扩大操作
    @objc func handlePinGestureAction(_ recognizer: UIPinchGestureRecognizer) {
        
        guard recognizer.numberOfTouches == 2 else {
            enableKVO = true
            scrollView.isScrollEnabled = true
            return
        }
       
        switch recognizer.state {
        case .began:
            enableKVO = false
            scrollView.isScrollEnabled = false
        case .ended, .cancelled, .failed:
            enableKVO = true
            scrollView.isScrollEnabled = true
            return
        default:
            break
        }
        
        let scale = recognizer.scale
        let originScale: CGFloat = 1.0
        let kLineScaleFactor: CGFloat = 0.06
        let kLineScaleBound: CGFloat = 0.03
        
        let diffScale = scale - originScale // 获取缩放倍数
        
        if abs(diffScale) > kLineScaleBound {
            let point1 = recognizer.location(ofTouch: 0, in: self)
            let point2 = recognizer.location(ofTouch: 1, in: self)
            
            let pinCenterX = (point1.x + point2.x) / 2
            let scrollViewPinCenterX = pinCenterX + scrollView.contentOffset.x
            
            // 中心点数据index
            let pinCenterLeftCount = scrollViewPinCenterX / (theme.candleWidth + theme.candleGap)
            
            // 缩放后的candle宽度
            var newCandleWidth = theme.candleWidth * (diffScale > 0 ? (1 + kLineScaleFactor) : (1 - kLineScaleFactor))
            
            newCandleWidth = max(theme.candleMinWidth, min(theme.candleMaxWidth, newCandleWidth))
            
            if (self.theme.candleWidth == newCandleWidth) {
                return
            }
            self.theme.candleWidth = newCandleWidth
            kLine.theme.candleWidth = newCandleWidth
            
            // 更新容纳的总长度
            self.updateKlineViewWidth()
            
            let newPinCenterX = pinCenterLeftCount * theme.candleWidth + (pinCenterLeftCount - 1) * theme.candleGap
            let newOffsetX = newPinCenterX - pinCenterX
            self.scrollView.contentOffset = CGPoint(x: newOffsetX > 0 ? newOffsetX : 0 , y: self.scrollView.contentOffset.y)
            
            kLine.contentOffsetX = scrollView.contentOffset.x
            kLine.drawKLineView()
        }
    }
    
    // 长按操作
    @objc func handleLongPressGestureAction(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let  point = recognizer.location(in: kLine)
            var highLightIndex = Int(point.x / (theme.candleWidth + theme.candleGap))
            var positionModelIndex = highLightIndex - kLine.startIndex
            
            highLightIndex = highLightIndex <= 0 ? 0 : highLightIndex
            positionModelIndex = positionModelIndex <= 0 ? 0 : positionModelIndex
            
            if highLightIndex < kLine.dataK.count && positionModelIndex < kLine.positionModels.count {
                kLine.isHighLight = true
                kLine.highLightIndex = highLightIndex
                let entity = kLine.dataK[highLightIndex]
                delegate?.highLight(model: entity)
            }
        }
        
        if recognizer.state == .ended {
            kLine.isHighLight = false
        }
    }
    
    func updateKlineViewWidth() {
        self.handleKlineData()

        let count: CGFloat = CGFloat(kLine.dataK.count)
        // 总长度
        kLineViewWidth = count * theme.candleWidth + (count + 1) * theme.candleGap
        if kLineViewWidth < self.frame.width {
            kLineViewWidth = self.frame.width
        }
        
        kLine.frame = CGRect(x: 0, y: 0, width: kLineViewWidth, height: scrollView.frame.height)
        scrollView.contentSize = CGSize(width: kLineViewWidth, height: scrollView.bounds.height)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//    // 画边框
//    func drawFrameLayer() {
//        // K线图
//        let uperFramePath = UIBezierPath(rect: self.bounds)
//
//        let uperFrameLayer = CAShapeLayer()
//        uperFrameLayer.lineWidth = 1
//        uperFrameLayer.strokeColor = theme.borderColor.cgColor
//        uperFrameLayer.fillColor = UIColor.clear.cgColor
//        uperFrameLayer.path = uperFramePath.cgPath
//        self.layer.addSublayer(uperFrameLayer)
//    }
}

//
extension NYLineView: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if (enableKVO) {
            kLine.contentOffsetX = scrollView.contentOffset.x
            kLine.renderWidth = scrollView.frame.width
            kLine.drawKLineView()
        }
        
        // MARK: - 用于滑动加载更多 KLine 数据
        if (scrollView.contentOffset.x < -10 && dataK.count > 0 && !loadingMore) {
            loadingMore = true
            delegate?.loadMore()
            print("load more")
        }
    }
}

extension NYLineView: SegmentMenuDelegate {
    func menuButtonDidClick(index: Int) {
        delegate?.timeSegmentChange(timeType: NYChartType.timeLineForDay)
    }
}

