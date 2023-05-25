//
//  MessagingTableView.swift
//  More
//
//  Created by Luko Gjenero on 09/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

private let incomingCell = String(describing: MessagingViewIncomingCell.self)
private let outgoingCell = String(describing: MessagingViewOutgoingCell.self)
private let typingCell = String(describing: MessageViewTypingCell.self)

private extension MessageViewModel {
    var fromMe: Bool {
        return sender.id == ProfileService.shared.profile?.id
    }
}

class MessagingTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

    private var rows: [MessageViewModel] = []
    private var heights: [MessageViewModel: CGFloat] = [:]
    private var lastWidth: CGFloat = 0
    
    private var isAnimating = false
    private var buffer: [MessageViewModel]? = nil
    
    var edit: ((_ message: MessageViewModel)->())?
    
    var isEditable: Bool = false {
        didSet {
            reloadData()
        }
    }

    var timeFormat: String = "h:mm a" {
        didSet {
            reloadData()
        }
    }
    
    var showTyping: Bool = false {
        didSet {
            if !isAnimating {
                setup(for: rows.filter{ !($0.isTyping == true) })
            }
            
            /*
            if showTyping {
                if !rows.contains(where: { $0.isTyping == true }) {
                    rows.append(MessageViewModel(isTyping: true, user: User()))
                    reloadData()
                    if indexPathsForVisibleRows?.contains(IndexPath(row: rows.count-2, section: 0)) == true {
                        scrollToRow(at: IndexPath(row: rows.count - 1, section: 0), at: .bottom, animated: false)
                    }
                }
            } else {
                if let idx = rows.firstIndex(where: { $0.isTyping == true }) {
                    rows.remove(at: idx)
                    reloadData()
                }
            }
            */
        }
    }
    
    var height: CGFloat {
        get {
            return rect(forSection: 0).height + contentInset.top + contentInset.bottom
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setup()
    }
    
    private func setup() {
        
        contentInsetAdjustmentBehavior = .never
        insetsContentViewsToSafeArea = false
        estimatedRowHeight = 0
        estimatedSectionFooterHeight = 0
        estimatedSectionHeaderHeight = 0
        
        register(UITableViewCell.self, forCellReuseIdentifier: "Dummy")
        register(UINib(nibName: incomingCell, bundle: nil), forCellReuseIdentifier: incomingCell)
        register(UINib(nibName: outgoingCell, bundle: nil), forCellReuseIdentifier: outgoingCell)
        register(UINib(nibName: typingCell, bundle: nil), forCellReuseIdentifier: typingCell)
        
        dataSource = self
        delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if lastWidth != bounds.width {
            lastWidth = bounds.width
            clearHeightCache()
            reloadData()
        }
    }
    
    func setup(for rows: [MessageViewModel], forceScrollToBotton: Bool = false) {
        
        guard isAnimating == false else {
            buffer = rows
            return
        }
        
        var sortedRows = rows.sorted { (lhs, rhs) -> Bool in
            return lhs.createdAt < rhs.createdAt
        }
        if showTyping {
            sortedRows.append(MessageViewModel(isTyping: true))
        }
        
        let newRows = sortedRows.filter { !self.rows.contains($0) }
        var reloadedRows: [MessageViewModel] = []
        for old in self.rows {
            if let new = sortedRows.first(where: { $0.id == old.id }) {
                if (old.read == nil && new.read != nil) || (old.delivered == nil && new.delivered != nil) {
                    reloadedRows.append(new)
                }
            }
        }
        
        let reloaded = reloadedRows.map { IndexPath(row: self.rows.firstIndex(of: $0) ?? 0, section: 0) }
        let deleted = self.rows.filter { !sortedRows.contains($0) } .map { IndexPath(row: self.rows.firstIndex(of: $0) ?? 0, section: 0) }
        let inserted = newRows.map { IndexPath(row: self.rows.count - deleted.count + (newRows.firstIndex(of: $0) ?? 0), section: 0) }
        
        let lastIndex = IndexPath(row: self.rows.count - 1, section: 0)
        let scroll = indexPathsForVisibleRows?.contains(lastIndex) == true
        
        self.rows = sortedRows
        
        beginUpdates()
        if reloaded.count > 0 {
            reloadRows(at: reloaded, with: .none)
        }
        if deleted.count > 0 {
            deleteRows(at: deleted, with: .fade)
        }
        if inserted.count > 0 {
            insertRows(at: inserted, with: .left)
        }
        endUpdates()
        
        if scroll || forceScrollToBotton {
            scrollToBottom()
        } else {
            animationStarted()
        }
    }

    func scrollToBottom() {
        guard rows.count > 0 else { return }
        scrollToRow(at: IndexPath(row: rows.count - 1, section: 0), at: .bottom, animated: true)
        animationStarted()
    }
    
    private func animationStarted() {
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.animationEnded()
        }
    }
    
    private func animationEnded() {
        isAnimating = false
        if let buffer = buffer {
            self.buffer = nil
            setup(for: buffer)
        }
    }
    
    // MARK: - tableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let rowModel = rows[indexPath.row]
        let identifier = rowModel.isTyping == true ? typingCell : rowModel.fromMe ? outgoingCell : incomingCell
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? MessagingViewBaseCell {
            cell.timeFormat = timeFormat
            cell.isEditable = isEditable
            cell.setup(for: rowModel)
            cell.editTap = { [weak self] in
                self?.edit?(rowModel)
            }
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "Dummy", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return height(for: rows[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // TODO : - nothig for now
    }
    
    // MARK: - height cache
    
    private func clearHeightCache() {
        heights = [:]
    }
    
    private func height(for model: MessageViewModel) -> CGFloat {
        
        if let height = heights[model] {
            return height
        }
        
        let height = calculateHeight(for: model)
        heights[model] = height
        return height
    }
    
    private func calculateHeight(for model: MessageViewModel) -> CGFloat {
        
        let identifier = model.fromMe ? outgoingCell : incomingCell
        switch identifier {
        case incomingCell:
            return MessagingViewIncomingCell.size(for: model, in: frame.size).height
        case outgoingCell:
            return MessagingViewOutgoingCell.size(for: model, in: frame.size).height
        default:
            return 0
        }
    }
    
    // MARK: - handle messages
    
    func newMessage(_ message: MessageViewModel) {
        if isAnimating {
            buffer?.append(message)
            return
        }
        
        if showTyping {
            rows.insert(message, at: rows.count - 1)
        } else {
            rows.append(message)
        }
        
        let indexPath = IndexPath(row: rows.count - (showTyping ? 2 : 1), section: 0)
        beginUpdates()
        insertRows(at: [indexPath], with: .right)
        endUpdates()
        scrollToBottom()
    }

}
