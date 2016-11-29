//
//  ViewController.swift
//  CalloutMenu
//
//  Created by 袁超 on 16/7/2.
//  Copyright © 2016年 naonao_YC. All rights reserved.
//

import UIKit
class ViewController: UIViewController,CalloutMenuViewDelegate {
    
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btn5: UIButton!
    
    var callMenuView1: YCCalloutMenuView!
    var callMenuView2: YCCalloutMenuView!
    var callMenuView3: YCCalloutMenuView!
    var callMenuView4: YCCalloutMenuView!
    var callMenuView5: YCCalloutMenuView!
    
    let dir = ArrowDirection.Down
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let txts = ["标题1","title2","subject3"]
        let icons = [UIImage(named:"main-cancell@3x.png")!,UIImage(named:"main-complain@3x.png")!,UIImage(named:"main-cancell@3x.png")!]
        
        callMenuView1 = YCCalloutMenuView.init(invoker:self, control:btn1, delegate:self, txts:txts,icons:icons, direction:ArrowDirection.Up)
        
        callMenuView2 = YCCalloutMenuView.init(invoker:self, control:btn2, delegate:self, txts:txts,icons:nil, direction:ArrowDirection.Right)
        
        callMenuView3 = YCCalloutMenuView.init(invoker:self, control:btn3, delegate:self, txts:txts,icons:icons, direction:ArrowDirection.Right)
        callMenuView3.menuColor = UIColor.blackColor()
        callMenuView3.txtColor = UIColor.whiteColor()
        callMenuView3.padding_right = 50
        callMenuView3.shadowDensity = 0
        
        callMenuView4 = YCCalloutMenuView.init(invoker:self, control:btn4, delegate:self, txts:txts,icons:nil, direction:ArrowDirection.Down)
        callMenuView4.distanceToControl = -5
        
        callMenuView5 = YCCalloutMenuView.init(invoker:self, control:btn5, delegate:self, txts:txts,icons:nil, direction:ArrowDirection.Up)
        callMenuView5.txtFontSize = 20
        callMenuView5.arrowH = 20
        callMenuView5.padding_left = 20
        callMenuView5.padding_right = 50
        
    }
    //btn1点击
    @IBAction func btn1Click() {
        callMenuView1.show()
    }

    @IBAction func btn2Click() {
        callMenuView2.show()
    }

    @IBAction func btn3Click() {
        callMenuView3.show()
    }


    @IBAction func btn4Click() {
        callMenuView4.show()
        
    }
    
    @IBAction func btn5Click() {
        callMenuView5.show()
    }
    
    func calloutMenuView(calloutMenuView:YCCalloutMenuView, selectedIndex index:Int, selectedTitle title:String) {
        print(index)
    }
    
    func separate() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}
}


