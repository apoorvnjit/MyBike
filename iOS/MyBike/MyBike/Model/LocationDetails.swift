//
//  LocationDetails.swift
//  MyBike
//
//  Created by Apoorva Reed(Personal) on 2/21/19.
//  Copyright © 2019 Apoorva Reed(Personal). All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation


class LocationDetails{

    var regionType = "restrict"
    
    func getRegionDetails(urlString: String, map: MKMapView) -> [MKPolygon]{
        var listofpolygons: [MKPolygon] = []
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
                        listofpolygons.append(self.addPolygon(regions: regiondetail, map: map))
                        r_id+=1
                        regiondetail.removeAll()
                    }
                    if(regions.count == count){
                        listofpolygons.append(self.addPolygon(regions: regiondetail, map: map))
                    }
                    count += 1
                    
                }
                
            } catch let jsonErr{
                print("Error: ", jsonErr)
            }
                
            }.resume()
        return listofpolygons
    }
    
    
    func addPolygon(regions: [CLLocation], map: MKMapView)-> MKPolygon{
//        let locations = [CLLocation(latitude: 40.737336, longitude: -74.171002), CLLocation(latitude: 40.735841,longitude: -74.166045), CLLocation(latitude: 40.734361, longitude: -74.166538), CLLocation(latitude: 40.734930,longitude: -74.169434),CLLocation(latitude: 40.735645, longitude: -74.171964)]
        var coordinates = regions.map({(location: CLLocation) -> CLLocationCoordinate2D in return location.coordinate})
        let polygon = MKPolygon(coordinates: &coordinates, count: regions.count)
        map.addOverlay(polygon)
        return polygon
        
    }
    //    func addPolyline(){
    //        let locations = [CLLocation(latitude: 40.737336, longitude: -74.171002), CLLocation(latitude: 40.735841,longitude: -74.166045), CLLocation(latitude: 40.735645, longitude: -74.171964)]
    //        var coordinates = locations.map({(location: CLLocation) -> CLLocationCoordinate2D in return location.coordinate})
    //        let polyline = MKPolyline(coordinates: &coordinates, count: locations.count)
    //        myMap?.addOverlay(polyline)
    ////        let polygon = MKPolygon(coordinates: &coordinates, count: locations.count)
    //    }
}
