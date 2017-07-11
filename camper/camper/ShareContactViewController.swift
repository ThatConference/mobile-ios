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

class ShareContactViewController: UIViewController {
    
    var localBeaconUUID = "1d44ddec-0ad8-4e1e-abab-1de93b948f88"
    let localBeaconMajor: CLBeaconMajorValue = 123
    let localBeaconMinor: CLBeaconMinorValue = 456 //MAKE THIS THE USER ID!
    
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    var discoveredPeripheral: CBPeripheral?
    var locationManager: CLLocationManager = CLLocationManager()
    var centralManager: CBCentralManager!
    
    var isBroadcasting = false
    
    var detectedBeacons = [CLBeacon]()
    
    var contactsArray: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("[NOT STARTED]")
        
        setUpLocation()
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        stopLocalBroadcast()
        self.dismiss(animated: true, completion: nil)
    }
    
    func setUpLocation() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
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
            cell.selectionStyle = .none
            // Call stop here
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            if (indexPathForSelectedRow == indexPath) {
                tableView.deselectRow(at: indexPath, animated: false)
                return nil
            }
        }
        return indexPath
    }
}

extension ShareContactViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            return
        }
        
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (RSSI.intValue > -15 || RSSI.intValue < -35) {
            return // With those RSSI values, probably not an iBeacon.
        }
        
        if peripheral != discoveredPeripheral {
            discoveredPeripheral = peripheral // Need to retain a reference to connect to the beacon.
            centralManager.connect(peripheral, options: nil)
            central.stopScan() // No need to scan anymore, we found it.
        }
    }
}

extension ShareContactViewController: CBPeripheralManagerDelegate {
    func initLocalBeacon() {
        if localBeacon != nil {
            stopLocalBeacon()
        }
        
        let uuid = UUID(uuidString: localBeaconUUID)!
        localBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: "That App")
        
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
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        discoveredPeripheral = nil
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        guard error == nil else {
            return
        }
        
        if let services = peripheral.services {
            for service in services {
                print("PIE")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        guard error == nil else {
            return
        }
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid.uuidString == "1d44ddec-0ad8-4e1e-abab-1de93b948f88" { // UUID
                    peripheral.readValue(for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard error == nil else {
            return;
        }
        
        if let value = characteristic.value {
            // value will be a Data object with bits that represent the UUID you're looking for.
            print("Found beacon UUID: \(value.hexString)")
            // This is where you can start the CLBeaconRegion and start monitoring it, or just get the value you need.
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
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: "That App")
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            for beacon in beacons {
//                updateDistance(distance: beacon.proximity, minor: beacon.minor)
                print("\(beacon.proximityUUID)")
                print("\(beacon.major)")
                print("\(beacon.minor)")
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
