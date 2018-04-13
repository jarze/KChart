//
//  ViewController.swift
//  KChart
//
//  Created by jarze on 2018/2/27.
//  Copyright © 2018年 jarze. All rights reserved.
//

import UIKit
import SwiftyJSON

public let ScreenWidth = UIScreen.main.bounds.width
public let ScreenHeight = UIScreen.main.bounds.height

class ViewController: UIViewController {
    
    var stockChartView:NYLineView!
    
    var segmentMenu: SegmentMenu!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.test()
        self.setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func test() {
        let jsonFile = "kLineF"
        let allDataK = getKLineData(getJsonDataFromFile(jsonFile))
        let tmpDataK = Array(allDataK)

        self.stockChartView = NYLineView(frame: CGRect.init(x: 0, y: ScreenWidth, width: ScreenWidth, height: 200), kLineType: .kLineForDay)
        self.view.addSubview(stockChartView!)
        
        stockChartView?.configureView(data: tmpDataK)
        stockChartView?.delegate = self
    }
    
    
    func setUpView() {
        segmentMenu = SegmentMenu(frame: CGRect(x: 0, y: 88/*headerStockInfoView.frame.maxY*/, width: ScreenWidth, height: 40))
        segmentMenu.menuTitleArray = ["分时", "五日", "日K", "周K", "月K", "dx", "fff", "分割", "cdvc", "dcs", "vdv", "cdc", "kmgbk"]
        segmentMenu.delegate = self
        
        //        stockBriefView = HSStockBriefView(frame: CGRect(x: 0, y: headerStockInfoView.frame.maxY, width: self.view.frame.width, height: 40))
        //        stockBriefView?.isHidden = true
        //
        //        kLineBriefView = HSKLineBriefView(frame: CGRect(x: 0, y: headerStockInfoView.frame.maxY, width: self.view.frame.width, height: 40))
        //        kLineBriefView?.isHidden = true
        //
        self.view.addSubview(segmentMenu)
        //        self.view.addSubview(stockBriefView!)
        //        self.view.addSubview(kLineBriefView!)
    }
    
    
    func getKLineData(_ json: JSON) -> [NYKLineModel] {
        var models = [NYKLineModel]()
        
        for (_, jsonData): (String, JSON) in json["data"]["data"] {
            let model = NYKLineModel()
            model.open = CGFloat(Double(jsonData[0].doubleValue))
            model.close = CGFloat(jsonData[1].doubleValue)
            model.high = CGFloat(jsonData[2].doubleValue)
            model.low = CGFloat(jsonData[3].doubleValue)
            model.volume = CGFloat(jsonData[4].doubleValue)
            model.timesTamp = jsonData[5].doubleValue
            models.append(model)
        }
        return models
    }
    
    func getJsonDataFromFile(_ fileName: String) -> JSON {
        let pathForResource = Bundle.main.path(forResource: fileName, ofType: "json")
        let content = try! String(contentsOfFile: pathForResource!, encoding: String.Encoding.utf8)
        let jsonContent = content.data(using: String.Encoding.utf8)!
        
        do {
            return try JSON(data: jsonContent)
            
        } catch {
            return JSON()
        }
    }
    
//    func initView() {
//        let stockChartView = HSKLineView(frame: CGRect.init(x: 0, y: 0, width: 300, height: 200), kLineType: .kLineForDay)
//        self.view.addSubview(stockChartView)
//        let jsonFile = "kLineForDay"
//        let allDataK = getKLineModelArray(getJsonDataFromFile(jsonFile))
//        let tmpDataK = Array(allDataK[allDataK.count-70..<allDataK.count])
//
//        stockChartView.configureView(data: tmpDataK)
//        self.view.addSubview(stockChartView)
//
//    }
    
    func getKLineModelArray(_ json: JSON) -> [NYKLineModel] {
        var models = [NYKLineModel]()
        for (_, jsonData): (String, JSON) in json["chartlist"] {
            let model = NYKLineModel()
//            model.date = Date.hschart.toDate(jsonData["time"].stringValue, format: "EEE MMM d HH:mm:ss z yyyy").hschart.toString("yyyyMMddHHmmss")
            model.open = CGFloat(jsonData["open"].doubleValue)
            model.close = CGFloat(jsonData["close"].doubleValue)
            model.high = CGFloat(jsonData["high"].doubleValue)
            model.low = CGFloat(jsonData["low"].doubleValue)
            model.volume = CGFloat(jsonData["volume"].doubleValue)
//            model.ma5 = CGFloat(jsonData["ma5"].doubleValue)
//            model.ma10 = CGFloat(jsonData["ma10"].doubleValue)
//            model.ma20 = CGFloat(jsonData["ma20"].doubleValue)
////            model.ma30 = CGFloat(jsonData["ma30"].doubleValue)
//            model.diff = CGFloat(jsonData["dif"].doubleValue)
//            model.dea = CGFloat(jsonData["dea"].doubleValue)
//            model.macd = CGFloat(jsonData["macd"].doubleValue)
//            model.rate = CGFloat(jsonData["percent"].doubleValue)
            models.append(model)
        }
        return models
    }
}


extension ViewController:NYDelegate {
    func loadMore() {
        print("-------loadMore")
        
        let jsonFile = "kLineF"
        let allDataK = getKLineData(getJsonDataFromFile(jsonFile))
        let tmpDataK = Array(allDataK[40...80])
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4) {
            self.stockChartView?.refreshMoreData(data: tmpDataK)
        }
    }
    
    func highLight(model: NYKLineModel) {
        print("---hightLight-----", model.high)
    }
    
    func timeSegmentChange(timeType: NYChartType) {
        print("\(timeType.rawValue)")
        let jsonFile = "kLineF"

        let allDataK = getKLineData(getJsonDataFromFile(jsonFile))
        let tmpDataK = Array(allDataK[0...80])
        stockChartView.configureView(data: tmpDataK)
    }
}

// MARK: - SegmentMenuDelegate

extension ViewController: SegmentMenuDelegate {
    func menuButtonDidClick(index: Int) {
        print("------\(index)")
        let jsonFile = "kLineF"
        let allDataK = getKLineData(getJsonDataFromFile(jsonFile))
        let tmpDataK = Array(allDataK[index...80])
        stockChartView.configureView(data: tmpDataK)
    }
}
