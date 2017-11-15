//
//  VideoSearchController.swift
//  BilibiliAPI
//
//  Created by Yuan Zhou on 2017/10/15.
//  Copyright © 2017年 Yuan Zhou. All rights reserved.
//

import UIKit

class VideoSearchController: UITableViewController {
    
    @IBOutlet weak var videoName: UILabel!
    @IBOutlet weak var upImage: UIImageView!
    @IBOutlet weak var upName: UILabel!
    @IBOutlet weak var videoamount: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var follower: UILabel!
    @IBOutlet weak var upsign: UILabel!
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var viewCount: UILabel!
    @IBOutlet weak var danmakuCount: UILabel!
    @IBOutlet weak var replyCount: UILabel!
    @IBOutlet weak var favoriteCount: UILabel!
    @IBOutlet weak var coinCount: UILabel!
    @IBOutlet weak var ShareCount: UILabel!
    @IBOutlet weak var curRanking: UILabel!
    @IBOutlet weak var hisRanking: UILabel!
    @IBOutlet weak var copyright: UILabel!
    @IBOutlet weak var favoriteIcon: UIButton!
    @IBOutlet weak var uploaderCell: UITableViewCell!
    @IBOutlet weak var descriptionCell: UITableViewCell!
    @IBOutlet weak var videoTitleCell: UITableViewCell!
    @IBOutlet var statTable: UITableView!
    
