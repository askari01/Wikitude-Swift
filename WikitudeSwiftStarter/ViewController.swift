//
//  ViewController.swift
//  WikitudeSwiftStarter
//
//  Created by alexwasner on 5/26/16.
//  Copyright © 2016 alexwasner. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion


class ViewController: UIViewController, WTArchitectViewDelegate, CLLocationManagerDelegate{
    fileprivate var architectView:WTArchitectView?
    fileprivate var architectWorldNavigation:WTNavigation?
    


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // test
        var locationManager = CLLocationManager()
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        print (locationManager.location!)
        
        let manager = CMMotionManager()
        
        if manager.isAccelerometerAvailable {
            manager.accelerometerUpdateInterval = 0.01
            manager.startAccelerometerUpdates(to: OperationQueue.main) {
                [weak self] (data: CMAccelerometerData?, error: Error?) in
                if let acceleration = data?.acceleration {
                    let rotation = atan2(acceleration.x, acceleration.y) - M_PI
                    print (rotation)
                }
            }
        }
        // end test
        
        do {
            try WTArchitectView.isDeviceSupported(forRequiredFeatures: WTFeatures._2DTracking)
            architectView = WTArchitectView(frame: self.view.frame)
            architectView?.delegate = self
            architectView?.setLicenseKey("qByvLCLFn+zWbd/q+hLw6bB1O8ZAFxL8/x5gm/SyBy12uXgjB/d1AMXqsJKu5bS3zprcAa9r8+01xjF5IDD66fmBkjzB2eeA/F1gCbXSu8JOgsWHHNIM/nghjIUF2Vi6YTyBmg14nLwW4oEP4+/SQ1i40DoSQIYHzIzgh5vP9IJTYWx0ZWRfX4LR4ZVqtTgyXTbFGRLrE0uNwZ0JaWwD5XJcWYw01DdRzIjFOF2QcYnT8lw4jJMlzF3KubwtcE8IVJJivuVZHeMF5b+yUCgRTnSST4e9+cIGBk62075QEiK99AgkWd8ncl++xKOvOi9UcFFQFKT8eoV9e8r9rfVBucjKQkAklm1zUz1/riwmKUcW90PIzZi4WPawCgZAi8/tDRptNCFRBQdoep9d1wIIbvusXxZodAt6+gQJVaKmoZOBsQzGHaK5AsryRTm7VBBGOyeViNrTnZSAp6qo5y47p0W+1Hnvx4+tgGaoTc3o0QtM3qvMWXm5BLiGcMJFjI922y939cEAF3Db3VJ4T97gU35DbvnKkS2IFV3S35FxuNh047GboOBAAm0n00v0x8AapFQ5wXxH+WsxgbhP3OLR7sKsmheUk1eRcHqnHHuMGAb4ul+cbRoIgdTIPVo8ZrzyefZJqzwR5JOlc4gd47aFUCvRyDel4vO2oWD2S4q8HrQ=")
            //broken on purpose so it will not compile until  you add your Wikitude license

            
            self.architectView?.loadArchitectWorld(from: Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "Web"), withRequiredFeatures: ._2DTracking)
            self.view.addSubview(architectView!)
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: OperationQueue.main, using: {(notification) in
                    DispatchQueue.main.async(execute: {
                        if self.architectWorldNavigation?.wasInterrupted == true{
                            self.architectView?.reloadArchitectWorld()
                        }
                        self.startWikitudeSDKRendering()
                    })
                })
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil, queue: OperationQueue.main, using: {(notification) in
                DispatchQueue.main.async(execute: {
                    self.stopWikitudeSDKRendering()
                })
            })
            
                
        } catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    func startWikitudeSDKRendering(){
        if self.architectView?.isRunning == false{
            self.architectView?.start({ configuration in
                    configuration?.captureDevicePosition = AVCaptureDevicePosition.back
                }, completion: {isRunning, error in
                    if !isRunning{
                        print("WTArchitectView could not be started. Reason: \(error?.localizedDescription)")
                    }
            })
        }
    }
    
    func stopWikitudeSDKRendering(){
        if self.architectView?.isRunning == true{
            self.architectView?.stop()
        }

    }
    func architectView(_ architectView: WTArchitectView!, invokedURL URL: Foundation.URL!) {
        //do shit here
        
//        - (void)architectView:(WTArchitectView *)architectView invokedURL:(NSURL *)URL
//        {
//            NSDictionary *parameters = [URL URLParameter];
//            if ( parameters )
//            {
//                if ( [[URL absoluteString] hasPrefix:@"architectsdk://button"] )
//                {
//                    NSString *action = [parameters objectForKey:@"action"];
//                    if ( [action isEqualToString:@"captureScreen"] )
//                    {
//                        [self captureScreen];
//                    }
//                }
//                else if ( [[URL absoluteString] hasPrefix:@"architectsdk://markerselected"])
//                {
//                    [self presentPoiDetails:parameters];
//                }
//            }
//        }
    }
    

    func architectView(_ architectView: WTArchitectView!, didFinishLoadArchitectWorldNavigation navigation: WTNavigation!) {
        //    /* Architect World did finish loading */
    }
    func architectView(_ architectView: WTArchitectView!, didFailToLoadArchitectWorldNavigation navigation: WTNavigation!, withError error: NSError!) {
        print("Architect World from URL \(navigation.originalURL) could not be loaded. Reason: \(error.localizedDescription)");
    }
    func architectView(_ architectView: WTArchitectView!, didEncounterInternalError error: NSError!) {
        print("WTArchitectView encountered an internal error \(error.localizedDescription)");
    }
}
