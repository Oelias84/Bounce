//
//  AdminMenuTableViewCell.swift
//  FitApp
//
//  Created by Ofir Elias on 18/05/2022.
//

import UIKit
import Combine

class AdminUserMenuTableViewCell: UITableViewCell {
    
    //    private var chat: Chat!
    private var viewModel: UserViewModel!
    
    private var cancellable: AnyCancellable?
    private var animator: UIViewPropertyAnimator?
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var lastSeenImageView: UIImageView!
    @IBOutlet weak var isExpiredImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var messageButton: UIButton!
    
    @IBOutlet weak var experationDateLabel: UILabel!
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }
    
    @IBAction private func messageButtonAction(_ sender: Any) {
        moveToChatContainerVC()
    }
}

extension AdminUserMenuTableViewCell {
    
    func resetCell() {
        lastSeenImageView.isHidden = true
        isExpiredImageView.isHidden = true
        experationDateLabel.isHidden = true
        
        userImageView.image = nil
        lastSeenImageView.image = nil
        isExpiredImageView.image = nil
        isExpiredImageView.tintColor = nil
        
        userImageView.alpha = 0.0
        animator?.stopAnimation(true)
        cancellable?.cancel()
    }
    public func configure(with vm: UserViewModel) {
        self.viewModel = vm
        
        //User name
        if let userName = viewModel.userName {
            userNameLabel.text = userName
            userNameLabel.textColor = .black
        } else {
            userNameLabel.text = "שם לא נמצא"
            userNameLabel.textColor = .red
        }
        
        //Profile Image
        cancellable = loadImage(for: viewModel.imagePath).sink {
            [weak self] image in
            self?.showImage(image: image)
        }
        
        switch viewModel.programState {
        case .active:
            break
        case .expire, nil:
            let image = UIImage(systemName: "clock.badge.exclamationmark")?.withRenderingMode(.alwaysTemplate)
            isExpiredImageView.isHidden = false
            isExpiredImageView.image = image
            isExpiredImageView.tintColor = .red
        case .expireSoon:
            let image = UIImage(systemName: "clock.badge.exclamationmark")
            isExpiredImageView.isHidden = false
            isExpiredImageView.image = image
            experationDateLabel.isHidden = false
            experationDateLabel.text = viewModel.programExperationDatedisplay
            setNeedsLayout()
        }
        
        //Last seen Image
        if viewModel.wasSeenLately == true || (viewModel.programState == .expire || viewModel.programState == nil) {
            lastSeenImageView.isHidden = true
        } else {
            lastSeenImageView.isHidden = false
            lastSeenImageView.image = UIImage(systemName: "person.fill.questionmark")
        }
        
        //Message image
        if viewModel.didReadLastMessage == true {
            messageButton.setImage(UIImage(systemName: "message"), for: .normal)
        } else {
            messageButton.setImage(UIImage(systemName: "message.fill"), for: .normal)
        }
    }
    
    fileprivate func showImage(image: UIImage?) {
        userImageView.alpha = 0.0
        animator?.stopAnimation(false)
        userImageView.image = image
        animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.userImageView.alpha = 1.0
        })
    }
    fileprivate func loadImage(for url: URL?) -> AnyPublisher<UIImage?, Never> {
        return Just(url).flatMap { poster -> AnyPublisher<UIImage?, Never> in
            guard let url else {
                return Just(UIImage(systemName:"person.circle")).eraseToAnyPublisher()
            }
            return ImageLoader.shared.loadImage(from: url)
        }.eraseToAnyPublisher()
    }
    fileprivate func moveToChatContainerVC() {
        let chatVC = ChatViewController(viewModel: viewModel.chatViewModel)
        parentViewController?.navigationController?.show(chatVC, sender: nil)
    }
}
