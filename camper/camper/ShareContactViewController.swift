//
//  ShareContactViewController.swift
//  That Conference
//
//  Created by Steven Yang on 7/5/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import CoreBluetooth
import CoreLocation
import UIKit

class ShareContactViewController: UIViewController {
    var localBeaconUUID = StateData.instance.currentUser.id!
    let localBeaconMajor: CLBeaconMajorValue = 2
    let localBeaconMinor: CLBeaconMinorValue = 2 //MAKE THIS THE USER ID!
    
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    var locationManager: CLLocationManager!
    
    var isBroadcasting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("[NOT STARTED]")
        
        setUpLocation()
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setUpLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        let status = CLLocationManager.authorizationStatus()
        
        if status == .denied || status == .restricted {
            let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            return
        }
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            print("Authorized")
            startLocalBroadcast()
        }
    }
    
    func startLocalBroadcast() {
        if !self.isBroadcasting {
            self.initLocalBeacon()
        }
    }
    
    func stopLocalBroadcast() {
        if self.isBroadcasting {
            self.stopLocalBeacon()
        }
    }

}

extension ShareContactViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ShareContactCell") as? ShareContactTableViewCell {
            return cell
        }
        
        return UITableViewCell()
    }
}

extension ShareContactViewController: CBPeripheralManagerDelegate {
    func initLocalBeacon() {
        if localBeacon != nil {
            stopLocalBeacon()
        }
        
        let uuid = UUID(uuidString: localBeaconUUID)!
        localBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: "That App")
        print(uuid.uuidString)
        
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
        print("[NOT STARTED]")
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as! [String: AnyObject]!)
        } else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
        }
    }
}

extension ShareContactViewController: CLLocationManagerDelegate {
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
                print("UNKNOWN")
            case .far:
                print("FAR (\(minor))")
            case .near:
                print("NEAR (\(minor))")
            case .immediate:
                print("IMMEDIATE (\(minor))")
            }
        }
    }
}

extension Data {
    
    public var hexString: String {
        var str = ""
        enumerateBytes { (buffer, index, stop) in
            for byte in buffer {
                str.append(String(format: "%02X", byte))
            }
        }
        return str
    }
}
