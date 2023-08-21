//
//  ExerciseViewController.swift
//  FitApp
//
//  Created by iOS Bthere on 02/12/2020.
//

import UIKit
import AVKit

class ExerciseViewController: UIViewController {
	
	public var exercise: Exercise!
	private var player: AVPlayer!
	private var urlVideos: [URL]!
	private var currentVideoUrlIndex = 0
	private let fullViewPlayer = AVPlayerViewController()

	private let googleManager = GoogleApiManager()
	
	private var playerContainerView: UIView!
	@IBOutlet weak var containerView: UIView!
	@IBOutlet weak var topBarView: BounceNavigationBarView!

	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var forwardButton: UIButton!
	@IBOutlet weak var backwardsButton: UIButton!
	
	@IBOutlet weak var fullScreenButton: UIButton!
	@IBOutlet weak var videoPageIndicator: UIPageControl!
	
	private var activityIndicator: UIActivityIndicatorView = {
		let aiv = UIActivityIndicatorView()
		aiv.translatesAutoresizingMaskIntoConstraints = false
		aiv.style = .large
		aiv.color = .white
		return aiv
	}()
	
	@IBOutlet weak var textTitleLabel: UILabel!
	@IBOutlet weak var textLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupTopBarView()
		
		let title = exercise.title
		let string = exercise.getExerciseText.replacingOccurrences(of: "\\n", with: "\n")
		textTitleLabel.text = title
		textLabel.text = string
		
		setUpPlayerContainerView()
		shouldHideButtons(true)
		playActivity()
		playVideo(for: exercise.videos)
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		topBarView.setImage()
	}
	
	@IBAction func playButtonAction(_ sender: Any) {
		let playerTimescale = self.player.currentItem?.asset.duration.timescale ?? 1
		let time =  CMTime(seconds: 1, preferredTimescale: playerTimescale)
		
		player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
			DispatchQueue.main.async {
				self.playButton.isHidden = true
				self.player.play()
			}
		}
	}
	@IBAction func forwardButtonAction(_ sender: Any) {
		player?.pause()
		playButton.isHidden = true
		activityIndicator.startAnimating()
		
		if currentVideoUrlIndex == urlVideos.count-1 {
			return
		}
		
		backwardsButton.isHidden = false
		currentVideoUrlIndex += 1
		videoPageIndicator.currentPage = currentVideoUrlIndex
		play(urlVideos[currentVideoUrlIndex])
	}
	@IBAction func backwardsButtonAction(_ sender: Any) {
		player.pause()
		playButton.isHidden = true
		activityIndicator.startAnimating()
		
		if currentVideoUrlIndex == 0 {
			return
		}
		
		backwardsButton.isHidden = false
		currentVideoUrlIndex -= 1
		if currentVideoUrlIndex == 0 { backwardsButton.isHidden = true }
		videoPageIndicator.currentPage = currentVideoUrlIndex
		play(urlVideos[currentVideoUrlIndex])
	}
	@IBAction func fullScreenButtonAction(_ sender: Any) {
		playFull()
	}
}

//MARK: - Delegate
extension ExerciseViewController: AVPlayerViewControllerDelegate {
	
	func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		playButton.isHidden = false
		let playerTimescale = self.player.currentItem?.asset.duration.timescale ?? 1
		let time =  CMTime(seconds: 1, preferredTimescale: playerTimescale)
		player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
			self.player.play()
		}
	}
}
extension ExerciseViewController: BounceNavigationBarDelegate {
	
	func backButtonTapped() {
		navigationController?.popViewController(animated: true)
	}
}

//MARK: - Functions
extension ExerciseViewController {
	
	private func play(_ url: URL) {
		playActivity()
		
		let asset = AVAsset(url: url)
		player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
		
		let playerLayer = AVPlayerLayer(player: player)
		let playerTimescale = self.player.currentItem?.asset.duration.timescale ?? 1
		let time = CMTime(seconds: 0, preferredTimescale: playerTimescale)
		
		playerLayer.frame = playerContainerView.bounds
		playerLayer.videoGravity = .resizeAspectFill
		playerContainerView.layer.addSublayer(playerLayer)
		
		getProgress()
		self.player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { (finished) in
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				self.player.play()
				self.shouldHideButtons(false)
			}
		}
	}
	private func getProgress()  {
		player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 10), queue: DispatchQueue.main) {
			[weak self] (progressTime) in
			if let duration = self?.player.currentItem?.duration {

				let durationSeconds = CMTimeGetSeconds(duration)
				let seconds = CMTimeGetSeconds(progressTime)
				let progress = Float(seconds/durationSeconds)

				if progress >= 0.0, progress <= 0.01 {
					self?.activityIndicator.stopAnimating()
				}
				if progress >= 1.0 {
					self?.playButton.isHidden = false
				}
			}
		}
	}
	private func playActivity() {
        activityIndicator.removeFromSuperview()
		playerContainerView.addSubview(activityIndicator)
		activityIndicator.centerYAnchor.constraint(equalTo: playerContainerView.centerYAnchor).isActive = true
		activityIndicator.centerXAnchor.constraint(equalTo: playerContainerView.centerXAnchor).isActive = true
		activityIndicator.startAnimating()
	}
	private func setupTopBarView() {
		topBarView.nameTitle = exercise.name
		topBarView.delegate = self
		topBarView.isBackButtonHidden = false
		topBarView.isMotivationHidden = true
		topBarView.isDayWelcomeHidden = true
	}
	private func setUpPlayerContainerView() {
		let buttonSize = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)

		if exercise.videos.count == 1 {
			forwardButton.isHidden = true
			backwardsButton.isHidden = true
		}
		forwardButton.imageView?.contentMode = .scaleAspectFit
		backwardsButton.imageView?.contentMode = .scaleAspectFit
		forwardButton.imageEdgeInsets = buttonSize
		backwardsButton.imageEdgeInsets = buttonSize
		
		videoPageIndicator.numberOfPages = exercise.videos.count
		
		playerContainerView = UIView()
		playerContainerView.backgroundColor = .black
		containerView.insertSubview(playerContainerView, at: 0)
		
		playerContainerView.translatesAutoresizingMaskIntoConstraints = false
		playerContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
		playerContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
		playerContainerView.heightAnchor.constraint(equalTo: containerView.heightAnchor ).isActive = true
	}
	private func playVideo(for exerciseNumbers: [String]) {
		playButton.isHidden = true
		
        googleManager.getExerciseVideosURL(exerciseType: exercise.type, videosArray: exerciseNumbers) {
			result in
			switch result {
			case .success(let urls):
				DispatchQueue.main.async {
					self.urlVideos = urls
					self.play(self.urlVideos.first!)
				}
			case .failure(let error):
				print(error)
			}
		}
	}
	private func shouldHideButtons(_ isHidden: Bool) {
		DispatchQueue.main.async {
			if isHidden {
				[self.fullScreenButton, self.videoPageIndicator].forEach { $0?.fadeOut() }
			} else {
				[self.fullScreenButton, self.videoPageIndicator].forEach { $0?.fadeIn() }
			}
		}
	}
	@objc func playFull() {
		fullViewPlayer.player = self.player
		fullViewPlayer.delegate = self
		
		present(fullViewPlayer, animated: true) {
			let playerTimescale = self.player.currentItem?.asset.duration.timescale ?? 1
			let time = CMTime(seconds: 1, preferredTimescale: playerTimescale)
			
			self.fullViewPlayer.player!.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
		}
	}
}
