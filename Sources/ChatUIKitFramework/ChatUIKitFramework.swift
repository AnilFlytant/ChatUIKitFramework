// The Swift Programming Language
// https://docs.swift.org/swift-book
// ChatUIKitFramework.swift
// A UIKit-based reusable chat UI framework compatible with Swift projects

import Foundation
import UIKit


public protocol ChatUIKitDelegate: AnyObject {
    func didSendMessage(_ message: String)
}

public class ChatUIKitViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    public weak var delegate: ChatUIKitDelegate?
    private var inputContainerBottomConstraint: NSLayoutConstraint?

    private var messages: [ChatMessage] = []

    private let tableView = UITableView()
    private let inputContainer = UIView()
    private let inputTextView = UITextView()
    private let sendButton = UIButton(type: .system)

    public override func viewDidLoad() {
        super.viewDidLoad()
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
        view.backgroundColor = .white

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "cell")

        inputTextView.delegate = self
        inputTextView.layer.borderColor = UIColor.gray.cgColor
        inputTextView.layer.borderWidth = 1
        inputTextView.layer.cornerRadius = 8

        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        view.addSubview(tableView)
        view.addSubview(inputContainer)
        inputContainer.addSubview(inputTextView)
        inputContainer.addSubview(sendButton)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        inputContainerBottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        inputContainerBottomConstraint?.isActive = true

        NSLayoutConstraint.activate([
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerBottomConstraint!,
            inputContainer.heightAnchor.constraint(equalToConstant: 50),

            inputTextView.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 8),
            inputTextView.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            inputTextView.heightAnchor.constraint(equalToConstant: 36),

            sendButton.leadingAnchor.constraint(equalTo: inputTextView.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),

            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor)
        ])
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
        cell.configure(with: messages[indexPath.row])
        return cell
    }
}

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
