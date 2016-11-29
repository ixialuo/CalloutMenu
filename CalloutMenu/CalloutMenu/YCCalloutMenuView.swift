//
//  CalloutMenuView.swift
//
//  Created by 袁超 on 16/5/15.
//  Copyright © 2016年 codans. All rights reserved.
//

import UIKit

let WIDTH = UIScreen.mainScreen().bounds.width
let HEIGHT = UIScreen.mainScreen().bounds.height

/*＊箭头方向的枚举*/
enum ArrowDirection {
    case Up
    case Down
    case Left
    case Right
}

/*＊协议*/
protocol CalloutMenuViewDelegate: class {
//    .........
    
    func calloutMenuView(calloutMenuView:YCCalloutMenuView, selectedIndex index:Int, selectedTitle title:String)
}

/**弹出菜单*/
class YCCalloutMenuView: UIView,UITableViewDelegate,UITableViewDataSource,CAAnimationDelegate {
    
    //需要外界提供的属性
    
    /**触发控件*/
    var control: UIControl!
    /**控制器*/
    weak var invoker: UIViewController!
    /**文字选项*/
    var txtOptions: [String]! {
        didSet{
            setConfigure()
        }
    }
    /**图片选项*/
    var iconOptions: [UIImage]? {
        didSet{
            if iconOptions == nil || iconOptions?.count == 0 {
                iconMaxW = 0
            }
            setConfigure()
        }
    }
    /**箭头方向*/
    var arrowDirection = ArrowDirection.Up
    /**代理*/
    weak var delegate: CalloutMenuViewDelegate?
    /**菜单背景色*/
    var menuColor: UIColor = UIColor.whiteColor()
    /**文字颜色*/
    var txtColor: UIColor = UIColor.blackColor()
    /**边缘阴影密度，越大越浓密*/
    var shadowDensity: Double = 0.5
    
    //视图安放区域需要的属性
    
    /**距离触发控件的距离*/
    var distanceToControl: CGFloat = 8
    /**距离控制器左边的最小边距*/
    var minMarginToLeft: CGFloat = 16
    /**距离控制器右边的最小边距*/
    var minMarginToRight: CGFloat = 16
    /**距离控制器顶部的最小边距*/
    var minMarginToTop: CGFloat = 16
    /**距离控制器底部的最小边距*/
    var minMarginToBottom: CGFloat = 16
    /**箭头高度*/
    var arrowH: CGFloat = 8.0 {
        didSet{
            setConfigure()
        }
    }
    /**箭头顶角角度*/
    var arrowAngle = CGFloat(M_PI_2){
        didSet{
            setConfigure()
        }
    }

    /**行高*/
    var rowHeight: CGFloat = 30{
        didSet{
            setConfigure()
        }
    }

    /**选中时的颜色*/
    var selctedColor: UIColor = UIColor.grayColor()
    /**左边距*/
    var padding_left: CGFloat = 10 {
        didSet{
            setConfigure()
        }
    }
    /**右边距*/
    var padding_right: CGFloat = 10 {
        didSet{
            setConfigure()
        }
    }
    /**图片与文字间的间距*/
    var padding_iconToTxt: CGFloat = 5 {
        didSet{
            setConfigure()
        }
    }
    
    /**分割线距离左边的宽度*/
    var lineEdgeLeft: CGFloat = 10
    /**分割线距离右边的宽度*/
    var lineEdgeRight: CGFloat = 10
    /**分割线高度*/
    var lineHeight: CGFloat = 0.5
    /**分割线颜色*/
    var lineColor: UIColor = UIColor.grayColor()
    
    /**字体大小*/
    var txtFontSize: CGFloat = WIDTH >= 414 ? 15 : WIDTH >= 375 ? 14 : 13 {
        didSet{
            setConfigure()
        }
    }

    /**图片的最大宽度*/
    var iconMaxW: CGFloat = 0 {
        didSet{
            if iconOptions == nil {
                iconMaxW = 0
                assertionFailure("请先设置图片选项")
            } else {
               setConfigure()
            }
        }
    }
    //文字最大宽度
    private var txtMaxW: CGFloat {
        var w: CGFloat = 0
        for txt in txtOptions {
            w = max((txt as NSString).sizeWithAttributes([NSFontAttributeName:UIFont.systemFontOfSize(txtFontSize)]).width,w)
        }
        return w
    }
    

    //视图宽度
    private var width: CGFloat {
        switch arrowDirection {
        case .Up, .Down:
             return padding_left + iconMaxW + padding_iconToTxt + txtMaxW + padding_right
        default:
             return padding_left + iconMaxW + padding_iconToTxt + txtMaxW + padding_right + arrowH
        }
       
    }
    //视图高度
    private var height: CGFloat {
        switch arrowDirection {
        case .Up, .Down:
            return CGFloat(txtOptions.count)*rowHeight+arrowH
        default:
            return CGFloat(txtOptions.count)*rowHeight
        }
    }
    
