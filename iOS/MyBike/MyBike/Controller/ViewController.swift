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
import Alamofire
import SwiftyJSON
import UserNotifications


struct locationdetail: Decodable {
    let end_lat : String
    let start_lat : String
    let biketype : String
    let start_long : String
    let starttime : String
    let end_long : String
    let Distance : String
    let orderid : String
    let userid : String
    let bikeid : String
}

struct regiondetails: Decodable {
    let id : String
    let r_name : String
    let r_id : String
    let r_cor_id : String
    let r_lat : String
    let r_long : String
    let r_type : String
}

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    let BIKEDETAILS_URL = "http://54.144.157.152/getdata.php"
    let REGIONDETAILS_URL = "http://54.144.157.152/getregiondetails.php"
    //var regionType = "restrict"
    //let locationdata = LocationDetails()
    var listofPolygons: [MKPolygon] = []
    var listofPermitPolygons: [MKPolygon] = []
    var regionType = "restrict"
    var bikeType: Int = 1
    
    @IBAction func locateMe(_ sender: Any) {
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            myMap.setRegion(viewRegion, animated: true)
            myMap.showsUserLocation = true
            
            deleteAnnotation()
            getBikeLocationDetails(urlString: BIKEDETAILS_URL)
            //getRegionDetails(urlString: REGIONDETAILS_URL)
        }
        
    }

    @IBOutlet weak var myMap: MKMapView!
    
    var locationManager = CLLocationManager()

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //displaying the ios local notification when app is in foreground
        completionHandler([.alert, .badge, .sound])
        completionHandler(UNNotificationPresentationOptions.sound)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // #1.1 - Create "the notification's category value--its type."
        let alertRestrictedAreaNotification = UNNotificationCategory(identifier: "RestrictedAreaEntered", actions: [], intentIdentifiers: [], options: [])
        let alertPermittedAreaNotification = UNNotificationCategory(identifier: "PermittedAreaEntered", actions: [], intentIdentifiers: [], options: [])
        // #1.2 - Register the notification type.
        UNUserNotificationCenter.current().setNotificationCategories([alertRestrictedAreaNotification])
        UNUserNotificationCenter.current().setNotificationCategories([alertPermittedAreaNotification])
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Notifications permission granted.")
            }
            else {
                print("Notifications permission denied because: \(String(describing: error?.localizedDescription)).")
            }
        }
        
        
        
        // Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        
        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            myMap.setRegion(viewRegion, animated: false)
            //myMap.showsUserLocation = true
        }
        
        self.locationManager = locationManager
        self.locationManager.startUpdatingLocation()
        listofPolygons = getRegionDetails(urlString: REGIONDETAILS_URL,map: myMap)
        
//        listofPolygons = locationdata.getRegionDetails(urlString: REGIONDETAILS_URL,map: myMap)
        
