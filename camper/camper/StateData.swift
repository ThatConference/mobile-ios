//
//  StateData.swift
//  That Conference
//
//  Created by Steven Yang on 4/5/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import Foundation

class StateData {
    static let instance = StateData()
    public var sessionStore: SessionStore! = SessionStore()
    public var offlineFavoriteSessions: Sessions = Sessions()
    public var currentUser: User = User()
    public var camperContacts: [User] = [User()]
    
    private init() {}
    
    private var _statesProvinces: [StateProvincesModel]?
    public func statesProvinces() -> [StateProvincesModel] {
        if (_statesProvinces == nil) {
            loadStatesProvinces()
        }
        
        return _statesProvinces!
    }
    
    private func loadStatesProvinces() {
        _statesProvinces = []
        
        let alabama = StateProvincesModel()
        alabama.name = "Alabama"
        alabama.abbreviation = "AL"
        alabama.country = "US"
        _statesProvinces?.append(alabama)
        
        let alaska = StateProvincesModel()
        alaska.name = "Alaska"
        alaska.abbreviation = "AK"
        alaska.country = "US"
        _statesProvinces?.append(alaska)
        
        let arizona = StateProvincesModel()
        arizona.name = "Arizona"
        arizona.abbreviation = "AZ"
        arizona.country = "US"
        _statesProvinces?.append(arizona)
        
        let arkansas = StateProvincesModel()
        arkansas.name = "Arkansas"
        arkansas.abbreviation = "AR"
        arkansas.country = "US"
        _statesProvinces?.append(arkansas)
        
        let california = StateProvincesModel()
        california.name = "California"
        california.abbreviation = "CA"
        california.country = "US"
        _statesProvinces?.append(california)
        
        let colorado = StateProvincesModel()
        colorado.name = "Colorado"
        colorado.abbreviation = "CO"
        colorado.country = "US"
        _statesProvinces?.append(colorado)
        
        let connecticut = StateProvincesModel()
        connecticut.name = "Connecticut"
        connecticut.abbreviation = "CT"
        connecticut.country = "US"
        _statesProvinces?.append(connecticut)
        
        let delaware = StateProvincesModel()
        delaware.name = "Delaware"
        delaware.abbreviation = "DE"
        delaware.country = "US"
        _statesProvinces?.append(delaware)
        
        let dc = StateProvincesModel()
        dc.name = "District of Columbia"
        dc.abbreviation = "DC"
        dc.country = "US"
        _statesProvinces?.append(dc)
        
        let florida = StateProvincesModel()
        florida.name = "Florida"
        florida.abbreviation = "FL"
        florida.country = "US"
        _statesProvinces?.append(florida)
        
        let georgia = StateProvincesModel()
        georgia.name = "Georgia"
        georgia.abbreviation = "GA"
        georgia.country = "US"
        _statesProvinces?.append(georgia)
        
        let hawaii = StateProvincesModel()
        hawaii.name = "Hawaii"
        hawaii.abbreviation = "HI"
        hawaii.country = "US"
        _statesProvinces?.append(hawaii)
        
        let idaho = StateProvincesModel()
        idaho.name = "Idaho"
        idaho.abbreviation = "ID"
        idaho.country = "US"
        _statesProvinces?.append(idaho)
        
        let illinois = StateProvincesModel()
        illinois.name = "Illinois"
        illinois.abbreviation = "IL"
        illinois.country = "US"
        _statesProvinces?.append(illinois)
        
        let indiana = StateProvincesModel()
        indiana.name = "Indiana"
        indiana.abbreviation = "IN"
        indiana.country = "US"
        _statesProvinces?.append(indiana)
        
        let iowa = StateProvincesModel()
        iowa.name = "Iowa"
        iowa.abbreviation = "IA"
        iowa.country = "US"
        _statesProvinces?.append(iowa)
        
        let kansas = StateProvincesModel()
        kansas.name = "Kansas"
        kansas.abbreviation = "KS"
        kansas.country = "US"
        _statesProvinces?.append(kansas)
        
        let kentucky = StateProvincesModel()
        kentucky.name = "Kentucky"
        kentucky.abbreviation = "KY"
        kentucky.country = "US"
        _statesProvinces?.append(kentucky)
        
        let louisiana = StateProvincesModel()
        louisiana.name = "Louisiana"
        louisiana.abbreviation = "LA"
        louisiana.country = "US"
        _statesProvinces?.append(louisiana)
        
        let maine = StateProvincesModel()
        maine.name = "Maine"
        maine.abbreviation = "ME"
        maine.country = "US"
        _statesProvinces?.append(maine)
        
        let maryland = StateProvincesModel()
        maryland.name = "Maryland"
        maryland.abbreviation = "MD"
        maryland.country = "US"
        _statesProvinces?.append(maryland)
        
        let massachusetts = StateProvincesModel()
        massachusetts.name = "Massachusetts"
        massachusetts.abbreviation = "MA"
        massachusetts.country = "US"
        _statesProvinces?.append(massachusetts)
        
        let michigan = StateProvincesModel()
        michigan.name = "Michigan"
        michigan.abbreviation = "MI"
        michigan.country = "US"
        _statesProvinces?.append(michigan)
        
        let minnesota = StateProvincesModel()
        minnesota.name = "Minnesota"
        minnesota.abbreviation = "MN"
        minnesota.country = "US"
        _statesProvinces?.append(minnesota)
        
        let mississippi = StateProvincesModel()
        mississippi.name = "Mississippi"
        mississippi.abbreviation = "MS"
        mississippi.country = "US"
        _statesProvinces?.append(mississippi)
        
        let missouri = StateProvincesModel()
        missouri.name = "Missouri"
        missouri.abbreviation = "MO"
        missouri.country = "US"
        _statesProvinces?.append(missouri)
        
        let montana = StateProvincesModel()
        montana.name = "Montana"
        montana.abbreviation = "MT"
        montana.country = "US"
        _statesProvinces?.append(montana)
        
        let nebraska = StateProvincesModel()
        nebraska.name = "Nebraska"
        nebraska.abbreviation = "NE"
        nebraska.country = "US"
        _statesProvinces?.append(nebraska)
        
        let nevada = StateProvincesModel()
        nevada.name = "Nevada"
        nevada.abbreviation = "NV"
        nevada.country = "US"
        _statesProvinces?.append(nevada)
        
        let newHampshire = StateProvincesModel()
        newHampshire.name = "New Hampshire"
        newHampshire.abbreviation = "NH"
        newHampshire.country = "US"
        _statesProvinces?.append(newHampshire)
        
        let newJersey = StateProvincesModel()
        newJersey.name = "New Jersey"
        newJersey.abbreviation = "NJ"
        newJersey.country = "US"
        _statesProvinces?.append(newJersey)
        
        let newMexico = StateProvincesModel()
        newMexico.name = "New Mexico"
        newMexico.abbreviation = "NM"
        newMexico.country = "US"
        _statesProvinces?.append(newMexico)
        
        let newYork = StateProvincesModel()
        newYork.name = "New York"
        newYork.abbreviation = "NY"
        newYork.country = "US"
        _statesProvinces?.append(newYork)
        
        let northCarolina = StateProvincesModel()
        northCarolina.name = "North Carolina"
        northCarolina.abbreviation = "NC"
        northCarolina.country = "US"
        _statesProvinces?.append(northCarolina)
        
        let northDakota = StateProvincesModel()
        northDakota.name = "North Dakota"
        northDakota.abbreviation = "ND"
        northDakota.country = "US"
        _statesProvinces?.append(northDakota)
        
        let ohio = StateProvincesModel()
        ohio.name = "Ohio"
        ohio.abbreviation = "OH"
        ohio.country = "US"
        _statesProvinces?.append(ohio)
        
        let oklahoma = StateProvincesModel()
        oklahoma.name = "Oklahoma"
        oklahoma.abbreviation = "OK"
        oklahoma.country = "US"
        _statesProvinces?.append(oklahoma)
        
        let oregon = StateProvincesModel()
        oregon.name = "Oregon"
        oregon.abbreviation = "OR"
        oregon.country = "US"
        _statesProvinces?.append(oregon)
        
        let pennsylvania = StateProvincesModel()
        pennsylvania.name = "Pennsylvania"
        pennsylvania.abbreviation = "PA"
        pennsylvania.country = "US"
        _statesProvinces?.append(pennsylvania)
        
        let rhodeIsland = StateProvincesModel()
        rhodeIsland.name = "Rhode Island"
        rhodeIsland.abbreviation = "RI"
        rhodeIsland.country = "US"
        _statesProvinces?.append(rhodeIsland)
        
        let southCarolina = StateProvincesModel()
        southCarolina.name = "South Carolina"
        southCarolina.abbreviation = "SC"
        southCarolina.country = "US"
        _statesProvinces?.append(southCarolina)
        
        let southDakota = StateProvincesModel()
        southDakota.name = "South Dakota"
        southDakota.abbreviation = "SD"
        southDakota.country = "US"
        _statesProvinces?.append(southDakota)
        
        let tennessee = StateProvincesModel()
        tennessee.name = "Tennessee"
        tennessee.abbreviation = "TN"
        tennessee.country = "US"
        _statesProvinces?.append(tennessee)
        
        let texas = StateProvincesModel()
        texas.name = "Texas"
        texas.abbreviation = "TX"
        texas.country = "US"
        _statesProvinces?.append(texas)
        
        let utah = StateProvincesModel()
        utah.name = "Utah"
        utah.abbreviation = "UT"
        utah.country = "US"
        _statesProvinces?.append(utah)
        
        let vermont = StateProvincesModel()
        vermont.name = "Vermont"
        vermont.abbreviation = "VT"
        vermont.country = "US"
        _statesProvinces?.append(vermont)
        
        let virginia = StateProvincesModel()
        virginia.name = "Virginia"
        virginia.abbreviation = "VA"
        virginia.country = "US"
        _statesProvinces?.append(virginia)
        
        let washington = StateProvincesModel()
        washington.name = "Washington"
        washington.abbreviation = "WA"
        washington.country = "US"
        _statesProvinces?.append(washington)
        
        let westVirginia = StateProvincesModel()
        westVirginia.name = "West Virginia"
        westVirginia.abbreviation = "WV"
        westVirginia.country = "US"
        _statesProvinces?.append(westVirginia)
        
        let wisconsin = StateProvincesModel()
        wisconsin.name = "Wisconsin"
        wisconsin.abbreviation = "WI"
        wisconsin.country = "US"
        _statesProvinces?.append(wisconsin)
        
        let wyoming = StateProvincesModel()
        wyoming.name = "Wyoming"
        wyoming.abbreviation = "WY"
        wyoming.country = "US"
        _statesProvinces?.append(wyoming)
    }
}