    private var coverView: UIView!  //底部蒙层
    
    //显示选项内容的表视图
    private var tableView: UITableView!
    
    //外界初始化方法
    init(invoker:UIViewController, control:UIControl, delegate:CalloutMenuViewDelegate?, txts:[String],icons:[UIImage]?, direction:ArrowDirection) {
        
        super.init(frame: CGRectZero)
        backgroundColor = UIColor.clearColor()
        
        self.invoker = invoker
        self.control = control
        self.delegate = delegate
        self.txtOptions = txts
        self.iconOptions = icons
        self.arrowDirection = direction
        
        //设置图片的宽度
        iconMaxW = icons == nil ? 0 : 14
        
        initCoverView()
        
        initTableView()
        
        setConfigure()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - 设置
    private func setConfigure() {
        frame.size = CGSizeMake(width, height)
        tableView.frame = CGRectMake(0, 0, width, height)
    }

    
    /**需要正确展示该视图时外界需调用的方法*/
    func show() {
        invoker.view.addSubview(coverView)
        UIView.animateWithDuration(0.2, animations: {
            self.coverView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        })
        
        invoker.view.addSubview(self)
        let anim = CABasicAnimation(keyPath: "transform.scale")
        anim.fromValue = 0
        anim.toValue = 1
        anim.duration = 0.2
        anim.repeatCount = 1
        anim.removedOnCompletion = false
        anim.fillMode = kCAFillModeForwards
        anim.delegate = self
        layer.addAnimation(anim, forKey: "scaleFromSmallToBig")
    }
    
    /**
     该视图需要动画消失时需调用的方法
     */
    @objc private func dismiss() {
        
        let anim = CABasicAnimation(keyPath: "transform.scale")
        anim.toValue = 0
        anim.duration = 0.2
        anim.repeatCount = 1
        anim.removedOnCompletion = false
        anim.fillMode = kCAFillModeForwards
        anim.delegate = self
        layer.addAnimation(anim, forKey: "scaleFromBigToSmall")
        
        UIView.animateWithDuration(0.2, animations: {
            self.coverView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
        }) { (b) in
            self.coverView.removeFromSuperview()
        }
    }
    
    /**
     动画结束
     
     - parameter anim: 动画实例
     - parameter flag: 动画完成的标识
     */
    func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if anim == layer.animationForKey("scaleFromBigToSmall") {
            removeFromSuperview()
        }
    }
    
