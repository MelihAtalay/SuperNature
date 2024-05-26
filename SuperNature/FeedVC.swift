

import UIKit
import Firebase
import SDWebImage
import Foundation

var userEmailArray = [String] ()

var likeArray = [Int] ()
var userImageArray = [String] ()
var userCommentArray = [String] ()
var dateArray  = [String ]()
var IdArray = [String]()
var cityNames = [String]()
var countryNames = [String]()
var longitudeArray = [Double] ()
var latitudeArray  = [Double] ()
var selectedId = String()
var selectedRowIndex: Int?
var useruidarray = [String]()
var nameArray = [String]()
var surnameArray = [String]()
var profileURLArray = [String]()




class FeedVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    
    
    @IBAction func SeeTheComments(_ sender: Any) {
        if let selectedRow = selectedRowIndex {
            selectedId = IdArray[selectedRow]
            
            performSegue(withIdentifier: "goComments", sender: nil)
        } else {
            print("No cell is selected.")
        }
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goComments" {
            if let selectedId = sender as? String {
                
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRowIndex = indexPath.row
        
        
    }
    
    
    
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (hideKeyboard))
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        
        backgroundImageView.addGestureRecognizer(gestureRecognizer)
        
        
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        getDataFromFirestore()
        
        
        
        
        
        
        
        
        
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userCommentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
               
               if indexPath.row < nameArray.count && indexPath.row < surnameArray.count {
                   cell.emailLabel.text = "\(nameArray[indexPath.row]) \(surnameArray[indexPath.row])"
               }
               
               if indexPath.row < userCommentArray.count {
                   cell.commentLabel.text = userCommentArray[indexPath.row]
               }
               
               if indexPath.row < userImageArray.count {
                   cell.imageViewInCell.sd_setImage(with: URL(string: userImageArray[indexPath.row]))
               }
               
               if indexPath.row < countryNames.count && indexPath.row < cityNames.count {
                   cell.LocationLabel.text = "\(countryNames[indexPath.row]), \(cityNames[indexPath.row])"
               }
               
               if indexPath.row < IdArray.count {
                   cell.IdLabel.text = IdArray[indexPath.row]
               }
               
               if indexPath.row < likeArray.count {
                   cell.likeCounter.text = String(likeArray[indexPath.row])
               }
               
               if indexPath.row < profileURLArray.count {
                   cell.proiflepic.sd_setImage(with: URL(string: profileURLArray[indexPath.row]))
               }

               return cell
    }
    
    
    
    
    
    
    
    
    @objc func hideKeyboard () {
        view.endEditing(true)
    }
    
    func getDataFromFirestore (){
        let fireStoreDatabase = Firestore.firestore()
        
        
        fireStoreDatabase.collection("Posts").order(by: "postdate", descending: true).addSnapshotListener { (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Error")
            } else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    
                    userImageArray.removeAll(keepingCapacity: false)
                    userEmailArray.removeAll(keepingCapacity: false)
                    userCommentArray.removeAll(keepingCapacity: false)
                    likeArray.removeAll(keepingCapacity: false)
                    IdArray.removeAll(keepingCapacity: false)
                    cityNames.removeAll(keepingCapacity: false)
                    countryNames.removeAll(keepingCapacity: false)
                    longitudeArray.removeAll(keepingCapacity: false)
                    latitudeArray.removeAll(keepingCapacity: false)
                    useruidarray.removeAll(keepingCapacity: false)
                    nameArray.removeAll(keepingCapacity: false)
                    surnameArray.removeAll(keepingCapacity: false)
                    profileURLArray.removeAll(keepingCapacity: false)
                    
                    
                    for document in snapshot!.documents {
                        let documentID = document.documentID
                        IdArray.append(documentID)
                        
                        if let postedBy = document.get("postedBy") as? String {
                            userEmailArray.append(postedBy)
                        }
                       
                        
                        if let postComment = document.get("postComment") as? String {
                            userCommentArray.append(postComment)
                        }
                        
                        if let likes = document.get("likes") as? Int {
                            likeArray.append(likes)
                        }
                        
                        if let imageUrl = document.get("imageUrl") as? String {
                            userImageArray.append(imageUrl)
                        }
                        if let longitude = document.get("longitude") as? Double {
                            longitudeArray.append(longitude)
                        }
                        if let latitude = document.get("latitude") as? Double {
                            latitudeArray.append(latitude)
                        }
                        if let useruidsnapshot = document.get("PosterUID") as? String {
                            useruidarray.append(useruidsnapshot)
                        }
                        
                        
                        
                        
                    }
                    
                    
                    
                    self.getUserData2()
                    
                    
                    
                    
                    
                    
                    self.getCityAndCountryNames(latitudes: latitudeArray, longitudes: longitudeArray)
                    
                    
                    
                    
                    
                    
                }
                
                
            }
            
            
            
            
        }
        
        
        
    }
    func alertCreator (titleInput:String,messageInput:String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    
    
    
    func getCityAndCountryNames(latitudes: [Double], longitudes: [Double]) {
        
        let endpointURL = URL(string: "https://api.bigdatacloud.net/data/reverse-geocode")!
        let apiKey  = "bdc_d17088a91c2c462bb1c71f3f3838deea"
        
        
        
        
        
        for index in 0..<latitudes.count {
            
            let latitude = latitudes[index]
            let longitude = longitudes[index]
            
            
            var components = URLComponents(url: endpointURL, resolvingAgainstBaseURL: true)!
            components.queryItems = [
                URLQueryItem(name: "latitude", value: String(latitude)),
                URLQueryItem(name: "longitude", value: String(longitude)),
                URLQueryItem(name: "localityLanguage", value: "en"),
                URLQueryItem(name: "key", value: apiKey)
            ]
            
            
            guard let requestURL = components.url else {
                print("Error: Invalid request URL")
                continue
            }
            
            
            var request = URLRequest(url: requestURL)
            request.httpMethod = "GET"
            
            
            let semaphore = DispatchSemaphore(value: 0)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                defer { semaphore.signal() }
                // Check for errors
                guard error == nil else {
                    print("Error:", error!.localizedDescription)
                    return
                }
                
                
                
                guard let responseData = data else {
                    print("Error: No response data")
                    return
                }
                
                
                do {
                    let json = try JSONSerialization.jsonObject(with: responseData, options: []) as! [String: Any]
                    
                    if let city = json["principalSubdivision"] as? String,
                       let countryName = json["countryName"] as? String {
                        cityNames.append(city)
                        countryNames.append(countryName)
                    } else {
                        print("Error: Unable to extract city and country name from response")
                    }
                } catch {
                    print("Error: Unable to parse JSON response")
                }
            }
            
            task.resume()
            
            semaphore.wait()
            
            
        }
        
        
        
        
    }
    
    
   
    func getUserData2() {
        let firestoredatabase = Firestore.firestore()
        
        var userDataDictionary = [String: (String, String, String)]() // UID: (Name, Surname, ProfileURL)
        
        let group = DispatchGroup()
        
        for userUID in useruidarray {
            group.enter()
            let firestoredatabaseref = firestoredatabase.collection("User").document(userUID)
            firestoredatabaseref.getDocument { document, error in
                defer { group.leave() }
                if let document = document, document.exists {
                    let data = document.data()
                    let firstname = data?["Name"] as? String ?? ""
                    let lastname = data?["Surname"] as? String ?? ""
                    let profileURL = data?["profileURL"] as? String ?? ""
                    userDataDictionary[userUID] = (firstname, lastname, profileURL)
                } else {
                    print("document does not exist")
                }
            }
        }
        
        group.notify(queue: .main) {
            // UID sırasına göre dizileri güncelle
            for userUID in useruidarray {
                if let userData = userDataDictionary[userUID] {
                    nameArray.append(userData.0)
                    surnameArray.append(userData.1)
                   profileURLArray.append(userData.2)
                }
            }
            self.tableView.reloadData()
        }
    }

    
    
    
}
