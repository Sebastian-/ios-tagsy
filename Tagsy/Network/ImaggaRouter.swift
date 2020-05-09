//
//  ImaggaRouter.swift
//  Tagsy
//
//  Created by Sebastian Murgu on 2020-03-09.
//  Copyright © 2020 Sebastian Murgu. All rights reserved.
//

import Alamofire

public enum ImaggaRouter: URLRequestConvertible {
  
  enum Constants {
      static let baseURL = "https://api.imagga.com/v2"
      static let authorizationToken = "Basic YWNjX2RkNmNhZDVkNTI1NWFiODoyYzhiYzkzMjE1ZTdlNGJhMGYzYzc3MDNiZGM4YjFlZg=="
  }
  
  case upload
  case tags(String)
  case colors(String)
  
  var method: HTTPMethod {
    switch self {
    case .upload:
      return .post
    default:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .upload:
      return "/uploads"
    case .tags:
      return "/tags"
    case .colors:
      return "/colors"
    }
  }
  
  var parameters: [String : Any] {
    switch self {
    case .tags(let contentId):
      return ["image_upload_id": contentId]
    case .colors(let contentId):
      return ["image_upload_id": contentId, "extract_object_colors": 0]
    default:
      return [:]
    }
  }
  
  public func asURLRequest() throws -> URLRequest {
    let url = try Constants.baseURL.asURL()
    
    var request = URLRequest(url: url.appendingPathComponent(path))
    request.httpMethod = method.rawValue
    request.setValue(Constants.authorizationToken, forHTTPHeaderField: "Authorization")
    request.timeoutInterval = TimeInterval(10000)
    
    return try URLEncoding.default.encode(request, with: parameters)
  }
}
