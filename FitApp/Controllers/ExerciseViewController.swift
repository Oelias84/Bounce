//
//  ExerciseViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 02/12/2020.
//

import UIKit
import AVKit

class ExerciseViewController: UIViewController {
    
	var exercise: Exercise!
    private let googleManager = GoogleApiManager()
	private var player: AVPlayer!
	private var currentVideoUrl: URL!
	@IBOutlet weak var containerView: UIView!
	
	private var activityIndicator: UIActivityIndicatorView = {
		let aiv = UIActivityIndicatorView()
		aiv.translatesAutoresizingMaskIntoConstraints = false
		aiv.style = .large
		aiv.color = .white
		return aiv
	}()
	private var fullScreenButton: UIButton = {
		let button = UIButton(frame: CGRect(x: 100, y: 100, width: 300,height: 300))
		let image = UIImage(systemName: "arrow.up.left.and.arrow.down.right")?.withRenderingMode(.alwaysTemplate)
		
		button.translatesAutoresizingMaskIntoConstraints = false
		
		button.setTitle("", for: .normal)
		button.imageView?.contentMode = .scaleAspectFit
		button.imageEdgeInsets = UIEdgeInsets(top: 25.0, left: 25.0, bottom: 25.0, right: 25.0)
		button.addTarget(self, action: #selector(playFull), for: .touchUpInside)
		button.setImage(image, for: .normal)
		button.tintColor = .white
		return button
	}()
	
	private var playerContainerView: UIView! {
		didSet {
			playerContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(screenTapped)))
		}
	}

	@IBOutlet weak var textTitleLabel: UILabel!
	@IBOutlet weak var textLabel: UILabel!
	
	override func viewDidLoad() {
	super.viewDidLoad()
	title = exercise.name
	
	setUpPlayerContainerView()
	playActivity()
	playVideo(userString: exercise.videos.first!)
		
		let title = exercise.title
		let string = exercise.text.replacingOccurrences(of: "\\n", with: "\n")
		textTitleLabel.text = title
		textLabel.text = string
}
	
	private func playVideo(userString: String) {

		googleManager.getExerciseVideo(videoNumber: userString ) { result in
                switch result {
                case .success(let url):
                    guard let url = url else { return }
					self.play(url)
                case .failure(let error):
                    print(error)
            }
        }
    }
	private func setUpPlayerContainerView() {
		playerContainerView = UIView()
		playerContainerView.backgroundColor = .black
		containerView.addSubview(playerContainerView)
		playerContainerView.translatesAutoresizingMaskIntoConstraints = false
		playerContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
		playerContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
		playerContainerView.heightAnchor.constraint(equalTo: containerView.heightAnchor ).isActive = true
			
		if #available(iOS 11.0, *) {
			playerContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		} else {
			playerContainerView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor).isActive = true
		}
	}
	private func play(_ url: URL? ) {
		
		if let url = url {
			//2. Create AVPlayer object
			let asset = AVAsset(url: url)
			let playerItem = AVPlayerItem(asset: asset)
			player = AVPlayer(playerItem: playerItem)
			//3. Create AVPlayerLayer object
			let playerLayer = AVPlayerLayer(player: player)
			playerLayer.frame = playerContainerView.bounds //bounds of the view in which AVPlayer should be displayed
			playerLayer.videoGravity = .resizeAspectFill
			
			//4. Add playerLayer to view's layer
			self.playerContainerView.layer.addSublayer(playerLayer)

			//5. Play Video
			player.play()
		}
		getProgress {
			self.activityIndicator.stopAnimating()
			self.playerContainerView.addSubview(self.fullScreenButton)
			self.fullScreenButton.translatesAutoresizingMaskIntoConstraints = false
			self.fullScreenButton.bottomAnchor.constraint(equalTo: self.playerContainerView.bottomAnchor, constant: -25).isActive = true
			self.fullScreenButton.trailingAnchor.constraint(equalTo: self.playerContainerView.trailingAnchor, constant: -25).isActive = true
		}
	}
	private func getProgress(completion: @escaping (() -> Void))  {
		player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2), queue: DispatchQueue.main) {[weak self] (progressTime) in
			if let duration = self?.player.currentItem?.duration {
				
				let durationSeconds = CMTimeGetSeconds(duration)
				let seconds = CMTimeGetSeconds(progressTime)
				let progress = Float(seconds/durationSeconds)
				
				DispatchQueue.main.async {
					if progress >= 0.6 && progress <= 0.61 {
						completion()
					}
				}
			}
		}
	}
	private func playActivity() {
		playerContainerView.addSubview(activityIndicator)
		activityIndicator.centerYAnchor.constraint(equalTo: playerContainerView.centerYAnchor).isActive = true
		activityIndicator.centerXAnchor.constraint(equalTo: playerContainerView.centerXAnchor).isActive = true
		activityIndicator.startAnimating()
	}
	
	@objc func screenTapped() {
		player.seek(to: .zero)
		player.playImmediately(atRate: 1)
	}
	@objc func playFull() {
		let vc = AVPlayerViewController()
		vc.player = self.player

		present(vc, animated: true) {
			vc.player?.seek(to: .zero)
			vc.player?.playImmediately(atRate: 1)
		}
	}

}
