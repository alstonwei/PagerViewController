//
//   PagerController.swift
//   Project
//
//  Created by epailive on 17/1/16.
//  Copyright © 2017年 epailive. All rights reserved.
//

import UIKit
import Alamofire
import LLCycleScrollView
import SwiftyJSON
import HandyJSON
import XLPagerTabStrip

private let reuseIdentifier = "Cell"

class PagerController: UIViewController , TabBarDelegate{

    var selectedIndex: Int? = 0 {
        didSet{
            self.reload()
        }
    }
    var selectedViewController: UIViewController? = nil
    var headView: UIView?
    var tabBar: UIView?
    var circleView: LLCycleScrollView?
    var headerHeight: CGFloat = 250.0
    var tabbarHeight: CGFloat = 105.0
    let controlHeight:CGFloat = 25.0
    @IBOutlet public weak var buttonBarView: ButtonBarView!
    var segement:  TabBar?
    
    lazy var containerScrollView: UIScrollView = UIScrollView()
    lazy var contentContainerScrollView: UIScrollView = UIScrollView()
    var pagerControllers: Array<UIViewController> = [] {
        didSet{
            self.reload()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        setupChildViewControllers()
        
        let parrentWidth = self.view.frame.size.width
        headerHeight = parrentWidth/(750.0/324.0) + tabbarHeight - controlHeight
        
       
        
        headView = UIView()
        self.view.addSubview(headView!);
        headView?.frame = CGRect.init(origin: CGPoint(),size: CGSize.init(width: parrentWidth, height: headerHeight));
        headView?.backgroundColor = UIColor.white;
        let circleHeight = headerHeight - tabbarHeight + controlHeight
        circleView = LLCycleScrollView.llCycleScrollViewWithFrame(CGRect.init(origin: CGPoint.init(x: 0, y: 0 ),size: CGSize.init(width: parrentWidth, height: circleHeight)))
        circleView?.autoScroll = true
        circleView?.autoScrollTimeInterval = 2.0
//        // 加载状态图
//        circleView.placeHolderImage = #imageLiteral(resourceName: "s1")
//        // 没有数据时候的封面图
//        circleView.coverImage = #imageLiteral(resourceName: "s2")
//        circleView.customPageControlStyle = .none
        //添加segement
        headView?.addSubview(circleView!)
        let tabbarY = headerHeight - tabbarHeight
        tabBar = UIView()
        tabBar?.backgroundColor = UIColor.clear
        tabBar?.frame = CGRect.init(origin: CGPoint.init(x: 0, y: tabbarY),size: CGSize.init(width: parrentWidth, height: tabbarHeight));
        headView?.addSubview(tabBar!)
        drawPath(view: tabBar!)
        
        segement =  TabBar.init()
        segement?.itemSpacing = 5
        segement?.verticalSpacing = 5
        segement?.itemCornerRedius = 10
        segement?.delegate = self
        segement?.backgroundColor = UIColor.white
        segement?.frame = CGRect.init(origin: CGPoint.init(x: 0, y:  controlHeight+2),size: CGSize.init(width: parrentWidth, height: 78));
        tabBar?.addSubview(segement!);
        updateSelectViewController()
        fetchAds()
    }
    
    /// 更新选中viewcontroler
    func updateSelectViewController() {
        /// 添加当前选中viewcontroller
        let destinationVC = self.pagerControllers[(segement?.selectIndex)!]
        if (selectedViewController == destinationVC) {
            return
        }
        //移除旧的controller
        if(selectedViewController != nil){
            selectedViewController?.willMove(toParentViewController: self)
            removeObserver(scrollView: getScollView(controller: selectedViewController!))
            selectedViewController?.view.removeFromSuperview()
        }
        let parrentWidth = self.view.frame.size.width
        let parrentHeight = self.view.frame.size.height
        destinationVC.view.frame = CGRect.init(origin: CGPoint.init(x: 0, y: 0),size: CGSize.init(width: parrentWidth, height: parrentHeight))
        
        let scrollView = getScollView(controller: destinationVC)
        scrollView.contentInset = UIEdgeInsets.init(top: headerHeight, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets.init(top: headerHeight, left: 0, bottom: 0, right: 0)
        
        self.view.addSubview(destinationVC.view)
        self.view.bringSubview(toFront: headView!)
        destinationVC.didMove(toParentViewController: self)
        
        
        //设置新的选中的controller
        selectedViewController = destinationVC
        addObserver(scrollView: scrollView)
    }
    
    func setupChildViewControllers() {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else { fatalError("Unable to instantiate a guess view controller") }
        self.addChildViewController(controller)
        self.pagerControllers.append(controller)
        
        let controller1 =  PartPreViewVC()
        self.addChildViewController(controller1)
        self.pagerControllers.append(controller1)
        
        guard let controller2 = storyboard?.instantiateViewController(withIdentifier: "categoryVC") as? CategoryVC else { fatalError("Unable to instantiate a guess view controller") }
        self.addChildViewController(controller2)
        self.pagerControllers.append(controller2)
        
    }
    
    /// 加载广告
    func fetchAds()  {
    }
    func drawPath(view: UIView) {
        let w = view.frame.size.width
        let h = view.frame.size.height
        let startPoint = CGPoint.init(x: 0, y: controlHeight);
        let controlPoint = CGPoint.init(x:w*0.5, y: CGFloat(-controlHeight))
        let endPoint = CGPoint.init(x:Int(w), y: Int(controlHeight))
        let path =  UIBezierPath(roundedRect:CGRect.init(origin: CGPoint.init(x: 0, y: controlHeight), size: CGSize.init(width: w, height: h - CGFloat(controlHeight))), byRoundingCorners:[UIRectCorner.topLeft,UIRectCorner.topRight], cornerRadii: CGSize.init(width:0,height:0))
        path.move(to: startPoint)
        path.addQuadCurve(to: endPoint, controlPoint: controlPoint)
        path.close()
        path.lineCapStyle = CGLineCap.round
        path.lineJoinStyle = CGLineJoin.round
        let layer = CAShapeLayer()
        layer.lineWidth = 3
        layer.fillColor = UIColor.white.cgColor
        layer.path = path.cgPath
        layer.shouldRasterize = true
        view.layer.addSublayer(layer)
    }
    func getCurrentScollView() -> UIScrollView {
        return (selectedViewController as!  PagerProtocol)._caculateScrollView()
    }
    func getScollView(controller: UIViewController) -> UIScrollView {
        return (controller as!  PagerProtocol)._caculateScrollView()
    }
     // MARK: - func 
    func reload() {
        
    }

    
    /// 监听scrollview
    func addObserver(scrollView:UIScrollView) {
        scrollView.addObserver(self, forKeyPath: "contentOffset", options:[NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old], context: nil)
        scrollView.willChangeValue(forKey: "contentOffset")
        scrollView.didChangeValue(forKey: "contentOffset")
    }
    
    func removeObserver(scrollView:UIScrollView) {
        scrollView.removeObserver(self, forKeyPath: "contentOffset")
        
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset"{
            let parrentWidth = self.view.frame.size.width
            //let parrentHeight = self.view.frame.size.height
            let scrollView = getCurrentScollView()
            let y = scrollView.contentOffset.y
            print("Y:\(scrollView.contentOffset.y)")
            if y > -headerHeight && y < 0 {
                let headerY = max(-headerHeight,-(headerHeight + y))
                print("headerY:\(headerY)")
                headView?.frame = CGRect.init(origin: CGPoint.init(x: 0, y:headerY),size: CGSize.init(width: parrentWidth, height: headerHeight));
            }
            else if y < -headerHeight {//向下
                headView?.frame = CGRect.init(origin: CGPoint(),size: CGSize.init(width: parrentWidth, height: headerHeight));
            }
            else if y >= 0//上滑 超过边界值
            {
                headView?.frame = CGRect.init(origin: CGPoint.init(x: 0, y:-headerHeight),size: CGSize.init(width: parrentWidth, height: headerHeight));
            }
            print("==================")   
        }
    }
    // MARK: tabBarDelegate
    
    func tabBar(_ tabBar:  TabBar, didSelectItemAt index: Int){
        print("didSelectItemAt")
        updateSelectViewController()
    }
    
    func tabBar(_ tabBar:  TabBar, didDeselectItemAt index: Int){
        
    }
    
    func tabBar(_ tabBar:  TabBar, numberOfItems index: Int) -> Int{
        return self.pagerControllers.count
    }
    
    func tabBar(_ tabBar:  TabBar, titleForItemAt index: Int) -> String{
        
        var ret = ""
        switch index {
        case 0:
            ret = "今日"
        case 1:
            ret = "预展"
        case 2:
            ret = "已成交"
        default:
             ret = "今日"
        }
        return ret
    }
}


protocol PagerProtocol {
    func _caculateScrollView() -> UIScrollView
}



