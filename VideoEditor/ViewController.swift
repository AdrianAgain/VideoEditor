//
//  ViewController.swift
//  VideoEditor
//
//  Created by Adrian Hernandez on 10/2/15.
//  Copyright © 2015 Adrian Hernandez. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import MobileCoreServices
import AssetsLibrary

class ViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var cropButton: UIButton!
    
    var mutableComposition : AVMutableComposition?
    var inputAsset : AVAsset!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cropButton.enabled = false
        self.exportButton.enabled = false
        
       
        NSNotificationCenter.defaultCenter().addObserverForName(EditionCommandCompletionNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (note) -> Void in
            self.exportButton.enabled = true
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(ExportCommandCompletionNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (note) -> Void in
            UIAlertView(title: "Finished Exporting", message: "Alalala", delegate: nil, cancelButtonTitle: "Cool").show()
            self.exportButton.enabled = true
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func  getAsset(){
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePickerController.mediaTypes =  [kUTTypeMovie as String]
        imagePickerController.videoQuality = UIImagePickerControllerQualityType.Type640x480
        
        self.presentViewController(imagePickerController, animated: true, completion: nil)
        
    }

    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var url : NSURL!
        if let _ = info[UIImagePickerControllerMediaType] as? String {

             url = info[UIImagePickerControllerReferenceURL] as! NSURL
            
            
//            if let asset = PHAsset.fetchAssetsWithALAssetURLs([url], options: nil).firstObject as? PHAsset {
//                
//                PHCachingImageManager().requestAVAssetForVideo(asset, options: nil, resultHandler: { (asset: AVAsset?, audioMix: AVAudioMix?, info: [NSObject : AnyObject]?) -> Void in
//                    if let asset = asset {
//                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
//                            self.inputAsset = asset
//                            self.cropButton.enabled = true
//                        })
//                    }
//                })
//            }

            
        }
        picker.dismissViewControllerAnimated(true) { () -> Void in
            self.showEditorWithAssetURL(url)
        }
    }
    
    func showEditorWithAssetURL(assetURL : NSURL){
        let editor : VideoEditorViewController = UIStoryboard(name: "VideoEditor", bundle: nil).instantiateInitialViewController() as! VideoEditorViewController
        self.presentViewController(editor, animated: true) { () -> Void in
           editor.loadAssetFromFile(assetURL)
        }
    }
    
    @IBAction func crop(sender: AnyObject) {
        let cropper : CropCommand  = CropCommand(composition: self.mutableComposition, videoComposition: nil, audioMix: nil)
        cropper.cropAsset(self.inputAsset, insertionPoint: CMTimeMakeWithSeconds(4,24), duration: CMTimeMakeWithSeconds(2,24))
        self.mutableComposition = cropper.mutableComposition
        self.cropButton.enabled = false
    }

    @IBAction func export(sender: AnyObject) {
        
        var path : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
        
        let manager = NSFileManager.defaultManager()
        do {
            try  manager.createDirectoryAtPath(path as String, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            print(error)
        }
        
        path = path.stringByAppendingPathComponent("output.mp4")
        do {
          try manager.removeItemAtPath(path as String)
        }
        catch  {
            print("error")
        }
        
        
        let exporter : ExportCommand = ExportCommand(composition: self.mutableComposition, videoComposition: nil, audioMix: nil)
        exporter.exportAsset(self.inputAsset, presetName: AVAssetExportPreset1280x720, outputPath: path as String, outputFileType: AVFileTypeQuickTimeMovie)
        
        self.exportButton.enabled = false
    }
    
    @IBAction func pick(sender: AnyObject) {
//        self.presentViewController(UIStoryboard(name: "VideoEditor", bundle: nil).instantiateInitialViewController()!, animated: true, completion: nil)
        self.getAsset()
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

