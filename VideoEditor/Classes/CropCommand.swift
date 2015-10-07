//
//  TrimCommand.swift
//  VideoEditor
//
//  Created by Adrian Hernandez on 10/2/15.
//  Copyright © 2015 Adrian Hernandez. All rights reserved.
//

import UIKit
import AVFoundation

class CropCommand: EditionCommand {
    
    private var insertionPoint : CMTime = kCMTimeZero
    private var duration : CMTime = kCMTimeZero
    
    /** modify the composition to a section defined by the range [insertionPoint - duration] */
    func cropAsset(asset: AVAsset, insertionPoint: CMTime, duration: CMTime){
        self.insertionPoint = insertionPoint
        self.duration = duration
        self.performWithAsset(asset)
    }
    
    override func performWithAsset(asset: AVAsset) {
        
        var assetVideoTracks : [AVAssetTrack]?
        var assetAudioTracks : [AVAssetTrack]?
        
        // Check if the asset contains video and audio tracks
        if asset.tracksWithMediaType(AVMediaTypeVideo).count != 0{
            assetVideoTracks = asset.tracksWithMediaType(AVMediaTypeVideo)
        }
        if asset.tracksWithMediaType(AVMediaTypeAudio).count != 0{
            assetAudioTracks = asset.tracksWithMediaType(AVMediaTypeAudio)
        }
        
        let insertionPoint = self.insertionPoint
        let trimmedDuration = self.duration
        
        if self.mutableComposition == nil {
            // create a new composition
            self.mutableComposition = AVMutableComposition()
            
            // insert the trimmed tracks from AVAsset
            if let videoTracks = assetVideoTracks {
                
                // prcessing each video track
                for videoAssetTrack in videoTracks {
                    
                    let compositionVideoTrack = self.mutableComposition!.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
                    
                    do {
                        try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(insertionPoint, trimmedDuration), ofTrack: videoAssetTrack, atTime: kCMTimeZero)
                    }
                    catch let error as NSError {
                        self.handleError(error)
                    }
                }
            }
            if let audioTracks = assetAudioTracks {
                
                // processing each audio track
                for audioAssetTrack in audioTracks {
                    let compositionAudioTrack = self.mutableComposition!.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
                    
                    do {
                        try compositionAudioTrack.insertTimeRange(CMTimeRangeMake(insertionPoint, trimmedDuration), ofTrack: audioAssetTrack, atTime: kCMTimeZero)
                    }
                    catch let error as NSError {
                        self.handleError(error)
                    }
                    
                }
            }
        }
        else {
            // there is already a composition
            self.mutableComposition!.removeTimeRange(CMTimeRangeMake(kCMTimeZero, insertionPoint))
            self.mutableComposition!.removeTimeRange(CMTimeRangeMake(trimmedDuration, self.mutableComposition!.duration))
        }
        
        
        // Notify crop operation completed
        NSNotificationCenter.defaultCenter().postNotificationName(EditionCommandCompletionNotification, object: self)
    }
//    
    private func handleError(error : NSError){
        print("\(NSStringFromClass(self.dynamicType)) error: \(error.description)")
    }
    
    
    //    private func insertTimeRangeToCompositionTrack(inout compositionTrack : AVMutableCompositionTrack, assetTrack : AVAssetTrack, compositionTrackDuration: CMTime,insertionPoint: CMTime) {
    //
    //        do {
    //            try compositionTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, compositionTrackDuration), ofTrack: assetTrack, atTime: insertionPoint)
    //        }
    //        catch let error as NSError {
    //            self.handleError(error)
    //        }
    //
    //    }
    //
    //    private func canAddTrack(track: AVAssetTrack ) -> Bool {
    //        // returns true only if the range [insertionPoint - trimmedDuration] intersected with
    //        // the track timeRange is not empty.
    //        return false
    //    }
}
