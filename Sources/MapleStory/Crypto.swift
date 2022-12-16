//
//  Crypto.swift
//  
//
//  Created by Alsey Coleman Miller on 12/13/22.
//

import Foundation
import CMapleStory

internal enum Crypto {
    
    enum AES {
        
        
    }
    
    enum Maple {
        
        /// MapleStory encrypt
        static func encrypt(_ data: inout Data) {
            let length = Int32(data.count)
            data.withUnsafeMutableBytes {
                maple_encrypt($0.baseAddress, length)
            }
        }
        
        /// MapleStory decrypt
        static func decrypt(_ data: inout Data) {
            let length = Int32(data.count)
            data.withUnsafeMutableBytes {
                maple_decrypt($0.baseAddress, length)
            }
        }
    }
}