    /**
     初始化蒙层
     
     - returns: Void
     */
    private func initCoverView() {
        coverView = UIView(frame: UIScreen.mainScreen().bounds)
        coverView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
        coverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    
    //初始化表视图
    private func initTableView() {
        let tableViewFrm = CGRectMake(0, 0, width, height)
        tableView = UITableView.init(frame: tableViewFrm, style: .Plain)
        
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.layer.cornerRadius = 10.0/3
        
        tableView.registerClass(customCell.self, forCellReuseIdentifier: "cell")
        
        tableView.separatorStyle = .None
        
        addSubview(tableView)
        
    }
    
    //重绘
    override func drawRect(rect: CGRect) {
        
        let controlFrm = control.convertRect(control.bounds, toView: invoker.view)
        var partOfRect = CGRectZero   //矩形部分
        var arrowPoint0 = CGPointZero //顶点0
        var arrowPoint1 = CGPointZero //顶点1
        var arrowPoint2 = CGPointZero //顶点2
        
        //根据箭头方向绘图
        switch arrowDirection {
        case .Up:
            partOfRect = CGRectMake(0, arrowH, rect.width, rect.height-arrowH)
            if controlFrm.origin.x + controlFrm.width/2 < minMarginToLeft + width/2 {
                arrowPoint0.x = controlFrm.origin.x + controlFrm.width/2 - minMarginToLeft
                frame.origin = CGPointMake(minMarginToLeft, controlFrm.origin.y+controlFrm.height+distanceToControl)
            } else if WIDTH - controlFrm.origin.x - controlFrm.width/2 < width/2 + minMarginToRight {
                arrowPoint0.x = controlFrm.origin.x + controlFrm.width/2 - (WIDTH - minMarginToRight - width)
                frame.origin = CGPointMake(WIDTH-minMarginToRight-width, controlFrm.origin.y+controlFrm.height+distanceToControl)
            } else {
                arrowPoint0.x = width/2
                frame.origin = CGPointMake(controlFrm.origin.x+controlFrm.width/2-width/2, controlFrm.origin.y+controlFrm.height+distanceToControl)
            }
            tableView.frame = CGRectMake(0, arrowH, width, height-arrowH)
            arrowPoint1.x = arrowPoint0.x - arrowH*tan(arrowAngle/2)
            arrowPoint1.y = arrowH
            arrowPoint2.x = arrowPoint0.x + arrowH*tan(arrowAngle/2)
            arrowPoint2.y = arrowH
            //调整layer的position与anchorPoint
            layer.position = CGPointMake(frame.origin.x+width*(arrowPoint0.x/width), frame.origin.y)
            layer.anchorPoint = CGPointMake(arrowPoint0.x/width, 0)
        case .Down:
            partOfRect = CGRectMake(0, 0, rect.width, rect.height-arrowH)
            if controlFrm.origin.x + controlFrm.width/2 < minMarginToLeft + width/2 {
                arrowPoint0.x = controlFrm.origin.x + controlFrm.width/2 - minMarginToLeft
                frame.origin = CGPointMake(minMarginToLeft, controlFrm.origin.y-rect.height-distanceToControl)
            } else if WIDTH - controlFrm.origin.x - controlFrm.width/2 < width/2 + minMarginToRight {
                arrowPoint0.x = controlFrm.origin.x + controlFrm.width/2 - (WIDTH - minMarginToRight - width)
                frame.origin = CGPointMake(WIDTH-minMarginToRight-width, controlFrm.origin.y-rect.height-distanceToControl)
            } else {
                arrowPoint0.x = width/2
                frame.origin = CGPointMake(controlFrm.origin.x+controlFrm.width/2-width/2, controlFrm.origin.y-rect.height-distanceToControl)
            }
            tableView.frame = CGRectMake(0, 0, width, height-arrowH)
            arrowPoint0.y = rect.height
            arrowPoint1.x = arrowPoint0.x - arrowH*tan(arrowAngle/2)
            arrowPoint1.y = rect.height-arrowH
            arrowPoint2.x = arrowPoint0.x + arrowH*tan(arrowAngle/2)
            arrowPoint2.y = rect.height-arrowH
            //调整layer的position与anchorPoint
            layer.position = CGPointMake(frame.origin.x+width*(arrowPoint0.x/width), frame.origin.y+height)
            layer.anchorPoint = CGPointMake(arrowPoint0.x/width, 1)

        case .Left:
            partOfRect = CGRectMake(0, 0, width-arrowH, height)
            if controlFrm.origin.y + controlFrm.height/2 < minMarginToTop + height/2 {
                arrowPoint0.y = controlFrm.origin.y + controlFrm.height/2 - minMarginToTop
                frame.origin = CGPointMake(controlFrm.origin.x+controlFrm.width+distanceToControl, minMarginToTop)
            } else if HEIGHT - controlFrm.origin.y - controlFrm.height/2 < height/2 + minMarginToBottom {
                arrowPoint0.y = controlFrm.origin.y + controlFrm.height/2 - (HEIGHT - minMarginToBottom - height)
                frame.origin = CGPointMake(controlFrm.origin.x+controlFrm.width+distanceToControl, HEIGHT-height-minMarginToBottom)
            } else {
                arrowPoint0.y = height/2
                frame.origin = CGPointMake(controlFrm.origin.x+controlFrm.width+distanceToControl, controlFrm.origin.y+controlFrm.height/2-height/2)
            }
            tableView.frame = CGRectMake(arrowH, 0, width-arrowH, height)
            arrowPoint1.x = arrowH
            arrowPoint1.y = arrowPoint0.y - arrowH*tan(arrowAngle/2)
            arrowPoint2.x = arrowH
            arrowPoint2.y = arrowPoint0.y + arrowH*tan(arrowAngle/2)
            //调整layer的position与anchorPoint
            layer.position = CGPointMake(frame.origin.x, frame.origin.y+height*(arrowPoint0.y/height))
            layer.anchorPoint = CGPointMake(0, arrowPoint0.y/height)

        case .Right:
            partOfRect = CGRectMake(0, 0, width-arrowH, height)
            if controlFrm.origin.y + controlFrm.height/2 < minMarginToTop + height/2 {
                arrowPoint0.y = controlFrm.origin.y + controlFrm.height/2 - minMarginToTop
                frame.origin = CGPointMake(controlFrm.origin.x-width-distanceToControl, minMarginToTop)
            } else if HEIGHT - controlFrm.origin.y - controlFrm.height/2 < height/2 + minMarginToBottom {
                arrowPoint0.y = controlFrm.origin.y + controlFrm.height/2 - (HEIGHT - minMarginToBottom - height)
                frame.origin = CGPointMake(controlFrm.origin.x-width-distanceToControl, HEIGHT-height-minMarginToBottom)
            } else {
                arrowPoint0.y = height/2
                frame.origin = CGPointMake(controlFrm.origin.x-width-distanceToControl, controlFrm.origin.y+controlFrm.height/2-height/2)
            }
            tableView.frame = CGRectMake(0, 0, width-arrowH, height)
            arrowPoint0.x = width
            arrowPoint1.x = width - arrowH
            arrowPoint1.y = arrowPoint0.y - arrowH*tan(arrowAngle/2)
            arrowPoint2.x = width - arrowH
            arrowPoint2.y = arrowPoint0.y + arrowH*tan(arrowAngle/2)
            //调整layer的position与anchorPoint
            layer.position = CGPointMake(frame.origin.x+width, frame.origin.y+arrowPoint0.y)
            layer.anchorPoint = CGPointMake(1, arrowPoint0.y/height)
        }
        
        
        //绘圆角矩形
        let path = UIBezierPath(roundedRect: partOfRect, cornerRadius: 10.0/3)
        menuColor.setFill()
        path.fill()
        
        //绘三角形箭头
        let path1 = UIBezierPath()
        path1.moveToPoint(arrowPoint0)
        path1.addLineToPoint(arrowPoint1)
        path1.addLineToPoint(arrowPoint2)
        path1.closePath()
        menuColor.setFill()
        path1.fill()
        
        //设置阴影
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = Float(shadowDensity)
        layer.shadowOffset = CGSizeMake(0.0, 0.0)
        
        tableView.backgroundColor = menuColor
    }
    
    
    //MARK: - tableView delegate dataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return txtOptions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! customCell
        cell.setStyle(padding_left,padding_right,padding_iconToTxt,iconMaxW,txtMaxW,txtFontSize)
        if iconOptions?.count > indexPath.row {
            cell.setIcon(iconOptions![indexPath.row])
        }
        cell.setTxt(txtOptions[indexPath.row],color:txtColor)
        cell.backgroundColor = menuColor
        if indexPath.row == txtOptions.count - 1 {
            cell.divLine.hidden = true
        } else {
            cell.divLine.hidden = false
            cell.setLineStyle(lineEdgeLeft, lineEdgeRight, lineHeight, lineColor)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.calloutMenuView(self, selectedIndex: indexPath.row, selectedTitle: txtOptions[indexPath.row])
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.2*Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.dismiss()
            tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        }
        
    }
    
}

