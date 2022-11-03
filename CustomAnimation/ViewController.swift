//
//  ViewController.swift
//  CustomAnimation
//
//  Created by Алексей on 03.11.2022.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    var playerLayer: AVPlayerLayer = AVPlayerLayer()
    var player = AVPlayer()
    var timeObserverToken: Any?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        playVideo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removePeriodicTimeObserver()
    }
    
    // MARK: - CALuaer Animations Setup
    private func createTransformandPositionAnimations() -> (CABasicAnimation,CABasicAnimation) {
        let transformInitialValue = playerLayer.transform
        
        let positionInitialValue = playerLayer.position
        let positionFinalValue: CGPoint = CGPoint(x: UIScreen.main.bounds.width - 100, y: UIScreen.main.bounds.height - 100)
        
        CATransaction.setDisableActions(true)
        playerLayer.position = positionFinalValue
        playerLayer.transform = CATransform3DMakeScale(0.15, 0.15, 0.15)
        
        let positionAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.position))
        positionAnimation.fromValue = positionInitialValue
        positionAnimation.toValue = positionFinalValue
        positionAnimation.duration = 4
        
        let transformAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        transformAnimation.fromValue = transformInitialValue
        transformAnimation.toValue = CATransform3DMakeScale(0.15, 0.15, 0.15)
        transformAnimation.duration = 4
        return (transformAnimation, positionAnimation)
    }
    
    private func createCornerAnimation() -> CABasicAnimation {
        let initialValue: CGFloat = 0
        let finalValue: CGFloat = self.playerLayer.bounds.height / 2
        CATransaction.setDisableActions(true)
        playerLayer.cornerRadius = finalValue
        playerLayer.sublayers?.first?.cornerRadius = finalValue
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
        animation.fromValue = initialValue
        animation.toValue = finalValue
        animation.duration = 0.5
        return animation
    }
    
    // MARK: - Timer Setup
    private func addPeriodicTimeObserver() {
        
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1, preferredTimescale: timeScale)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time,
                                                          queue: .main) { [weak self] time in
            guard let self = self else { return }
            let seconds = CMTimeGetSeconds(time)
            let intSeconds: Int = Int(seconds)
            
            switch intSeconds {
            case 3:
                let cornerAnimation = self.createCornerAnimation()
                self.playerLayer.add(cornerAnimation, forKey: #keyPath(CALayer.cornerRadius))
                self.playerLayer.sublayers?.first?.add(cornerAnimation, forKey: #keyPath(CALayer.cornerRadius))
            case 4:
                let animations = self.createTransformandPositionAnimations()
                
                self.playerLayer.add(animations.0, forKey: #keyPath(CALayer.transform))
                self.playerLayer.add(animations.1, forKey: #keyPath(CALayer.position))
            default:
                break
            }
        }
    }
    
    private func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    // MARK: - AVPlayer Setup
    private func playVideo() {
        guard let path = Bundle.main.path(forResource: "test_1", ofType:"mp4") else {
            debugPrint("test_1.mp4 not found")
            return
        }
        
        self.player = AVPlayer(url: URL(fileURLWithPath: path))
        self.playerLayer = AVPlayerLayer(player: player)
        self.view.layer.addSublayer(playerLayer)
        self.playerLayer.frame = CGRect(x: 0,
                                        y: 0,
                                        width: UIScreen.main.bounds.height,
                                        height: UIScreen.main.bounds.height)
        self.playerLayer.position = view.center
        self.playerLayer.backgroundColor = UIColor.white.cgColor
        
        self.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        self.player.play()
        self.addPeriodicTimeObserver()
    }
}

