//
//  VideoEditorViewController.swift
//  VideoEditor
//
//  Created by Adrian Hernandez on 10/5/15.
//  Copyright © 2015 Adrian Hernandez. All rights reserved.
//

import UIKit
import AVFoundation

enum TimeObserverKey : Int {
    case Pause = 0
}

private let PlayerItemKeyPathStatus = "status"

class VideoEditorViewController: UIViewController {

    
    @IBOutlet weak var playerView: PlayerView!
    
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    static var itemStatusContext : UnsafeMutablePointer<Void> = nil
    private var timeObservers : [TimeObserverKey : AnyObject] = [:]
    
    var playerItem: AVPlayerItem!
    
    /** The asset to edit */
    var inputAsset : AVAsset!
    
    /** The mutable composition that wraps the input asset to allow edition. */
    var mutableComposition : AVMutableComposition?
    
    /** Video composition to allow video composition instructions. */
    var mutableVideoComposition : AVMutableVideoComposition?
    
    /** Audio mix to allow custom audio processing. */
    var audioMix : AVMutableAudioMix?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        self.stopKeyValueObserving()
        self.removeTimeObservers()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        print("***** DEALLOCATING: \(NSStringFromClass(self.dynamicType)) *****")
    }
    
   //MARK: - Actions
    
    @IBAction func playAction(sender: AnyObject) {
        self.playerView.player?.play()
        
        self.addTimeObserver(TimeObserverKey.Pause, time: CMTime(seconds: 4, preferredTimescale: 24), queue: dispatch_get_main_queue()) { () -> (Void) in
            self.playerView.player?.pause()
        }
    }
    
    @IBAction func chooseAction(sender: AnyObject) {
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.removeTimeObservers()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

//MARK: - Player
extension VideoEditorViewController {
    
    func loadAssetFromFile(fileURL: NSURL){
        
        let asset : AVAsset = AVURLAsset(URL: fileURL, options: nil)
        let assetKeysToLoadAndTest = ["playable", "composable", "tracks", "duration"]
        
        asset.loadValuesAsynchronouslyForKeys(assetKeysToLoadAndTest) { () -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.setupPlaybackOFAsset(asset, withKeys: assetKeysToLoadAndTest)
            })
        }
        self.inputAsset = asset
    }
    
    private func setupPlaybackOFAsset(asset: AVAsset, withKeys keys: [String]){
        
        // This method is called when AVAsset has completed loading the specified array of keys.
        // playback of the asset is set up here.
        
        // Check whether the values of each of the keys we need has been successfully loaded.
        for key in keys{
            let error : NSErrorPointer = nil
            if (asset.statusOfValueForKey(key, error: error) == AVKeyValueStatus.Failed){
                self.handleError(error.memory)
                return
            }
        }
        
        if (!asset.playable){
            //TODO: handle asset cannot be played
            // handle asset cannot be played
            print("Asset cannot be played")
        }
        
        if(!asset.composable){
            //TODO: Handle asset not composable
            // Asset cannot be used to create a composition (e.g. it may have protected content).
            print("Asset cannot be used to create a composition")
        }
        
        // Setup the player item
        if (asset.tracksWithMediaType(AVMediaTypeVideo).count != 0){
            self.playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: keys)
            
            /* Simply creating the player item does not mean it’s ready to use.
               To determine when it’s ready to play, you can observe the item’s status
               property */
            self.playerItem.addObserver(self, forKeyPath: PlayerItemKeyPathStatus, options: NSKeyValueObservingOptions.Initial, context: VideoEditorViewController.itemStatusContext)
            
            // register to this notification to be able to move the player head to the begining
            // of the video once it is done playing.
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItem)
            
            // set the player
            let player = AVPlayer(playerItem: self.playerItem)
            self.playerView.player = player
            
        }
        else{
            //TODO: Handle asset has no video tracks
            // This asset has no video tracks.
            print("This asset has no video tracks.")
        }
    }
    
    private func syncUI(){
        if self.playerView.player?.currentItem != nil && self.playerView.player?.currentItem?.status == AVPlayerItemStatus.ReadyToPlay {
            print("Players current Item is ready to play")
            self.playButton.enabled = true
        }
        else{
            print("Players current Item is NOT ready to play")
            self.playButton.enabled = false
        }
    }
    
    private func handleError(error: NSError?){
        //TODO: Implement
        UIAlertView(title: "Error", message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    func playerItemDidReachEnd(notification: NSNotification){
        //TODO: Implement appropiately, since you may not want to go exactly to 
        // the begining of the video.
        self.playerView.player?.seekToTime(kCMTimeZero)
    }
}

extension VideoEditorViewController {
    
    private func stopKeyValueObserving(){
        self.playerItem.removeObserver(self, forKeyPath: PlayerItemKeyPathStatus)
    }
    
    private func addTimeObserver(observerKey:TimeObserverKey ,time: CMTime, queue: dispatch_queue_t?, block: (()-> (Void))){
        // already have one time observer for this key, remove it
        if let observer = self.timeObservers[observerKey]{
            self.playerView.player?.removeTimeObserver(observer)
        }
       self.timeObservers[observerKey] = self.playerView.player?.addBoundaryTimeObserverForTimes([NSValue(CMTime: time)], queue: queue, usingBlock: block)
    }
    
    private func removeTimeObservers(){
        for timeObserver in self.timeObservers {
            self.playerView.player?.removeTimeObserver(timeObserver.1)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if (context  == VideoEditorViewController.itemStatusContext){
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.syncUI()
            })
        }
        else{
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
}
