//
//  ImageItem.swift
//  GeoPhotos
//
//  Created by mcxiaoke on 16/6/7.
//  Copyright © 2016年 mcxiaoke. All rights reserved.
//

import Foundation

class ImageItem:NSObject {
  let url:NSURL
  let type:String
  let name:String
  let size:UInt64
  let dimension:NSSize
  let createdAt:NSDate
  
  var modifiedAt: NSDate
  var mimeType: String?
  var latitude:Double?
  var longitude:Double?
  var altitude:Double?
  var timestamp:NSDate?
  var exifDate:NSDate?
  
  var modified = false
  var backuped = false
  
  init(url:NSURL, type:String, name:String,
       size:UInt64, dimension:NSSize,
       createdAt:NSDate, modifiedAt:NSDate){
    self.url = url
    self.type = type
    self.name = name
    self.size = size
    self.dimension = dimension
    self.createdAt = createdAt
    self.modifiedAt = modifiedAt
  }
  
  override var description: String{
    return "ImageItem(name=\(name), latitude=\(latitude), longitude=\(longitude), timestamp=\(timestamp))"
  }
  
  func updateProperties(properties:NSDictionary) -> Bool {
    if let exif = properties[kCGImagePropertyExifDictionary as String]{
      if let exifDateStr = exif[kCGImagePropertyExifDateTimeDigitized as String] as? String {
        self.exifDate = DateFormatter.dateFromString(exifDateStr)
      }
    }
    // gps properties
    if let gps = properties[kCGImagePropertyGPSDictionary as String] {
      let latitudeRef = gps[kCGImagePropertyGPSLatitudeRef as String] as! String
      let latitude = gps[kCGImagePropertyGPSLatitude as String] as? Double
      let longitudeRef = gps[kCGImagePropertyGPSLongitudeRef as String] as! String
      let longitude = gps[kCGImagePropertyGPSLongitude as String] as? Double
      let altitude = gps[kCGImagePropertyGPSAltitude as String] as? Double
      let dateStr = gps[kCGImagePropertyGPSDateStamp as String] as? String
      let timeStr = gps[kCGImagePropertyGPSTimeStamp as String] as? String
      self.latitude = latitudeRef == "N" ? latitude! : -latitude!
      self.longitude = longitudeRef == "E" ? longitude! : -longitude!
      self.altitude = altitude
      if let dateStr = dateStr, let timeStr = timeStr {
        let timestamp = DateFormatter.dateFromString("\(dateStr) \(timeStr)")
        self.timestamp = timestamp
      }
      return true
    }
    return false
  }
  
  func updateProperties() -> Bool {
    guard let imageSource = CGImageSourceCreateWithURL(url, nil)
      else { return false }
    guard let propertiesValue = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)
      else { return false }
    guard let properties = propertiesValue as? NSDictionary else { return false }
    return updateProperties(properties)
  }
  
}
