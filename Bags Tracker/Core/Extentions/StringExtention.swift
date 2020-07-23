//
//  StringExtention.swift
//  Bags Tracker
//
//  Created by Mixaill on 17.07.2020.
//  Copyright © 2020 M Technologies. All rights reserved.
//

import Foundation
import CommonCrypto
import CryptoKit

extension String {

    var md5: String {
        let digest = Insecure.MD5.hash(data: Data(self.utf8))
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
        
//        let data = Data(self.utf8)
//        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
//            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
//            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
//            return hash
//        }
//        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    
    
}
