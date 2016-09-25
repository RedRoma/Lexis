//
//  ViewControllers+.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/17/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import CoreLocation
import Foundation
import UIKit


extension UIViewController
{
    
    func hideNetworkIndicator()
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        //34.018132, -118.493179
//        let link = "https://api.yelp.com/v3/businesses/search?term=delis&latitude=34.0181&longitude=-118.493179"
//        let url = URL(string:link)!
//        let token = "otPOIcrNXLV6Ak91B4Gs14YMvP5r5tH7eIZBPqjE2uk3h_lZ4McJGaxYJT4PJsoLlTfwEQ1svx15STNY6cxTpps3K1Yy4J4YkJIWqgbBp-7I06hI7Qsyk5YxSefeV3Yx"
//        
//        var request = URLRequest.init(url: url)
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        URLSession.shared.dataTask(with: request) { data, response, error  in
//            
//            guard let data = data else { return }
//            //parse into json
//            //update UI
//        }.resume()
        
    }
    
    func showNetworkIndicator()
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
}

extension UITableViewController
{
    
    func reloadSection(_ section: Int, withAnimation animation: UITableViewRowAnimation = .automatic)
    {
        let indexSet = IndexSet.init(integer: section)
        self.tableView.reloadSections(indexSet, with: animation)
    }
}