//        checkPositioninsidePolygon(listPolygon: locationdata.getRegionDetails(urlString: REGIONDETAILS_URL,map: myMap))
    }
    func showPermittNotification(){
        // find out what are the user's notification preferences
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            
            // we're only going to create and schedule a notification
            // if the user has kept notifications authorized for this app
            guard settings.authorizationStatus == .authorized else { return }
            
            // create the content and style for the local notification
            let content = UNMutableNotificationContent()
            
            // #2.1 - "Assign a value to this property that matches the identifier
            // property of one of the UNNotificationCategory objects you
            // previously registered with your app."
            content.categoryIdentifier = "PermittedAreaEntered"
            
            // create the notification's content to be presented
            // to the user
            content.title = "Alert"
            content.subtitle = "You have entered a parking zone"
            content.body = "You can park your bike in this green zone"
            content.sound = UNNotificationSound.default
            
            // #2.2 - create a "trigger condition that causes a notification
            // to be delivered after the specified amount of time elapses";
            // deliver after 10 seconds
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            
            // create a "request to schedule a local notification, which
            // includes the content of the notification and the trigger conditions for delivery"
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            
            // "Upon calling this method, the system begins tracking the
            // trigger conditions associated with your request. When the
            // trigger condition is met, the system delivers your notification."
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
        } // end getNotificationSettings
    }
    func showRestrictNotification(){
        // find out what are the user's notification preferences
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            
            // we're only going to create and schedule a notification
            // if the user has kept notifications authorized for this app
            guard settings.authorizationStatus == .authorized else { return }
            
            // create the content and style for the local notification
            let content = UNMutableNotificationContent()
            
            // #2.1 - "Assign a value to this property that matches the identifier
            // property of one of the UNNotificationCategory objects you
            // previously registered with your app."
            content.categoryIdentifier = "RestrictedAreaEntered"
            
            // create the notification's content to be presented
            // to the user
            content.title = "Alert"
            content.subtitle = "You have entered no parking zone"
            content.body = "You cannot park your bike in this restricted zone"
            content.sound = UNNotificationSound.default
            
            // #2.2 - create a "trigger condition that causes a notification
            // to be delivered after the specified amount of time elapses";
            // deliver after 10 seconds
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            
            // create a "request to schedule a local notification, which
            // includes the content of the notification and the trigger conditions for delivery"
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            
            // "Upon calling this method, the system begins tracking the
            // trigger conditions associated with your request. When the
            // trigger condition is met, the system delivers your notification."
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
        } // end getNotificationSettings
    }
    func checkPositioninsidePolygon(listPolygon: [MKPolygon], lat: Double, long: Double){
        
        for child in listPolygon{
            let polygonRenderer = MKPolygonRenderer(polygon: child)
            let mapPoint: MKMapPoint = MKMapPoint((CLLocation(latitude: lat, longitude: long)).coordinate)
            //let mapPoint: MKMapPoint = MKMapPoint((CLLocation(latitude: 40.737336, longitude: -74.171002)).coordinate)
            let polygonViewPoint: CGPoint = polygonRenderer.point(for: mapPoint)
            if polygonRenderer.path.contains(polygonViewPoint) {
                print("Your location was inside your polygon.")
                showRestrictNotification()
                
                let alert = UIAlertController(title: "Restricted area", message: "You are not allowed to park bike in this zone", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                        
                        
                    }}))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
    }
    func checkPositioninsidePermitPolygon(listPolygon: [MKPolygon], lat: Double, long: Double){
        
        for child in listPolygon{
            let polygonRenderer = MKPolygonRenderer(polygon: child)
            let mapPoint: MKMapPoint = MKMapPoint((CLLocation(latitude: lat, longitude: long)).coordinate)
            //let mapPoint: MKMapPoint = MKMapPoint((CLLocation(latitude: 40.737336, longitude: -74.171002)).coordinate)
            let polygonViewPoint: CGPoint = polygonRenderer.point(for: mapPoint)
            if polygonRenderer.path.contains(polygonViewPoint) {
                print("Your location was inside your polygon.")
                showPermittNotification()
                
                let alert = UIAlertController(title: "Permitted area", message: "You are allowed to park bike in this zone", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                        
                        
                    }}))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
    }
    
    func deleteAnnotation(){
        let allAnnotations = self.myMap.annotations
        self.myMap.removeAnnotations(allAnnotations)
        
    }
    func checkUserAuthorization() -> Bool{
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()

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

        
        myMap.delegate = self
        myMap.showsUserLocation = true
        myMap.mapType = MKMapType(rawValue: 0)!
        let locValue:CLLocationCoordinate2D = (manager.location?.coordinate)!
        getBikeLocationDetails(urlString: BIKEDETAILS_URL)
        checkPositioninsidePolygon(listPolygon: listofPolygons, lat: locValue.latitude, long: locValue.longitude)
        checkPositioninsidePermitPolygon(listPolygon: listofPermitPolygons, lat: locValue.latitude, long: locValue.longitude)

    }
    
    
    func getBikeLocationDetails(urlString: String){
        
        // get bike details from the db
        guard let url = URL(string: urlString) else {
            return
        }
        URLSession.shared.dataTask(with: url){(data, response, err) in
            
            guard let data = data else {return}
            do{
                let locations = try JSONDecoder().decode([locationdetail].self, from: data)
                
                //print(data)
                var locationcoordinate : CLLocationCoordinate2D
                //print(locations)
                for child in locations{
                    locationcoordinate = CLLocationCoordinate2D(latitude: Double(child.end_lat)!, longitude: Double(child.end_long)!)
                    
                   // print(locationcoordinate)
//                    print(child.biketype)
                    self.addAnnotation(coordinate: locationcoordinate, title: child.bikeid, subtitle: child.biketype)
                }
                
            } catch let jsonErr{
                print("Error: ", jsonErr)
            }
            
        }.resume()
    }
    
    func getRegionDetails(urlString: String, map: MKMapView) -> [MKPolygon]{
        let listofpolygons: [MKPolygon] = []
        // get bike details from the db
        guard let url = URL(string: urlString) else {
            return listofpolygons
        }
        URLSession.shared.dataTask(with: url){(data, response, err) in
            
            guard let data = data else {return}
            do{
                let regions = try JSONDecoder().decode([regiondetails].self, from: data)
                
                //print(regions)
                var r_id:Int = 1
                var count = 1
                var regiondetail:[CLLocation] = []
                for child in regions{
                    if(Int(child.r_id) == r_id){
                        regiondetail.append(CLLocation(latitude: Double(child.r_lat)!, longitude: Double(child.r_long)!))
                        self.regionType = child.r_type
                    }else{
                        if(child.r_type == "restrict"){
                            self.listofPolygons.append(self.addPolygon(regions: regiondetail, map: map))
                        }else if (child.r_type == "permit"){
                            self.listofPermitPolygons.append(self.addPolygon(regions: regiondetail, map: map))
                        }
                        
                        print(regiondetail)
                        print("\n")
                        r_id+=1
                        regiondetail.removeAll()
                        regiondetail.append(CLLocation(latitude: Double(child.r_lat)!, longitude: Double(child.r_long)!))
                    }
                    if(regions.count == count){
                        print(regiondetail)
                        if(child.r_type == "restrict"){
                            self.listofPolygons.append(self.addPolygon(regions: regiondetail, map: map))
                        }else if (child.r_type == "permit"){
                            self.listofPermitPolygons.append(self.addPolygon(regions: regiondetail, map: map))
                        }
                    }
                    count += 1
                    
                }
                
            } catch let jsonErr{
                print("Error: ", jsonErr)
            }
            //self.checkPositioninsidePolygon(listPolygon: self.listofPolygons)
            }.resume()
        return listofpolygons
    }
    
    func updateAnnotation(json: JSON){
        //deletenotation()
        //addAnnotation(coordinate: <#T##CLLocationCoordinate2D#>, title: <#T##String#>, subtitle: <#T##String#>)
    }
    

    
    

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 3
        return renderer
        
        } else if overlay is MKPolygon {
        let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
            if(regionType=="restrict"){
                renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
                
            }else if(regionType=="permit"){
                renderer.fillColor = UIColor.green.withAlphaComponent(0.5)
            }
        
       // renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 2
        return renderer
    }
        
       return MKOverlayRenderer()
    }
    
    func addAnnotation(coordinate: CLLocationCoordinate2D, title: String, subtitle: String){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        annotation.subtitle = subtitle
        bikeType = Int(subtitle)!
        myMap.addAnnotation(annotation)
    }
   
    func addPolygon(regions: [CLLocation], map: MKMapView)-> MKPolygon{
        //        let locations = [CLLocation(latitude: 40.737336, longitude: -74.171002), CLLocation(latitude: 40.735841,longitude: -74.166045), CLLocation(latitude: 40.734361, longitude: -74.166538), CLLocation(latitude: 40.734930,longitude: -74.169434),CLLocation(latitude: 40.735645, longitude: -74.171964)]
        var coordinates = regions.map({(location: CLLocation) -> CLLocationCoordinate2D in return location.coordinate})
        let polygon = MKPolygon(coordinates: &coordinates, count: regions.count)
        map.addOverlay(polygon)
        return polygon
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        if annotation is MKUserLocation {
            return nil
        }else {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: restorationIdentifier)
            annotationView.canShowCallout = true
            var pinImage: UIImage = UIImage(named: "bikeType1")!
            
            if (annotation.subtitle=="2"){
                pinImage = UIImage(named: "bikeType2")!
            }
            
            
            let size = CGSize(width: 50, height: 50)
            UIGraphicsBeginImageContext(size)
            pinImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            
            annotationView.image = resizedImage
            
            return annotationView
        }
        
    }
    
    
}

