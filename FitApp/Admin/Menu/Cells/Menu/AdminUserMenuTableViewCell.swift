//
//  AdminMenuTableViewCell.swift
//  FitApp
//
//  Created by Ofir Elias on 18/05/2022.
//

import UIKit
import Combine

protocol AdminUserMenuTableViewCellDelegate: AnyObject {
    func broadcastButtonTapped(userViewModel: UserViewModel)
}

class AdminUserMenuTableViewCell: UITableViewCell {
    
    private var viewModel: UserViewModel!
    
    private var cancellable: AnyCancellable?
    private var animator: UIViewPropertyAnimator?
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var lastSeenImageView: UIImageView!
    @IBOutlet weak var isExpiredImageView: UIImageView!
    @IBOutlet weak var unreadCommentImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var broadcastButton: UIButton!
    
    @IBOutlet weak var experationDateLabel: UILabel!
    
    weak var delegate: AdminUserMenuTableViewCellDelegate?
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }
    
    @IBAction private func messageButtonAction(_ sender: Any) {
        moveToChatContainerVC()
    }
    @IBAction func broadcastButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        viewModel.shouldBroadcast.toggle()
        delegate?.broadcastButtonTapped(userViewModel: viewModel)
    }
}

extension AdminUserMenuTableViewCell {
    
    func resetCell() {
        lastSeenImageView.isHidden = true
        isExpiredImageView.isHidden = true
        experationDateLabel.isHidden = true
        unreadCommentImageView.isHidden = true
        
        userImageView.image = nil
        lastSeenImageView.image = nil
        isExpiredImageView.image = nil
        isExpiredImageView.tintColor = nil
        
        userImageView.alpha = 0.0
        animator?.stopAnimation(true)
        cancellable?.cancel()
    }
    func animateCellBroadcastButton() {
        DispatchQueue.main.async {
            if self.viewModel.shouldShowBrodcast {
                self.broadcastButton.isHidden = false
                self.broadcastButton.alpha = 1
            } else {
                self.broadcastButton.alpha = 0
                self.broadcastButton.isHidden = true
            }
            self.setNeedsLayout()
        }
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
        if viewModel.imagePath != nil {
            cancellable = loadImage(for: viewModel.imagePath).sink {
                [weak self] image in
                self?.showImage(image: image)
            }
        } else {
            userImageView.alpha = 1.0
            userImageView.image = UIImage(systemName:"person.circle")
        }
        
        //Last seen Image
        if let programState = viewModel.programState, programState == .expire {
            DispatchQueue.main.async {
                self.lastSeenImageView.isHidden = true
            }
        } else if let wasSeenLately = viewModel.wasSeenLately {
            lastSeenImageView.image = UIImage(systemName: "person.fill.questionmark")
            DispatchQueue.main.async {
                self.lastSeenImageView.isHidden = wasSeenLately
            }
        } else {
            DispatchQueue.main.async {
                self.lastSeenImageView.isHidden = true
            }
        }
        
        switch vm.programState {
        case .active:
            break
        case .expire, nil:
            let image = UIImage(systemName: "clock.badge.exclamationmark")?.withRenderingMode(.alwaysTemplate)
            isExpiredImageView.image = image
            isExpiredImageView.tintColor = .red
            
            DispatchQueue.main.async {
                self.isExpiredImageView.isHidden = false
            }
        case .expireSoon:
            let image = UIImage(systemName: "clock.badge.exclamationmark")
            isExpiredImageView.image = image
            experationDateLabel.text = vm.programExperationDatedisplay
            
            DispatchQueue.main.async {
                self.isExpiredImageView.isHidden = false
                self.experationDateLabel.isHidden = false
            }
        }

        //Message image
        if viewModel.didReadLastMessage == true {
            messageButton.setImage(UIImage(systemName: "message"), for: .normal)
        } else {
            messageButton.setImage(UIImage(systemName: "message.fill"), for: .normal)
        }
        
        //Uneread cpmment
        DispatchQueue.main.async {
            self.unreadCommentImageView.isHidden = !self.viewModel.showUnreadComment
        }
        
        //Broadcast
        broadcastButton.isSelected = vm.shouldBroadcast
        animateCellBroadcastButton()
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
