//
//  ViewController.swift
//  MyBike
//
//  Created by Apoorva Reed(Personal) on 2/5/19.
//  Copyright © 2019 Apoorva Reed(Personal). All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var myMap: MKMapView!
    
    var locationManager = CLLocationManager()
//    mapView.delegate = self
//    var mapV = MKMapView()
//    var mapView = MKMapViewDelegate()
    override func viewDidLoad() {
        super.viewDidLoad()
        if checkUserAuthorization(){
            locationManager.startUpdatingLocation()
        }
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    func checkUserAuthorization() -> Bool{
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()

        if CLLocationManager.locationServicesEnabled(){
            switch CLLocationManager.authorizationStatus(){
            case .authorizedAlways:
                print("Access granted")
                return true
            case .notDetermined, .restricted, .denied, .authorizedWhenInUse :
                print("Access not granted for always")
                return false
            }
        }else{
            print("Access not granted")
            return false
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let location:CLLocationCoordinate2D = manager.location!.coordinate
//        let latitude = location.latitude
//        let longitude = location.longitude
//        let latDelta:CLLocationDegrees = 0.1
//        let longDelta:CLLocationDegrees = 0.1
//        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
//        let maplocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
//        let region:MKCoordinateRegion = MKCoordinateRegion(center: maplocation, span: span)
//        myMap.setRegion(region, animated: true)
//
        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.myMap.setRegion(region, animated: true)
        }
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let annotation = MKPointAnnotation()
        annotation.coordinate = locValue
        annotation.title = "Bike"
        annotation.subtitle = "current location"
        self.myMap.addAnnotation(annotation)
        //stop updating location, only need user location once to position map.
        manager.stopUpdatingLocation()
    }
    
    func setMapRegion(){
//        var getUserLocation: MKUserLocation{
//
//        }
        
//        init(center centerCoordinate: CLLocationCoordinate2D,
//        latitudinalMeters: CLLocationDistance,
//        longitudinalMeters: CLLocationDistance)
    }

}

