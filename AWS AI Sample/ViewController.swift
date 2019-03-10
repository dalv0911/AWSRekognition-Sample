//
//  ViewController.swift
//  AWS AI Sample
//
//  Created by Da Le on 3/2/19.
//  Copyright © 2019 Tasogare. All rights reserved.
//

import UIKit
import AWSRekognition

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var rekognition: AWSRekognition?
    var apiResult: AWSRekognitionIndexFacesResponse?
    let collectionId = "com.dalv.faces"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rekognition = AWSRekognition.default()
        loading.stopAnimating()
        // Only create the location Id once
//        let request = AWSRekognitionCreateCollectionRequest()
//        request?.collectionId = collectionId
//        rekognition?.createCollection(request!).continueWith { (res) in
//            if let error = res.error {
//                print(error)
//            }
//            print(res)
//            return nil
//        }
        
    }

    @IBAction func openApiResultView(_ sender: Any) {
        let apiResultView = self.storyboard?.instantiateViewController(withIdentifier: "ApiResultController") as! ApiResultController
        apiResultView.result = apiResult
        apiResultView.modalPresentationStyle = .custom
        apiResultView.modalTransitionStyle = .crossDissolve
        present(apiResultView, animated: true, completion: nil)
    }
    
    @IBAction func openCamera(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        pickerController.cameraCaptureMode = .photo
        present(pickerController, animated: true)
    }
    
    @IBAction func openGallery(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .savedPhotosAlbum
        present(pickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Couldn't load image from Photos")
        }
        imageView.image = image
        
        let imageData: Data = image.jpegData(compressionQuality: 0.2)!
        sendImageToRekognition(imageData: imageData)
    }
    
    func sendImageToRekognition(imageData: Data) {
        loading.startAnimating()
        let rekognitionImage = AWSRekognitionImage()
        rekognitionImage?.bytes = imageData
        let request = AWSRekognitionIndexFacesRequest()
        request?.collectionId = collectionId
        request?.image = rekognitionImage
        request?.detectionAttributes = ["ALL"]
        
        rekognition?.indexFaces(request!).continueOnSuccessWith(block: { (res) in
            if let error = res.error {
                print(error)
            }
            if let result = res.result, let faceRecords = result.faceRecords {
                self.apiResult = result
                DispatchQueue.main.async {
                    self.decorFace(faceRecord: FaceRecord(data: faceRecords[0]))
                }
            }
            return nil
        })
    }
    
    func decorFace(faceRecord: FaceRecord) {
        
        let faceImage = imageView.image!
        
        let landmarks = faceRecord.landmarks()
        let mustacheRect = faceRecord.mustacheRect(faceImage: faceImage)
//        let beardRect = faceRecord.beardRect(faceImage: faceImage)
        
        let mustacheImage = UIImage(named: "mustache")
//        let beardImage = UIImage(named: "beard")
        
        // Draw on the face image
        UIGraphicsBeginImageContext(imageView.image!.size)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        faceImage.draw(at: CGPoint.zero)
        
        if mustacheRect != nil {
            mustacheImage?.draw(in: mustacheRect!)
        }
        if landmarks != nil {
            for landmark in landmarks! {
                let circle = CGRect(x: CGFloat(truncating: landmark.x!) * faceImage.size.width, y: CGFloat(truncating: landmark.y!) * faceImage.size.height, width: 30, height: 30)
                context?.setFillColor(UIColor.white.cgColor)
                context?.fillEllipse(in: circle)
            }
        }
        
//        if beardRect != nil {
//            beardImage?.draw(in: beardRect!)
//        }
        
        context?.restoreGState()
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        loading.stopAnimating()
        imageView.image = newImage
    }
    
}


