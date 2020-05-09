//
//  ImaggaAPI.swift
//  Tagsy
//
//  Created by Sebastian Murgu on 2020-03-09.
//  Copyright © 2020 Sebastian Murgu. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ImaggaAPI {
  static public let shared = ImaggaAPI()
  
  func postUpload(
    image: UIImage,
    progressCompletion: @escaping (_ percent: Float) -> Void,
    completion: @escaping (_ tags: [String]?, _ colors: [ImageColor]?, _ id: String?) -> Void) {
    
    guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
    
    Alamofire.upload(
      multipartFormData: { multipartFormData in
        multipartFormData.append(imageData, withName: "image", fileName: "image.jpg", mimeType: "image/jpg")
    },
    // ImaggaRouter.upload encoding result block
    with: ImaggaRouter.upload) {
      encodingResult in
      switch encodingResult {
      // we were successful in encoding ImaggaRouter.upload
      case .success(let encodedUpload, _, _):
          // pass upload progress data to our progressCompletion function
          encodedUpload.uploadProgress { progress in
              progressCompletion(Float(progress.fractionCompleted))
          }
          // validate our encoding result
          encodedUpload.validate()

          // send our request and access the response
          encodedUpload.responseJSON { response in
              guard response.result.isSuccess,
                  // our request failed, print the error
                  let value = response.result.value else {
                      print("Error while uploading file: \(String(describing: response.result.error))")
                      completion(nil, nil, nil)
                      return
              }

              // our request was successful (200)

              // grab the upload id from the result
              let uploadedImageID = JSON(value)["result"]["upload_id"].stringValue
              print("Image uploaded with ID: \(uploadedImageID)")

              // call downloadTags with our upload id
              self.getTags(imageID: uploadedImageID) { tags in

                  // we've received tags data
                  // call downloadColors with our upload id
                  self.getColors(imageID: uploadedImageID) { colors in

                      // call our completion method with the data we've received
                      completion(tags, colors, uploadedImageID)
                  }
              }
          }
      // encoding failed
      case .failure(let error):
          print("There was an error uploading image: \(error)")
      }
    }
  }
  
  // getTags takes 2 arguments
  // an uploaded image id and a completion function that will be called
  // when we have received data from the Imagga API
  func getTags(imageID: String, completion: @escaping ([String]?) -> Void) {
      Alamofire
          // build the requeset
          .request(ImaggaRouter.tags(imageID))
          // send the request and receive the response
          .responseJSON { response in
              guard response.result.isSuccess,
                    let value = response.result.value else {
                  // there was an error
                  print("Error while fetching tags: \(String(describing: response.result.error))")
                  completion(nil)
                  return
              }

              // success!
              // get the tags from the response
              let tags = JSON(value)["result"]["tags"].array?.map { json -> String in
                  json["tag"]["en"].stringValue
              }

              // call the completion function and pass the tags
              completion(tags)
      }
  }
  
  // getColors takes 2 arguments
  // an uploaded image id and a completion function that will be called
  // when we have received data from the Imagga API
  func getColors(imageID: String, completion: @escaping ([ImageColor]?) -> Void) {
      Alamofire
          // build the requeset
          .request(ImaggaRouter.colors(imageID))
          // send the request and receive the response
          .responseJSON { response in
              guard response.result.isSuccess,
                  let value = response.result.value else {
                      // theere was an error
                      print("Error while fetching colors: \(String(describing: response.result.error))")
                      completion(nil)
                      return
              }

              // success!
              // get the colors from the response
              // create a ImageColor object for each set of color data we've recieved
              let photoColors = JSON(value)["result"]["colors"]["image_colors"].array?.map { json -> ImageColor in
                  ImageColor(red: json["r"].intValue,
                             green: json["g"].intValue,
                             blue: json["b"].intValue,
                             colorName: json["closest_palette_color"].stringValue)
              }

              // call the completion function and pass the array of ImageColor objects
              completion(photoColors)
      }
  }
  
}
