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
import Firebase

class ShareContactViewController: BaseViewControllerNoCameraViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shareButton: RoundedButton!
    
    var localBeaconUUID = "1d44ddec-0ad8-4e1e-abab-1de93b948f88"
    
    var localBeaconMajor: CLBeaconMajorValue = StateData.instance.currentUser.int16BAuxId
    
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!

    var locationManager: CLLocationManager = CLLocationManager()
    var isBroadcasting = false
    
    let conditionRef = Database.database().reference().child("contact-sharing")

    var userAuxArray: [UserAuxiliaryModel] = []
    var contactsDict: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        print("[NOT STARTED]")
        
        setUpLocation()
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        stopLocalBroadcast()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func shareContactButtonPressed(_ sender: RoundedButton) {
        //
        //        let params: [String: Dictionary<String, Int>] = ["requests": ["asfe-sdfgre-vdfv": Date().dateToInt()], "blocks": ["asfe-sdfgre-vdfv": Date().dateToInt()]]
        //
        //        conditionRef.child(StateData.instance.currentUser.id).setValue(params)
    }
    
    func setUpLocation() {
        
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
        return userAuxArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ShareContactCell") as? ShareContactTableViewCell {
            let user = userAuxArray[indexPath.row]
            cell.setUpCell(userAux: user)
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

extension ShareContactViewController: CBPeripheralManagerDelegate {
    func initLocalBeacon() {
        if localBeacon != nil {
            stopLocalBeacon()
        }
        
        let uuid = UUID(uuidString: localBeaconUUID)!
        localBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, identifier: "That App")
        
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
                    startIndicator()
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
    
    func stopScanning() {
        let uuid = UUID(uuidString: localBeaconUUID)!
        
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "That App")
        
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            var beaconArray: [Int] = []
            var count = 0
            
            for beacon in beacons {
                if beacon.major != NSNumber(value: StateData.instance.currentUser.int16BAuxId) {
                    if (!beaconArray.contains(Int(beacon.major))) {
                        beaconArray.append(Int(beacon.major))
                    } else {
                        count += 1
                    }
                    
                    if (count == 10) {
                        break
                    }
                }
            }
            
            stopScanning()
            loadContacts(auxIdArray: beaconArray) {
                self.stopIndicator()
            }
        } else {
            self.simpleAlert(title: "Unable to find local contacts", body: "Please try again.")
        }
    }
    
    func loadContacts(auxIdArray: [Int], completed: @escaping () -> ()) {
        let contactAPI = ContactAPI()
        contactAPI.getAuxUsers(auxIdArray: auxIdArray) { (result) in
            switch (result) {
            case .success(let result):
                self.userAuxArray = result
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                break
            case .failure(let error):
                self.userAuxArray = []
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                print(error)
                break
            }
        }
        
        completed()
    }
    
    func updateDistance(distance: CLProximity, major: NSNumber) {
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .unknown:
                print("UNKNOWN")
            case .far:
                print("FAR (\(major))")
            case .near:
                print("NEAR (\(major))")
            case .immediate:
                print("IMMEDIATE (\(major))")
            }
        }
    }
}
