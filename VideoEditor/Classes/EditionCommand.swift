//
//  EditionCommand.swift
//  VideoEditor
//
//  Created by Adrian Hernandez on 10/2/15.
//  Copyright © 2015 Adrian Hernandez. All rights reserved.
//

import UIKit
import AVFoundation

//Notifications
let EditionCommandCompletionNotification = "EditionCommandCompletionNotification"
let ExportCommandCompletionNotification = "ExportCommandCompletionNotification"

class EditionCommand: NSObject {

    //MARK: Properties
    /** the mutable composition that contains video and audio composition tracks. */
     var mutableComposition : AVMutableComposition?
    
    /** contains the video composition instructions.  */
    var mutableVideoComposition : AVMutableVideoComposition?
    
    /** contains the audio mix input parameters. */
    var mutableAudioMix : AVMutableAudioMix?
    
    //MARK: - Initializer
    init(composition: AVMutableComposition?, videoComposition: AVMutableVideoComposition?, audioMix: AVMutableAudioMix?){
        super.init()
        self.mutableComposition = composition
        self.mutableVideoComposition = videoComposition
        self.mutableAudioMix = audioMix
    }
    
    
    // abstract method. needs to be implemented by subclasses
    func performWithAsset(asset: AVAsset){
        self.doesNotRecognizeSelector("performWithAsset:")
    }

    
}
