//
//  ViewController.swift
//  BizOTR
//
//  Created by Keanu Freitas on 9/16/20.
//  Copyright © 2020 AppKumu. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    @IBOutlet weak var signUpBtn: UIButton!    
    @IBOutlet weak var loginBtn: UIButton!
    
    var videoPlayer: AVPlayer?
    var videoPLayerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupVideoPlaye()
    }

    func setupElements() {
        
        // Setting the styleds for the button
        Utilities.styleFilledButton(signUpBtn)
        Utilities.styleHollowButton(loginBtn)
    }
    
    func setupVideoPlaye() {
        
        let videoPath = Bundle.main.path(forResource: "Money", ofType: ".mp4")
        
        guard videoPath != nil else {
            return
        }
        
        let url = URL(fileURLWithPath: videoPath!)
        let item = AVPlayerItem(url: url)
        
        videoPlayer = AVPlayer(playerItem: item)
        videoPLayerLayer = AVPlayerLayer(player: videoPlayer)
        videoPLayerLayer?.frame = CGRect(x: -self.view.frame.size.width*1.5, y: 0, width: self.view.frame.size.width*4, height: self.view.frame.size.height)
        
        view.layer.insertSublayer(videoPLayerLayer!, at: 0)
        videoPlayer?.play()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.videoPlayer?.currentItem, queue: .main) { [weak self] _ in
            self?.videoPlayer?.seek(to: CMTime.zero)
            self?.videoPlayer?.play()
        }
    }
}

