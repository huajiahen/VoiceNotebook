//
//  Utitity.swift
//  VoiceNotebook
//
//  Created by huajiahen on 9/30/15.
//  Copyright © 2015 huajiahen. All rights reserved.
//

import Foundation

func documentsPathURL() -> NSURL {
    return NSURL.init(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0], isDirectory: true)
}