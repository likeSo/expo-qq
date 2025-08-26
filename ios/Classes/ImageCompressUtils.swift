//
//  ImageCompressUtils.swift
//  ExpoWechat
//
//  Created by Aron on 2025/6/17.
//

import Foundation

struct ImageCompressUtils {
    /// 压缩图片数据到指定 KB 大小
    /// - Parameters:
    ///   - imageData: 原始图片数据（JPEG/PNG）
    ///   - targetKB: 目标大小（单位 KB）
    /// - Returns: 压缩后的图片数据（如果无法压缩到目标大小，返回 nil）
    static func compressImageData(_ imageData: Data, toTargetKB targetKB: Int) -> Data? {
        guard targetKB > 0 else { return nil }
        
        // 1. 检查原始数据是否已经符合要求
        if imageData.count <= targetKB * 1024 {
            return imageData
        }
        
        // 2. 尝试无损压缩（如果是 PNG）
        if isPNG(data: imageData), let compressed = tryCompressPNG(imageData, targetKB: targetKB) {
            return compressed
        }
        
        // 3. 有损压缩（JPEG 或 PNG 转 JPEG）
        return tryCompressJPEG(imageData, targetKB: targetKB)
    }


    /// 检查是否为 PNG 图片
    private static func isPNG(data: Data) -> Bool {
        return data.starts(with: [0x89, 0x50, 0x4E, 0x47]) // PNG 文件头
    }

    /// 尝试无损压缩 PNG（通过降低位深度）
    private static  func tryCompressPNG(_ data: Data, targetKB: Int) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        
        // PNG 无损压缩空间有限，如果原始数据远大于目标，直接返回 nil
        if data.count > targetKB * 1024 * 3 {
            return nil
        }
        
        return autoreleasepool {
            image.pngData()
        }
    }

    /// 有损压缩 JPEG（或 PNG 转 JPEG）
    private static  func tryCompressJPEG(_ data: Data, targetKB: Int) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let targetBytes = targetKB * 1024
        var quality: CGFloat = 0.9
        var result: Data?
        
        for _ in 0..<10 {
            autoreleasepool {
                guard let compressedData = image.jpegData(compressionQuality: quality) else { return }
                
                if compressedData.count <= targetBytes {
                    result = compressedData
                } else {
                    quality *= 0.7
                }
            }
            
            if result != nil { break }
        }
        
        // 如果仍然过大，强制缩小尺寸
        if result == nil || result!.count > targetBytes {
            return compressByResizing(image, targetKB: targetKB)
        }
        
        return result
    }

    /// 通过缩小尺寸压缩
    private static  func compressByResizing(_ image: UIImage, targetKB: Int) -> Data? {
        let targetBytes = targetKB * 1024
        var currentSize = image.size
        var result: Data?
        
        // 按比例逐步缩小尺寸（最小不低于 100x100）
        while currentSize.width > 100 && currentSize.height > 100 {
            autoreleasepool {
                let newSize = CGSize(width: currentSize.width * 0.8, height: currentSize.height * 0.8)
                UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
                image.draw(in: CGRect(origin: .zero, size: newSize))
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                if let data = newImage?.jpegData(compressionQuality: 0.5) {
                    if data.count <= targetBytes {
                        result = data
                    } else {
                        currentSize = newSize
                    }
                }
            }
            
            if result != nil { break }
        }
        
        return result
    }
}
