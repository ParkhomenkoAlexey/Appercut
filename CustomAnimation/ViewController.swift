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
        
        view.backgroundColor = .orange
        playVideo()
        
//        playerLayer.frame = CGRect(x: 180, y: 80, width: 240, height: 240)
//        playerLayer.borderColor = UIColor.green.cgColor
//        playerLayer.borderWidth = 2.0
//        playerLayer.cornerRadius = 0
//        playerLayer.backgroundColor = UIColor.systemPink.cgColor
//        playerLayer.masksToBounds = true
//        self.view.layer.addSublayer(playerLayer)
        
//        let animation = self.createPositionAnimation()
//        self.playerLayer.add(animation, forKey: #keyPath(CALayer.position))
//
//        let tanimation = self.createTransformAnimation()
//        self.playerLayer.add(tanimation, forKey: #keyPath(CALayer.transform))
        
    }
    
    private func createPositionAnimation() -> CABasicAnimation {
        let initialValue = playerLayer.position
        let finalValue: CGPoint = CGPoint(x: UIScreen.main.bounds.width - 200, y: UIScreen.main.bounds.height - 200)
        CATransaction.setDisableActions(true)
        playerLayer.position = finalValue
//        playerLayer.sublayers?.first?.position = finalValue
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.position))
        animation.fromValue = initialValue
        animation.toValue = finalValue
        animation.duration = 4
        return animation
    }
    
    private func createTransformAnimation() -> CABasicAnimation {
        let initialValue = playerLayer.transform
        CATransaction.setDisableActions(true)
        playerLayer.transform = CATransform3DMakeScale(0.15, 0.15, 0.15)
//        playerLayer.sublayers?.first?.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        animation.fromValue = initialValue
        animation.toValue = CATransform3DMakeScale(0.15, 0.15, 0.15)
        animation.duration = 4
        return animation
    }
    
    private func createCornerAnimation() -> CABasicAnimation {
        let initialValue: CGFloat = 0
        let finalValue: CGFloat = self.playerLayer.bounds.height / 2
        CATransaction.setDisableActions(true)
        playerLayer.cornerRadius = finalValue
        playerLayer.sublayers?.first?.cornerRadius = finalValue
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.fromValue = initialValue
        animation.toValue = finalValue
        animation.duration = 0.5
        return animation
    }
    
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
                self.playerLayer.add(cornerAnimation, forKey: "cornerRadius")
                self.playerLayer.sublayers?.first?.add(cornerAnimation, forKey: "cornerRadius")
            case 4:
//                let transformAnimation = self.createTransformAnimation()
                let positionAnimation = self.createPositionAnimation()
                
                CATransaction.begin()
//                self.playerLayer.add(transformAnimation, forKey: #keyPath(CALayer.position))
//                self.playerLayer.sublayers?.first?.add(transformAnimation, forKey: #keyPath(CALayer.transform))
                self.playerLayer.add(positionAnimation, forKey: #keyPath(CALayer.position))
                CATransaction.commit()
                
                
                
//                self.playerLayer.sublayers?.first?.add(positionAnimation, forKey: #keyPath(CALayer.position))
                
                
                print ("VIDEO PLAYED FOR 4 SECONDS")
            case 5:
                print ("VIDEO PLAYED FOR 5 SECONDS")
            default:
                break
            }
        }
    }
    
    private func playVideo() {
        guard let path = Bundle.main.path(forResource: "test_1", ofType:"mp4") else {
            debugPrint("test_1.mp4 not found")
            return
        }
        
        self.player = AVPlayer(url: URL(fileURLWithPath: path))
        // UIScreen.main.bounds.height
        self.playerLayer = AVPlayerLayer(player: player)
        self.view.layer.addSublayer(playerLayer)
        self.playerLayer.frame = CGRect(x: 0,
                                        y: 0,
                                        width: UIScreen.main.bounds.height,
                                        height: UIScreen.main.bounds.height)
        self.playerLayer.position = view.center
        self.playerLayer.backgroundColor = UIColor.red.cgColor
        
        self.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        self.player.play()
        self.addPeriodicTimeObserver()
    }
}

