//
//  ViewController.swift
//  BeaconPOC
//
//  Created by Matthew Ridley on 5/18/17.
//  Copyright © 2017 Milk Can. All rights reserved.
//

import CoreBluetooth
import CoreLocation
import UIKit

class ViewController: UIViewController {
    let localBeaconUUID = "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"
    let localBeaconMajor: CLBeaconMajorValue = 2
    let localBeaconMinor: CLBeaconMinorValue = 2 //MAKE THIS THE USER ID!

    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    var locationManager: CLLocationManager!
    
    var isBroadcasting = false

    @IBOutlet weak var beaconId: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.beaconId.text = "[NOT STARTED]"
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        if !self.isBroadcasting {
            self.initLocalBeacon()
        }
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        if self.isBroadcasting {
            self.stopLocalBeacon()
        }
    }
}

extension ViewController: CBPeripheralManagerDelegate {
    func initLocalBeacon() {
        if localBeacon != nil {
            stopLocalBeacon()
        }
        
        let uuid = UUID(uuidString: localBeaconUUID)!
        localBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: "That App")
        self.beaconId.text = uuid.uuidString
        
        beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        
        self.isBroadcasting = true
    }
    
    func stopLocalBeacon() {
        peripheralManager.stopAdvertising()
        peripheralManager = nil
        beaconPeripheralData = nil
        localBeacon = nil
        
        self.isBroadcasting = false
        self.beaconId.text = "[NOT STARTED]"
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as! [String: AnyObject]!)
        } else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: localBeaconUUID)!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "That App")
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            for beacon in beacons {
                updateDistance(distance: beacon.proximity, minor: beacon.minor)
            }
        } else {
            updateDistance(distance: .unknown, minor: 0)
        }
    }
    
    func updateDistance(distance: CLProximity, minor: NSNumber) {
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .unknown:
                self.view.backgroundColor = UIColor.gray
                print("UNKNOWN")
            case .far:
                self.view.backgroundColor = UIColor.blue
                print("FAR (\(minor))")
            case .near:
                self.view.backgroundColor = UIColor.orange
                print("NEAR (\(minor))")
            case .immediate:
                self.view.backgroundColor = UIColor.red
                print("IMMEDIATE (\(minor))")
            }
        }
    }
}
