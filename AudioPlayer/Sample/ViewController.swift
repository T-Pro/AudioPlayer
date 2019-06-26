//
//  ViewController.swift
//  Sample
//
//  Created by Pedro Paulo de Amorim on 21/05/2019.
//  Copyright © 2019 Kevin Delannoy. All rights reserved.
//

import UIKit
import AudioPlayer
import AVFoundation

class ViewController: UIViewController, AudioPlayerDelegate {
  
    var part: Int = 0
    var dispatchQueue: DispatchQueue?
    let player = AudioPlayer()

    override func viewDidLoad() {
    super.viewDidLoad()
        player.delegate = self
        
//        let file: URL = URL(string: "")!
//        let item: AudioItem? = AudioItem(mediumQualitySoundURL: file)
//        item?.cachingPlayerItemDelegate = self
//        self.player.play(item: item!)

        let file: URL = readAudioFile(context: self, name: "long", format: "wav")
        let item: AudioItem? = AudioItem(mediumQualitySoundURL: file)
        item?.cachingPlayerItemDelegate = self
        player.play(item: item!)

        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.player.stop()
            let item: AudioItem? = AudioItem(mediumQualitySoundURL: file)
            item?.cachingPlayerItemDelegate = self
            self.player.play(item: item!)
        }

    }
  
    func audioPlayer(_ audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, to state: AudioPlayerState) {
        print("from \(from) to \(state) = \(audioPlayer.currentItemDuration)")
    }

    private func readAudioFile(context: AnyObject, name: String, format: String) -> URL {
        let bundle: Bundle = Bundle(for: type(of: context))
        guard let pathString: String = bundle.path(forResource: name, ofType: format) else {
            fatalError()
        }
        if FileManager.default.fileExists(atPath: pathString) {
            return URL(fileURLWithPath: pathString)
        }
        fatalError()
    }

}

extension ViewController: CachingPlayerItemDelegate {
    
    func playerItemDidFinishDownloadingData(_ playerItem: AVPlayerItem) {
        print("playerItemDidFinishDownloadingData")
        //Append as last dispatch
        dispatchQueue?.sync {
            self.dispatchQueue = nil
            part = 0
        }
    }
    
    func playerItemStartedDownloadingData(_ playerItem: AVPlayerItem) {
        print("playerItemStartedDownloadingData started")
        let url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("cache.wav")
        do {
            try FileManager.default.removeItem(at: url)
            print("playerItemStartedDownloadingData data deleted")
        } catch {
            print(error)
        }
    }
    
    func playerItem(_ playerItem: AVPlayerItem, didDownloadBytesSoFar bytesDownloaded: UInt64, outOf bytesExpected: Int, from data: Data) {
        
        if dispatchQueue == nil {
            part = 0
            dispatchQueue = DispatchQueue(label: "WriterQueue", qos: .userInitiated)
        }
        
        dispatchQueue?.sync {
            print("Writing \(part)")
            autoreleasepool {
                let url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("cache.wav")
                guard let outputStream: OutputStream = OutputStream(url: url, append: true) else {
                    return
                }
                outputStream.open()
                data.withUnsafeBytes { (rawBufferPointer: UnsafeRawBufferPointer) -> Void in
                    let bufferPointer: UnsafeBufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)
                    guard let baseAddress: UnsafePointer = bufferPointer.baseAddress else {
                        return
                    }
                    outputStream.write(baseAddress, maxLength: data.count)
                }
                outputStream.close()
            }
            print("Wrote \(part)")
            part += 1
        }
    }
    
    func playerItemCachePath(_ playerItem: AVPlayerItem) -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("cache.wav")
    }
    
}
