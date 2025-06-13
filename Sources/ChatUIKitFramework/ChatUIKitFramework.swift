// The Swift Programming Language
// https://docs.swift.org/swift-book
// ChatUIKitFramework.swift
// A UIKit-based reusable chat UI framework compatible with Swift projects

import Foundation
import UIKit


public protocol ChatUIKitDelegate: AnyObject {
    func didSendMessage(_ message: String)
}

public struct ChatUIStyle {
    public var userMessageColor: UIColor
    public var agentMessageColor: UIColor
    public var userTextColor: UIColor
    public var agentTextColor: UIColor
    public var font: UIFont
    public var backgroundColor: UIColor

    public init(userMessageColor: UIColor = .blue,
                agentMessageColor: UIColor = .lightGray,
                userTextColor: UIColor = .white,
                agentTextColor: UIColor = .black,
                font: UIFont = .systemFont(ofSize: 16),
                backgroundColor: UIColor = .white) {
        self.userMessageColor = userMessageColor
        self.agentMessageColor = agentMessageColor
        self.userTextColor = userTextColor
        self.agentTextColor = agentTextColor
        self.font = font
        self.backgroundColor = backgroundColor
    }
}


public class ChatUIKitViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    public weak var delegate: ChatUIKitDelegate?
    private var inputContainerBottomConstraint: NSLayoutConstraint?
    private var style: ChatUIStyle

    private var messages: [ChatMessage] = []

    private let tableView = UITableView()
    private let inputContainer = UIView()
    private let inputTextView = UITextView()
    private let attachButton = UIButton(type: .system)
    private let sendButton = UIButton(type: .system)
    private let maxTextViewHeight: CGFloat = 100
    private var inputTextViewHeightConstraint: NSLayoutConstraint!


    public init(style: ChatUIStyle = ChatUIStyle()) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupInputContainer()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToBottom()
    }


    public func addMessage(_ message: ChatMessage) {
        messages.append(message)
        tableView.reloadData()
        scrollToBottom()
    }
    
    public func loadMessages(_ newMessages: [ChatMessage]) {
        messages = newMessages
        tableView.reloadData()
        scrollToBottom()
    }

    public func appendMessage(_ message: ChatMessage) {
        messages.append(message)
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        scrollToBottom()
    }
    
    private func setupUI() {
        view.backgroundColor = style.backgroundColor

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "cell")

        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor)
        ])
    }
    
    
    private func setupInputContainer() {
        inputContainer.backgroundColor = style.backgroundColor
        view.addSubview(inputContainer)
        inputContainer.translatesAutoresizingMaskIntoConstraints = false

        attachButton.setImage(UIImage(systemName: "paperclip"), for: .normal)
        attachButton.tintColor = style.agentTextColor
        attachButton.layer.cornerRadius = 18
        attachButton.backgroundColor = style.agentMessageColor
        attachButton.translatesAutoresizingMaskIntoConstraints = false

        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.tintColor = style.agentTextColor
        sendButton.backgroundColor = style.agentMessageColor
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        inputTextView.font = .systemFont(ofSize: 16)
        inputTextView.isScrollEnabled = false
        inputTextView.layer.borderColor = UIColor.lightGray.cgColor
        inputTextView.layer.borderWidth = 1
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        inputTextView.delegate = self

        inputContainer.addSubview(attachButton)
        inputContainer.addSubview(inputTextView)
        inputContainer.addSubview(sendButton)
        
        inputContainerBottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        inputContainerBottomConstraint?.isActive = true


        NSLayoutConstraint.activate([
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerBottomConstraint!,
            inputContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),

            attachButton.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 8),
            attachButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            attachButton.widthAnchor.constraint(equalToConstant: 36),
            attachButton.heightAnchor.constraint(equalToConstant: 36),

            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 36),
            sendButton.heightAnchor.constraint(equalToConstant: 36),

            inputTextView.leadingAnchor.constraint(equalTo: attachButton.trailingAnchor, constant: 8),
            inputTextView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            inputTextView.topAnchor.constraint(equalTo: inputContainer.topAnchor, constant: 8),
            inputTextView.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: -8)
        ])

        inputTextViewHeightConstraint = inputTextView.heightAnchor.constraint(equalToConstant: 36)
        inputTextViewHeightConstraint.isActive = true

    }
    
    public func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)

        let newHeight = min(estimatedSize.height, maxTextViewHeight)
        inputTextView.isScrollEnabled = estimatedSize.height > maxTextViewHeight
        inputTextViewHeightConstraint.constant = newHeight
    }

    
    @objc private func keyboardWillShow(notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
           let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {

            inputContainerBottomConstraint?.constant = -keyboardFrame.height
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
                self.scrollToBottom()
            }
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        if let userInfo = notification.userInfo,
           let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {

            inputContainerBottomConstraint?.constant = 0
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func sendTapped() {
        let text = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        delegate?.didSendMessage(text)
        inputTextView.text = ""
        inputTextView.resignFirstResponder()
    }

    private func scrollToBottom() {
        guard messages.count > 0 else { return }
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            if self.tableView.numberOfRows(inSection: 0) > indexPath.row {
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }


    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChatMessageCell
        cell.configure(with: messages[indexPath.row], style: style)
        return cell
    }
}

//public class ChatMessageCell: UITableViewCell {
//    private let messageLabel = UILabel()
//    let bubbleView = UIView()
//    private var leadingConstraint: NSLayoutConstraint!
//    private var trailingConstraint: NSLayoutConstraint!
//
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        messageLabel.numberOfLines = 0
//        messageLabel.layer.cornerRadius = 10
//        messageLabel.layer.masksToBounds = true
//        
//        contentView.addSubview(bubbleView)
//        bubbleView.addSubview(messageLabel)
//        
//        bubbleView.layer.cornerRadius = 14
//        messageLabel.numberOfLines = 0
//        messageLabel.font = UIFont.systemFont(ofSize: 16)
//        bubbleView.translatesAutoresizingMaskIntoConstraints = false
//        messageLabel.translatesAutoresizingMaskIntoConstraints = false
//
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    public func configure(with message: ChatMessage, style: ChatUIStyle) {
//        messageLabel.text = message.text
//        messageLabel.textAlignment = message.isUser ? .right : .left
//        messageLabel.font = style.font
//        messageLabel.textColor = message.isUser ? style.userTextColor : style.agentTextColor
//        bubbleView.backgroundColor = message.isUser ? style.userMessageColor : style.agentMessageColor
//
//        // Layout constraints for left/right bubbleAdd commentMore actions
//        if message.isUser {
//            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = true
//        } else {
//            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
//        }
//
//        NSLayoutConstraint.activate([
//            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
//            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
//            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
//            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
//            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
//        ])
//    }
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        leadingConstraint.isActive = false
//        trailingConstraint.isActive = false
//    }
//}


public class ChatMessageCell: UITableViewCell {
    private let messageLabel = UILabel()
    private let bubbleView = UIView()

    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.layer.masksToBounds = true

        bubbleView.layer.cornerRadius = 14
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)

        // Common layout
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width * 0.75),

            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
        ])

        // Alignment constraints
        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(with message: ChatMessage, style: ChatUIStyle) {
        messageLabel.text = message.text
        messageLabel.font = style.font
        messageLabel.textAlignment = message.isUser ? .right : .left
        messageLabel.textColor = message.isUser ? style.userTextColor : style.agentTextColor
        bubbleView.backgroundColor = message.isUser ? style.userMessageColor : style.agentMessageColor

        // Deactivate both, then activate the correct one
        leadingConstraint.isActive = false
        trailingConstraint.isActive = false

        if message.isUser {
            trailingConstraint.isActive = true
        } else {
            leadingConstraint.isActive = true
        }
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        leadingConstraint.isActive = false
        trailingConstraint.isActive = false
    }
}