//MARK: 自定义单元格
class customCell: UITableViewCell {
    
    var imageV: UIImageView!
    var label: UILabel!
    var divLine: UIImageView!
    
    var padding_left: CGFloat = 10 //左边距
    var padding_right: CGFloat = 10  //右边距
    var padding_iconToTxt: CGFloat = 5 //图片与文字间的间距
    var iconMaxW: CGFloat = 14  //图片的最大宽度
    var txtMaxW: CGFloat = 0    //文字最大宽度
    var txtFontSize: CGFloat = WIDTH >= 414 ? 15 : WIDTH >= 375 ? 14 : 13

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imageV = UIImageView(frame: CGRectZero)
        addSubview(imageV)
        label = UILabel(frame: CGRectZero)
        //label.textColor = UIColor.init(rgba: "#646464")
        addSubview(label)
        
        divLine = UIImageView(frame: CGRectMake(padding_left, frame.height-0.5, frame.width-padding_left-padding_right, 0.5))
        //divLine.backgroundColor = UIColor(rgba: "#e1e1e1")
        addSubview(divLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setStyle(padding_left:CGFloat,_ padding_right:CGFloat,_ padding_iconToTxt:CGFloat,_ iconMaxW:CGFloat,_ txtMaxW:CGFloat,_ txtFontSize:CGFloat) {
        self.padding_left = padding_left
        self.padding_right = padding_right
        self.padding_iconToTxt = padding_iconToTxt
        self.iconMaxW = iconMaxW
        self.txtMaxW = txtMaxW
        self.txtFontSize = txtFontSize
    }
    
    func setIcon(icon:UIImage) {
        imageV?.image = icon
    }
    
    //根据内容调整布局
    func setTxt(txt:String,color:UIColor) {
        label.text = txt
        if let img = imageV.image {
            let p = img.size.width/img.size.height
            let h = iconMaxW / p
            imageV.frame = CGRectMake(padding_left, 0, iconMaxW, h)
            
            imageV.center.y = contentView.center.y
            label.frame = CGRectMake(imageV.frame.origin.x+iconMaxW+padding_iconToTxt, 0, txtMaxW, frame.height)
            label.textAlignment = .Left
        } else {
            label.frame = CGRectMake(padding_left, 0, txtMaxW, frame.height)
            label.center.y = contentView.center.y
            label.textAlignment = .Center
        }
        label.textColor = color
        label.font = UIFont.systemFontOfSize(txtFontSize)
    }
    
    //设置分割线样式
    func setLineStyle(l:CGFloat,_ r:CGFloat,_ h:CGFloat,_ color:UIColor) {
        divLine.frame = CGRectMake(l, frame.height-h, frame.width-l-r, h)
        divLine.backgroundColor = color
    }
    
}

