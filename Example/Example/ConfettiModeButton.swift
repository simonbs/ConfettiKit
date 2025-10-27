import ConfettiKit
import UIKit

final class ConfettiModeButton: UIButton {
    var onSelectionChange: ((ConfettiMode) -> Void)?
    var selectedMode: ConfettiMode = .topToBottom {
        didSet {
            updateTitle()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMenu()
        updateTitle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupMenu()
        updateTitle()
    }

    private func setupMenu() {
        let actions = ConfettiMode.allCases.map { mode in
            UIAction(title: "\(mode.displayName)", state: mode == selectedMode ? .on : .off) { [weak self] _ in
                self?.selectedMode = mode
                self?.onSelectionChange?(mode)
            }
        }
        menu = UIMenu(options: .singleSelection, children: actions)
        showsMenuAsPrimaryAction = true
        if #available(iOS 16, *) {
            preferredMenuElementOrder = .fixed
        }
    }

    private func updateTitle() {
        setTitle("Mode: \(selectedMode.displayName)", for: .normal)
        setTitleColor(.systemBlue, for: .normal)
    }
}

private extension ConfettiMode {
    var displayName: String {
        switch self {
        case .topToBottom:
            "Top to Bottom"
        case .centerToLeft:
            "Center to Left"
        case .centerToTop:
            "Center to Top"
        case .centerToRight:
            "Center to Right"
        case .centerToBottom:
            "Center to Bottom"
        case .centerToEdges:
            "Center to Edges"
        }
    }
}
