//
//  FaceRecord.swift
//  AWS AI Sample
//
//  Created by Da Le on 3/3/19.
//  Copyright © 2019 Tasogare. All rights reserved.
//

import Foundation
import AWSRekognition

class FaceRecord
{
 
    let data: AWSRekognitionFaceRecord
    let genderDict = [
        AWSRekognitionGenderType.male: "男性",
        AWSRekognitionGenderType.female: "女性",
        AWSRekognitionGenderType.unknown: "Unknown"
    ]
    let emotionDict = [
        AWSRekognitionEmotionName.happy: "Happy",
        AWSRekognitionEmotionName.angry: "Angry",
        AWSRekognitionEmotionName.calm: "Calm",
        AWSRekognitionEmotionName.confused: "Confused",
        AWSRekognitionEmotionName.disgusted: "Disgusted",
    ]
    
    init(data: AWSRekognitionFaceRecord) {
        self.data = data
    }
    
    func mustacheRect(faceImage: UIImage) -> CGRect? {
        if data.faceDetail == nil || data.faceDetail?.landmarks == nil {
            return nil
        }
        var nose: AWSRekognitionLandmark?
        var mouthLeft: AWSRekognitionLandmark?
        var mouthRight: AWSRekognitionLandmark?
        
        for item in data.faceDetail!.landmarks! {
            if item.types == AWSRekognitionLandmarkType.nose {
                nose = item
            } else if item.types == AWSRekognitionLandmarkType.mouthLeft {
                mouthLeft = item
            } else if item.types == AWSRekognitionLandmarkType.mouthRight {
                mouthRight = item
            }
        }
        if nose == nil || mouthLeft == nil || mouthRight == nil {
            return nil
        }
        let diffMouth = mouthRight!.x!.floatValue - mouthLeft!.x!.floatValue
        let mouthWidth = CGFloat(diffMouth) * faceImage.size.width + 450
        
        return CGRect(x: CGFloat(truncating: nose!.x!) * faceImage.size.width - mouthWidth / 2, y: CGFloat(truncating: nose!.y!) * faceImage.size.height + 5, width: mouthWidth, height: 600)
    }
    
    func beardRect(faceImage: UIImage) -> CGRect? {
        if data.faceDetail == nil || data.faceDetail?.landmarks == nil {
            return nil
        }
        var chinBottom: AWSRekognitionLandmark?
        
        for item in data.faceDetail!.landmarks! {
            if item.types == AWSRekognitionLandmarkType.chinBottom {
                chinBottom = item
            }
        }
        if chinBottom == nil {
            return nil
        }
        
        return CGRect(x: CGFloat(truncating: chinBottom!.x!) * faceImage.size.width - 200, y: CGFloat(truncating: chinBottom!.y!) * faceImage.size.height - 100, width: 400, height: 600)
    }
    
    func toTableData() -> [ApiDataCellModel] {
        let faceDetail = data.faceDetail
        var cell: ApiDataCellModel
        var array:[ApiDataCellModel] = []
        
        cell = ApiDataCellModel(name: "年齢", value: "\(faceDetail?.ageRange?.low ?? 0) ~ \(faceDetail?.ageRange?.high ?? 0)歳")
        array.append(cell)

        cell = ApiDataCellModel(name: "性別", value: "\(genderDict[faceDetail?.gender?.value ?? AWSRekognitionGenderType.unknown]!)")
        array.append(cell)
        
        cell = ApiDataCellModel(name: "髭", value: "\((faceDetail?.beard?.value ?? false).boolValue ? "あり" : "なし")")
        array.append(cell)
        
        cell = ApiDataCellModel(name: "口髭", value: "\((faceDetail?.mustache?.value ?? false).boolValue ? "あり" : "なし")")
        array.append(cell)
        
        var emotion: String = "None"
        var emotionConfidence: NSNumber = 0
        if faceDetail?.emotions != nil {
            for emotionFace in (faceDetail?.emotions)! {
                if emotionFace.confidence?.doubleValue ?? 0 > emotionConfidence.doubleValue {
                    emotionConfidence = emotionFace.confidence ?? 0
                    emotion = "\(emotionDict[emotionFace.types] ?? "None")"
                }
            }
        }
        cell = ApiDataCellModel(name: "感情", value: emotion)
        array.append(cell)
        
        cell = ApiDataCellModel(name: "メガネ", value: "\((faceDetail?.eyeglasses?.value ?? false).boolValue ? "あり": "なし")")
        array.append(cell)
        
        cell = ApiDataCellModel(name: "開眼", value: "\((faceDetail?.eyesOpen?.value ?? false).boolValue ? "あり": "なし")")
        array.append(cell)
        
        cell = ApiDataCellModel(name: "開口", value: "\((faceDetail?.mouthOpen?.value ?? false).boolValue ? "あり": "なし")")
        array.append(cell)
        
        cell = ApiDataCellModel(name: "笑顔", value: "\((faceDetail?.smile?.value ?? false).boolValue ? "あり": "なし")")
        array.append(cell)
        
        cell = ApiDataCellModel(name: "黒眼鏡", value: "\((faceDetail?.sunglasses?.value ?? false).boolValue ? "あり": "なし")")
        array.append(cell)
        
        return array
    }
    
    func landmarks() -> [AWSRekognitionLandmark]? {
        return data.faceDetail?.landmarks
    }
}
