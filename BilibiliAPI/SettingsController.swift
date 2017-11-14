//
//  SettingsController.swift
//  BilibiliAPI
//
//  Created by Yuan Zhou on 2017/11/14.
//  Copyright © 2017年 Yuan Zhou. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let alertController = UIAlertController(title: "Are you sure?", message:
                    "Do you really want to remove all favorite videos in your collection?", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: {
                    (action) -> Void in
                    FavoriteDB.sharedInstance.removeVideos()
                }))
                alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                tableView.deselectRow(at: indexPath, animated: true)
            } else if indexPath.row == 1 {
                let alertController = UIAlertController(title: "Are you sure?", message:
                    "Do you really want to remove all favorite users in your collection?", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: {
                    (action) -> Void in
                    FavoriteDB.sharedInstance.removeUsers()
                }))
                alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}