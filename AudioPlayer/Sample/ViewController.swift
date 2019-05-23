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
  
  let player = AudioPlayer()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    player.delegate = self
    
    let file: URL = URL(string: "URL HERE")!
    let item: AudioItem? = AudioItem(mediumQualitySoundURL: file)
    item?.cachingPlayerItemDelegate = self
    player.play(item: item!)
    
  }
  
  func audioPlayer(_ audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, to state: AudioPlayerState) {
    print("from \(from) to \(state)")
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
    }
    
    func playerItemStartedDownloadingData(_ playerItem: AVPlayerItem) {
        print("playerItemStartedDownloadingData started")
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("cache.wav")
        do {
            try FileManager.default.removeItem(at: url)
            print("playerItemStartedDownloadingData data deleted")
        } catch {
            print(error)
        }
    }
    
    func playerItem(_ playerItem: AVPlayerItem, didDownloadBytesSoFar bytesDownloaded: UInt64, outOf bytesExpected: Int, from data: Data) {
        
        print("downloaded part \(data.count)")
        
        autoreleasepool {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("cache.wav")
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
    }
    
    func playerItemCachePath(_ playerItem: AVPlayerItem) -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("cache.wav")
    }
    
}
