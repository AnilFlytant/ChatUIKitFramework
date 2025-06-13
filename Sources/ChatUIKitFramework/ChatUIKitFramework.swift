// The Swift Programming Language
// https://docs.swift.org/swift-book
// ChatUIKitFramework.swift
// A UIKit-based reusable chat UI framework compatible with Swift projects

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

    public func addMessage(_ message: ChatMessage) {
        messages.append(message)
        tableView.reloadData()
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
            inputContainerBottomConstraint,
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
    }

    private func scrollToBottom() {
        if messages.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
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

//public class ChatMessageCell: UITableViewCell {
//    private let messageLabel = UILabel()
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        messageLabel.numberOfLines = 0
//        messageLabel.font = .systemFont(ofSize: 16)
//        messageLabel.textColor = .black
//        messageLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
//        messageLabel.layer.cornerRadius = 10
//        messageLabel.layer.masksToBounds = true
//        contentView.addSubview(messageLabel)
//        messageLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
//            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
//        ])
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func configure(with message: ChatMessage) {
//        messageLabel.text = message.text
//        messageLabel.textAlignment = message.isUser ? .right : .left
//    }
//}
//
//public struct ChatMessage {
//    public let text: String
//    public let isUser: Bool
//
//    public init(text: String, isUser: Bool) {
//        self.text = text
//        self.isUser = isUser
//    }
//}
