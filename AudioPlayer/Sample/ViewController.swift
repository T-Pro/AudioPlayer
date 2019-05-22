//
//  ViewController.swift
//  Sample
//
//  Created by Pedro Paulo de Amorim on 21/05/2019.
//  Copyright © 2019 Kevin Delannoy. All rights reserved.
//

import UIKit
import AudioPlayer

class ViewController: UIViewController, AudioPlayerDelegate {
  
  let player = AudioPlayer()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    player.delegate = self
    play()
  }
  
  func play() {
    print("############################")
    
    let file: URL = readAudioFile(context: self, name: "short", format: "wav")
    
    let item = AudioItem(mediumQualitySoundURL: file)
    player.play(item: item!)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
      self.play()
    }
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

