//
//  ViewController.swift
//  LCDemo_ParellelCalls
//
//  Created by Umang Kathuria on 18/09/19.
//  Copyright © 2019 Umang Kathuria. All rights reserved.
//

import UIKit
import LiquidCore

class ViewController: UIViewController, LCMicroServiceDelegate, LCMicroServiceEventListener {
    var text: UILabel = UILabel()
    var button: UIButton = UIButton(type: .system)
    let responseEvent = "resData"
    let readyEvent = "Ready"
    let requestEvent = "reqNativeParallelCalls"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        createUI()
        print("View DID Load")
    }
    
    
    func createUI() {
        text.textAlignment = .center
        text.text = "Hello World!!"
        text.font = UIFont(name: "Menlo", size: 17)
        self.view.addSubview(text)
        
        button.setTitle("Call JS Layer!", for: .normal)
        button.titleLabel?.font = UIFont(name: "Menlo", size: 17)
        button.addTarget(self, action: #selector(onTouch), for: .touchUpInside)
        self.view.addSubview(button)
        
        self.text.translatesAutoresizingMaskIntoConstraints = false
        self.button.translatesAutoresizingMaskIntoConstraints = false
        
        let top = UILayoutGuide()
        let bottom = UILayoutGuide()
        self.view.addLayoutGuide(top)
        self.view.addLayoutGuide(bottom)
        
        let views = [ "text": text, "button": button, "top":top, "bottom":bottom ]
        let c1 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[text]-|", metrics: nil, views: views)
        let c2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[button]-|", metrics: nil, views: views)
        let c3 = NSLayoutConstraint.constraints(withVisualFormat: "V:|[top]-[text]-[button]-[bottom(==top)]|",
                                                metrics: nil, views: views)
        self.view.addConstraints(c1 + c2 + c3)
    }
    /**
     * onTouch method setting the action on the button click.
     *
     */
    @objc func onTouch(sender:UIButton!) {
        for i in 1...10{
            callAPI()
        }
    }
    
    func callAPI() -> Void {
        print("BUTTON CLICKED")
        let jsFilePath = Bundle.main.path(forResource: "liquid", ofType: "bundle")
        let jsURL = URL.init(fileURLWithPath : jsFilePath!)
        let service = LCMicroService(url: jsURL, delegate: self)
        service?.start()
        print("Service Started")
    }
    
    /**
     * onStart method for adding for adding events to the service.
     *
     */
    func onStart(_ service: LCMicroService) {
        print("inside obnstart added")
        service.addEventListener(self.readyEvent, listener: self)
        service.addEventListener(self.responseEvent, listener: self)
        print("Listeners added")
    }
    /**
     * onEvent method for listening for various events emitted by Shield or JS Layer.
     *
     */
    func onEvent(_ service: LCMicroService, event: String, payload: Any?) {
        if event == self.readyEvent {
            print("Emitting Request....")
            let jsonObj = createJsonObject()
            service.emitString(self.requestEvent, string: jsonObj)
        } else if event == self.responseEvent {
            
            DispatchQueue.main.async {
                print(payload.unsafelyUnwrapped)
            }
        }
    }
    
    /**
     * createJsonObject method returns a json object in string format.
     *
     */
    func createJsonObject() -> String {
        
        let dictionary = ["a0": 0,
                          "a1": 1,
                          "a2": 20,
                          "a3": 3,
                          "a4": 40,
                          "a5": 15,
                          "a6": 6,
                          "a7": 7,
                          "a8": 8,
                          "a9": 9,
                          "a10": 10
            ] as [String : Any]
        let theJSONData = try?  JSONSerialization.data(
            withJSONObject: dictionary,
            options: .prettyPrinted
        )
        let theJSONText = String(data: theJSONData.unsafelyUnwrapped, encoding: .utf8)
        
        return theJSONText!
    }
    
}




