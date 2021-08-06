//
//  InfoViewController.swift
//  NeuroFlow App
//
//  Created by Nathan Ho on 8/5/21.
//
//  Class controls what is displayed on each cell table
//  Clicking on a cell will display the artist's image, name and popularity
//

import Foundation
import UIKit

class InfoViewController:  UIViewController {
    
    // var for displays
    var image = UIImage()
    var name = String()
    var popularityNum = String()
    
    // initialize components from app vc
    @IBOutlet weak var backgroundIMG: UIImageView!
    @IBOutlet weak var mainIMG: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var popularity: UILabel!
    
    override func viewDidLoad() {
        
        // set image from artist
        backgroundIMG.image = image
        mainIMG.image = image
        
        // set the artist name
        artistName.text = name
        
        // set popularity text
        popularity.text = popularityNum
        
    }
}
