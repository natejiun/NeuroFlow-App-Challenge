//
//  ViewController.swift
//  NeuroFlow App
//
//  Created by Nathan Ho on 8/3/21.
//
//  I installed Alamofire through Cocoapods to make the OAuth token request, this project also has SpotifyKit, but was never used
//  Alamofire Github Repository: https://github.com/Alamofire/Alamofire
//

import UIKit
import Alamofire

struct post {
    let mainImage : UIImage!
    let name : String!
    let pop : String!
}

class TableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchbar: UISearchBar!
    
    required init?(coder aDecoder: NSCoder) {
        //self.accToken = "Anonymous"
        super.init(coder: aDecoder)
    }
    
    // create post obj
    var posts = [post]()
    
    // client information
    let clientID = "546aa16fe2c243bb9b3c6d91b2074ffd"
    let clientSecret = "7dd42b749c254b0dad0968689c7b7c4f"
    
    // search url to send with authentication
    var searchURL = String()
    
    // token url for auth token
    var tokenURL = "https://accounts.spotify.com/api/token"
    
    // access token we get from Spotify server aka client credentials flow
    var accessToken = String()

    typealias JSONStandard = [String : AnyObject]
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        posts.removeAll()
        let keywords = searchBar.text
        
        // TODO: app crashes when character "'" is used, need to replace occurences of "'" with ""
//        if ((keywords?.contains("'")) != nil){
//            let string = keywords?.replacingOccurrences(of: "'", with: "")
//        }
        
        let finalKeywords = keywords?.replacingOccurrences(of: " ", with: "+")
        
        searchURL = "https://api.spotify.com/v1/search?q=\(finalKeywords!)&type=artist"
        
        callURL(url: searchURL)
        self.view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        callToken()
    }

    // func to get new token
    func callToken() {
        // parameters needed for making request
        let parameters = ["client_id" : clientID,
                          "client_secret" : clientSecret,
                          "grant_type" : "client_credentials",
                          "redirect_uri": "https%3A%2F%2Fwww.neuroflow.com%2F"]

        // encoed in base 64 i.e. clientid:clientsecret
        let headers : HTTPHeaders = ["Authorization" : "Basic OTc0MGVkNDQ2ZTBhNGJhMDllMGM2OWFjNmIyYWI5N2E6ODZjNTE2MmEyMWQzNDgzMTgzNGFiZDdkZGI1OGM1MTk="]
        
        // post request
        AF.request(tokenURL, method: .post, parameters: parameters, headers: headers).responseJSON(completionHandler: {
            response in
            
            // print result in console
            print(response.result)
            
            // TODO: read json file and obtain access token and set it equal to the access token var in class
            self.setToken(JSONData : response.data!)

        })
    
    }
    
    // set the access token we get from the JSON file to the var we have in class
    func setToken(JSONData: Data) {
        
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            
            let items = readableJSON["access_token"]
            
            // force unwrapped in order to not have tag "Optional(...)" displayed in our access token
            accessToken = "\(items!)"
            
            print(accessToken)
                
        }
        catch {
            print(error)
            
        }
        
    }
    
    
    // call the URL user wants to search
    func callURL(url : String) {
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        //
        AF.request(url, headers: headers).responseJSON(completionHandler: {
            response in
            
            print(response.result)
            self.parseJSON(JSONData: response.data!)
        })
    }
    
    // parse the JSON file we get after earning access token and using API
    func parseJSON(JSONData : Data) {
        
        // initialize a number formatter, style the followers as commas
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard

            if let artists = readableJSON["artists"] as? JSONStandard {
                if let items = artists["items"] as? [JSONStandard]{
                    for i in 0..<items.count{
                        let item = items[i] as? JSONStandard // conditonal cast message
                        
                        //print(item ?? "")   (console prints for testing)
                        //print(item?["name"] ?? "")
                        let name = item?["name"] as! String
                        
                        let fol = item?["followers"]
                        let total = fol?["total"] as! Int
                        
                        // add commas in the numbers
                        let temp = Int(total)
                        let formatTotal = numberFormatter.string(from: NSNumber(value:temp))
                        
                        //print(total)  (console prints for testing)
                            
                        // search for images elements on each artist name
                        if let images = item?["images"] as? [JSONStandard] {
                        // load first image section into imageData
                        let imageData = images.first
                        
                        // get the url info
                        // in the situation an artist does not have a profile image, a nil value will result in a picture of my good friend
                        let mainImageURL = URL(string: imageData?["url"] as? String ?? "https://media.discordapp.net/attachments/263767570274975747/872977501754916924/image0.jpg?width=501&height=935")
                        
                        // import the media data
                        let mainImageData = NSData(contentsOf: mainImageURL!)
                            
                        let mainImage = UIImage(data: mainImageData! as Data)
                        
                            posts.append(post.init(mainImage: mainImage, name: name, pop: "\(formatTotal!)"))
                        
                        // load data onto tab
                        self.tableView.reloadData()
                        
                            
                        }
                    }
                }
            }
        }

        catch {
            print(error)
        }

    }
    
    // table updaters and methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        let mainImageView = cell?.viewWithTag(2) as! UIImageView
        
        mainImageView.image = posts[indexPath.row].mainImage
        
        let mainLabel = cell?.viewWithTag(1) as! UILabel
        
        mainLabel.text = posts[indexPath.row].name
        
        return cell!
    }
    
    // send var information to the info view controller to display
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow?.row
        
        let vc = segue.destination as! InfoViewController
        
        vc.image = posts[indexPath!].mainImage
        vc.name = posts[indexPath!].name
        vc.popularityNum = posts[indexPath!].pop
        
    }
    
    
}

