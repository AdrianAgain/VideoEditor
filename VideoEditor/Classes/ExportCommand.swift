//
//  ExportCommand.swift
//  VideoEditor
//
//  Created by Adrian Hernandez on 10/2/15.
//  Copyright © 2015 Adrian Hernandez. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class ExportCommand: EditionCommand {

    private var exportSession : AVAssetExportSession!
    private var outputURL : NSURL!
    private var presetName : String!
    private var outputFileType : String!
    
    /**
    Exports the asset to a file specified by the outputPath.
    - parameter asset the asset to export
    - parameter presetName  A string constant specifying the name of the preset template for the export. For possible values, see Export Preset Names for Device-Appropriate QuickTime Files, Export Preset Names for QuickTime Files of a Given Size, AVAssetExportSessionStatusCancelled, Export Preset Name for iTunes Audio, and Export Preset Name for Pass-Through.
    - parameter outputPath path for the output file
    */
    
    func exportAsset(asset: AVAsset, presetName: String , outputPath: String, outputFileType: String){
        
        self.outputURL = NSURL(fileURLWithPath: outputPath)
        self.presetName = presetName
        self.outputFileType = outputFileType
        
        do{
            try  NSFileManager.defaultManager().removeItemAtPath(outputPath)
        }
        catch let error as NSError {
            self.handleError(error)
        }
        
        self.performWithAsset(asset)
    }
    
    
    override func performWithAsset(asset: AVAsset) {
        self.exportSession = AVAssetExportSession(asset: self.mutableComposition ?? asset, presetName: self.presetName)
        
        self.exportSession.videoComposition = self.mutableVideoComposition
        self.exportSession.audioMix = self.mutableAudioMix
        self.exportSession.outputURL = self.outputURL
        self.exportSession.outputFileType = self.outputFileType
    
        self.exportSession.exportAsynchronouslyWithCompletionHandler { () -> Void in
            switch self.exportSession.status {
            case .Completed :
                self.exportSessionCompletedSuccessfully()
                break
            case .Failed, .Cancelled :
                self.handleError(self.exportSession.error)
                break
            default:
                break
            }
        }
    }
    
    private func exportSessionCompletedSuccessfully(){
       NSNotificationCenter.defaultCenter().postNotificationName(ExportCommandCompletionNotification, object: self)
        self.writeVideoToPhotoLibrary()
    }
    
    private func writeVideoToPhotoLibrary(){
        let library = ALAssetsLibrary()
        library.writeVideoAtPathToSavedPhotosAlbum(self.outputURL) { (assetURL, error) -> Void in
            if error == nil {
            print("Saved in library edited video")
            }
            else {
            print(error)
            }
        }
    }
    
    private func handleError(error : NSError?){
        print("\(NSStringFromClass(self.dynamicType)) error: \(error?.description)")
    }
    
}
