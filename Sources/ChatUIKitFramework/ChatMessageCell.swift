//
//  ChatMessageCell.swift
//  ChatUIKitFramework
//
//  Created by Aura on 13/06/25.
//

class ChatMessageCell: UITableViewCell {
    let bubbleView = UIView()
    let messageLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)

        bubbleView.layer.cornerRadius = 14
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func configure(with message: ChatMessage) {
        messageLabel.text = message.text
        let isUser = message.isUser

        bubbleView.backgroundColor = isUser ? UIColor.black : UIColor.systemGray6
        messageLabel.textColor = isUser ? .white : .black
        messageLabel.textAlignment = isUser ? .right : .left

        // Layout constraints for left/right bubble
        if isUser {
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = true
        } else {
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
        }

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