    let searchBar = UISearchBar()
    var searchButtonPressed = false
    var info_set = false
    var DNE = false
    var aid: String!
    var uid: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.titleView = searchBar
        self.searchBar.keyboardType = UIKeyboardType.numberPad
        self.searchBar.becomeFirstResponder()
        if #available(iOS 11.0, *) {
            self.searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
        self.statTable.isHidden = true
        self.favoriteIcon.addTarget(self, action: #selector(favoritePressed), for: UIControlEvents.touchUpInside)
        
        let searchButton = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(searchPressed))
        self.navigationItem.setRightBarButton(searchButton, animated: true)
        reset_views()
        if self.searchButtonPressed {
            self.searchButtonPressed = false
            search()
        }
    }
    
    func reset_views() {
        self.videoName.text = ""
        self.upImage.image = nil
        self.upName.text = ""
        self.videoamount.text = ""
        self.following.text = ""
        self.follower.text = ""
        self.upsign.text = ""
        self.videoImage.image = nil
        self.desc.text = ""
        self.viewCount.text = ""
        self.danmakuCount.text = ""
        self.replyCount.text = ""
        self.favoriteCount.text = ""
        self.coinCount.text = ""
        self.ShareCount.text = ""
        self.curRanking.text = ""
        self.hisRanking.text = ""
        self.copyright.text = ""
        self.info_set = false
        self.uid = nil
        self.DNE = false
        self.videoTitleCell.isUserInteractionEnabled = false
        self.uploaderCell.isUserInteractionEnabled = false
        self.descriptionCell.isUserInteractionEnabled = false
        self.videoTitleCell.accessoryType = UITableViewCellAccessoryType.none
        self.uploaderCell.accessoryType = UITableViewCellAccessoryType.none
        self.descriptionCell.accessoryType = UITableViewCellAccessoryType.none
        self.favoriteIcon.isHidden = true
        self.favoriteIcon.setImage(UIImage(named: "notfavorite"), for: UIControlState.normal)
    }
    
    @objc func searchPressed(_ sender: UIBarButtonItem) {
        search()
    }
    
    @objc func favoritePressed() {
        if let index = FavoriteDB.sharedInstance.videoIDs.index(of: self.aid) {
            self.favoriteIcon.setImage(UIImage(named: "notfavorite"), for: UIControlState.normal)
            FavoriteDB.sharedInstance.videoTitles.remove(at: index)
            FavoriteDB.sharedInstance.videoImgs.remove(at: index)
            FavoriteDB.sharedInstance.videoIDs.remove(at: index)
            let alertController = UIAlertController(title: "Favorite removed", message:
                "This video has been removed from your favorite collection.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.favoriteIcon.setImage(UIImage(named: "favorite"), for: UIControlState.normal)
            FavoriteDB.sharedInstance.videoTitles.append(self.videoName.text)
            FavoriteDB.sharedInstance.videoImgs.append(self.videoImage.image)
            FavoriteDB.sharedInstance.videoIDs.append(self.aid)
            let alertController = UIAlertController(title: "Favorite added", message:
                "This video has been added to your favorite collection.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func search() {
        self.reset_views()
        self.searchBar.resignFirstResponder()
        
        self.aid = self.searchBar.text
        if Int(self.aid) == nil {
            let alertController = UIAlertController(title: "Error", message:
                "Video ID should be an integer", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.statTable.isHidden = false
            self.videoName.text = "Searching video ID " + self.aid
            if FavoriteDB.sharedInstance.videoIDs.contains(self.aid) {
                self.favoriteIcon.setImage(UIImage(named: "favorite"), for: UIControlState.normal)
            }
            get_request("bili_video", "https://api.bilibili.com/archive_stat/stat?aid=" + self.searchBar.text!)
            get_request("jiji_video", "http://www.jijidown.com/Api/AvToCid/" + self.aid)
            get_request("webpage", "http://bili.utoptutor.com/videopage?aid=" + self.aid)
        }
    }
    
    func get_request(_ type: String, _ urlstr: String) {
        let url = URL(string: urlstr)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let data = data {
                do {
                    // Convert the data to JSON
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    DispatchQueue.main.async(execute: {
                        self.displayInfo(type, json)
                    })
                }  catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func displayInfo(_ type: String, _ json: [String: Any]) {
        if type == "bili_video" {
            if json["code"] as! Int != 0 {
                self.videoName.text = "Video doesn't exist"
                self.DNE = true
            } else {
                let data = json["data"] as! [String: Any?]
                self.viewCount.text = String(data["view"] as? Int ?? 0)
                self.danmakuCount.text = String(data["danmaku"] as? Int ?? 0)
                self.replyCount.text = String(data["reply"] as? Int ?? 0)
                self.favoriteCount.text = String(data["favorite"] as? Int ?? 0)
                self.coinCount.text = String(data["coin"] as? Int ?? 0)
                self.ShareCount.text = String(data["share"] as? Int ?? 0)
                let curRankInt = data["now_rank"] as? Int ?? 0
                let hisRankInt = data["his_rank"] as? Int ?? 0
                let copyrightInt = data["copyright"] as? Int ?? 0
                self.curRanking.text = curRankInt == 0 ? ">100" :  String(curRankInt)
                self.hisRanking.text = hisRankInt == 0 ? ">1000" :  String(hisRankInt)
                self.copyright.text = copyrightInt == 1 ? "Yes" : "No"
            }
        } else if type == "jiji_video" {
            if json["code"] as! Int != 0 /*|| json["maxpage"] as! Int == 0*/ {
                // TODO: set videoimage as defaulf "not found" image
                return
            } else {
                if self.info_set == false {
                    self.info_set = true
                    if !self.DNE {
                        self.videoName.text = json["title"] as? String ?? "Video may be deleted"
                        self.favoriteIcon.isHidden = false
                        self.videoTitleCell.isUserInteractionEnabled = true
                        self.videoTitleCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                    }
                    self.upName.text = json["up"] as? String
                    self.desc.text = json["desc"] as? String
                    if FavoriteDB.sharedInstance.downloadImage {
                        self.setImage(self.upImage, json["upimg"] as? String)
                    }
                    self.descriptionCell.isUserInteractionEnabled = true
                    self.descriptionCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                }
                if FavoriteDB.sharedInstance.downloadImage {
                    self.setImage(self.videoImage, json["img"] as? String)
                }
            }
        } else if type == "webpage" {
            if json["error"] as? Bool == true {
                //self.upsign.text = "Failed to uploader infomation"
                return
            } else {
                if self.info_set == false {
                    self.info_set = true
                    if !self.DNE {
                        self.videoName.text = json["title"] as? String
                        self.favoriteIcon.isHidden = false
                        self.videoTitleCell.isUserInteractionEnabled = true
                        self.videoTitleCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                    }
                    self.upName.text = json["upName"] as? String
                    self.desc.text = json["description"] as? String
                    if FavoriteDB.sharedInstance.downloadImage {
                        self.setImage(self.upImage, json["upAvatar"] as? String)
                    }
                    self.favoriteIcon.isHidden = false
                    self.videoTitleCell.isUserInteractionEnabled = true
                    self.descriptionCell.isUserInteractionEnabled = true
                    self.videoTitleCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                    self.descriptionCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                }
                let sign = json["upSign"] as? String
                self.upsign.text = sign == "" ? "Signature not set" : sign
                
                self.uid = json["uid"] as! String
                get_request("video_amount", "http://api.bilibili.com/x/space/navnum?mid=" + self.uid)
                get_request("follow_amount", "http://api.bilibili.com/x/relation/stat?vmid=" + self.uid)
                self.uploaderCell.isUserInteractionEnabled = true
                self.uploaderCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
        } else if type == "video_amount" {
            if json["code"] as! Int != 0 {
                //self.videoName.text = "Video not found"
            } else {
                let data = json["data"] as! [String: Any?]
                self.videoamount.text = "(" + String(data["video"] as? Int ?? 0) + " videos)"
            }
        } else if type == "follow_amount" {
            if json["code"] as! Int != 0 {
                //self.videoName.text = "Video not found"
            } else {
                let data = json["data"] as! [String: Any?]
                self.following.text = "Following: " + String(data["following"] as? Int ?? 0)
                self.follower.text = "Follower: " + String(data["follower"] as? Int ?? 0)
            }
        }
    }
    
    func setImage(_ image_view: UIImageView, _ urlstr: String?) {
        if let url = urlstr, let imgurl = URL(string: url) {
            let img = try? Data(contentsOf: imgurl)
            image_view.image = UIImage(data: img!)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController {
            searchBar.resignFirstResponder()
            if #available(iOS 11.0, *) {
                searchBar.isHidden = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            searchBar.isHidden = false
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "videoTitle" {
            let vcDest = segue.destination as! WebKitController
            vcDest.videoTitle = self.videoName.text
            vcDest.urlStr = self.aid
        } else if segue.identifier == "uploader" {
            if self.uid != nil {
                let vcDest = segue.destination as! UserSearchController
                vcDest.searchBar.text = self.uid
                vcDest.searchButtonPressed = true
            } else {
                let alertController = UIAlertController(title: "Cannot visit", message:
                    "This video is probably a movie or an episode of a bangumi, and its webpage layout is different from a usual one, thus the user ID of the uploader is not loaded, thus unable to view their profile.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        } else if segue.identifier == "description" {
            let vcDest = segue.destination as! VideoDescriptionController
            vcDest.descriptionText.text = self.desc.text
        }
    }
}
