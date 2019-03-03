//
//  ApiResultController.swift
//  AWS AI Sample
//
//  Created by Da Le on 3/3/19.
//  Copyright © 2019 Tasogare. All rights reserved.
//

import UIKit
import AWSRekognition

struct ApiDataCellModel {
    let name: String?
    let value: String?
}


class ApiResultController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var result: AWSRekognitionIndexFacesResponse? = nil
    var tableData: [ApiDataCellModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadTableViewData()
        
    }
    
    func loadTableViewData() {
        if result == nil || result?.faceRecords == nil {
            return
        }
        
        let faceRecord: FaceRecord = FaceRecord(data: (result?.faceRecords![0])!)
        tableData = faceRecord.toTableData()
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ApiTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "ApiTableViewCell") as! ApiTableViewCell
        cell.name.text = self.tableData[indexPath.row].name
        cell.value.text = self.tableData[indexPath.row].value
        return cell
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view !== containerView {
            // dismiss popup when touch outside
            self.dismiss(animated: true, completion: nil)
        }
    }
}
