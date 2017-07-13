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
    
    var loadinView: UIView!
    
    var localBeaconUUID = "1d44ddec-0ad8-4e1e-abab-1de93b948f88"
    
    var localBeaconMajor: CLBeaconMajorValue = StateData.instance.currentUser.int16BAuxId
    
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!

    var locationManager: CLLocationManager = CLLocationManager()
    var isBroadcasting = false
    
    let conditionRef = Database.database().reference().child("contact-sharing")
    let blockRef = Database.database().reference().child("contact-sharing").child(StateData.instance.currentUser.id).child("blocks")
    let requestRef = Database.database().reference().child("contact-sharing").child(StateData.instance.currentUser.id).child("requests")

    var userAuxArray: [UserAuxiliaryModel] = []
    var requestDict: [String: Dictionary<Int, Int>] = [:]
    var selectedAuxDict: Dictionary<String, Int> = [:]
    var beaconArray: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpLocation()
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        stopLocalBroadcast()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func shareContactButtonPressed(_ sender: RoundedButton) {

        if (selectedAuxDict.isEmpty) {
            simpleAlert(title: "No contact has been selected", body: "Please try again")
        } else {
            saveContacts {
                self.requestRef.observeSingleEvent(of: .value, with: { (snapShot) in
                    if let snapShotValue = snapShot.value as? Dictionary<String, Int> {
                        
                        print(snapShotValue)
                    }
                })
            }
        }
    }
    
    func setUpLocation() {
        loadingScreen()

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
            stopScanning()
            self.stopLocalBeacon()
        }
    }
    
    
    func saveContacts(completed: @escaping () -> ()) {
        for selectedID in selectedAuxDict {
            requestRef.child(selectedID.key).setValue(selectedID.value)
        }
        completed()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ShareContactTableViewCell {
            if let userAux = cell.userAux {
                selectedAuxDict[userAux.int16BAuxId.uInt16ToInt().intToString()] = Date().dateToInt()
            }
        }
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
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ShareContactTableViewCell {
            if let userAux = cell.userAux {
                self.selectedAuxDict.removeValue(forKey: userAux.int16BAuxId.uInt16ToInt().intToString())
            }
        }
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
    
    // Fix Scanning
    
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
            for beacon in beacons {
                if beacon.major != NSNumber(value: StateData.instance.currentUser.int16BAuxId) {
                    conditionRef.child(StateData.instance.currentUser.id).observeSingleEvent(of: .value, with: { (snapShot) in
                        if !(snapShot.hasChild(String(describing: beacon.major))) {
                            if !(self.beaconArray.contains(Int(beacon.major))) {
                                self.beaconArray.append(Int(beacon.major))
                                self.loadContacts(auxIdArray: [(Int(beacon.major))])
                                if (self.loadingView.isHidden == false) {
                                    self.hideLoadingScreen()
                                }
                            }
                        }
                    })
//                    checkDistance(distance: beacon.proximity, major: beacon.major)
                }
            }
            
        } else {
            self.simpleAlert(title: "Unable to find local contacts", body: "Please try again.")
        }
    }
    
    func loadContacts(auxIdArray: [Int]) {
        startIndicator()
        let contactAPI = ContactAPI()
        contactAPI.getAuxUsers(auxIdArray: auxIdArray) { (result) in
            switch (result) {
            case .success(let result):
                self.userAuxArray.append(contentsOf: result)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.stopIndicator()
                }
                break
            case .failure(let error):
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.stopIndicator()
                }
                print(error)
                break
            }
        }
    }
    
    func checkDistance(distance: CLProximity, major: NSNumber) {
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .unknown:
                print("UNKNOWN")
            case .far:
                if (self.beaconArray.contains(Int(major))) {
                    
                    for x in 0..<self.beaconArray.count {
                        if self.beaconArray[x] == Int(major) {
                            
                            self.beaconArray.remove(at: x)
                        }
                    }
                    
                    for x in 0..<self.userAuxArray.count {
                        if (major == NSNumber(value: self.userAuxArray[x].int16BAuxId)) {
                            
                            self.userAuxArray.remove(at: x)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            case .near:
                if !(self.beaconArray.contains(Int(major))) {
                    self.beaconArray.append(Int(major))
                    self.loadContacts(auxIdArray: [(Int(major))])
                }
            case .immediate:
                if !(self.beaconArray.contains(Int(major))) {
                    self.beaconArray.append(Int(major))
                    self.loadContacts(auxIdArray: [(Int(major))])
                }
            }
        }
    }
}
