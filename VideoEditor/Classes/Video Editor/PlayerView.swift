//
//  PlayerView.swift
//  VideoEditor
//
//  Created by Adrian Hernandez on 10/5/15.
//  Copyright © 2015 Adrian Hernandez. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerView: UIView {

    var player : AVPlayer? {
        get{
            return (self.layer as! AVPlayerLayer).player
        }
        set{
            (self.layer as! AVPlayerLayer).player = newValue
        }
    }
    
    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }

}
