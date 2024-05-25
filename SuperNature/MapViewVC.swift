

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewVC: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate{
    
    @IBOutlet weak var MapView: MKMapView!
    var locationManager = CLLocationManager()
    var chosenLocationlongtitude = Double()
    var chosenLocationlatititude = Double()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span =  MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: location, span: span)
        MapView.setRegion(region, animated: true)
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer: )))
        gestureRecognizer.minimumPressDuration = 2
        MapView.addGestureRecognizer(gestureRecognizer)
        
    }
    @objc func chooseLocation(gestureRecognizer:UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            
            let tocuhedPoint = gestureRecognizer.location(in: self.MapView)
            let touchedCordinates = self.MapView.convert(tocuhedPoint, toCoordinateFrom: self.MapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCordinates
            annotation.title = "Chosen Location"
            annotation.subtitle = "Subtitle"
            self.MapView.addAnnotation(annotation)
            chosenLocationlatititude = touchedCordinates.latitude
            chosenLocationlongtitude = touchedCordinates.longitude
            
            
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("AppDelegate could not be retrieved")
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        
        if let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context) as? Places {
            
            newPlace.latitude = chosenLocationlatititude
            newPlace.longitude = chosenLocationlongtitude
            
            
            do {
                try context.save()
                print("Saved successfully")
            } catch {
                print("Error saving context: \(error)")
            }
        } else {
            print("Failed to create new Place object")
        }
    }
    
    
    
    
    
}













func getCoreData () {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest <NSFetchRequestResult> (entityName: "Places")
    request.returnsObjectsAsFaults = false
    do {
        let results = try context.fetch(request)
        if results.count > 0 {
            for result in results as! [NSManagedObject] {
                if var latitudeCore = result.value(forKey: "latitude") as? Double {
                    
                    
                    
                }
                if var longitudeCore = result.value(forKey: "longitude") as? Double {
                    
                    
                }
                
                
            }
            
            
        }
    }
    catch {
        
    }
    
}








