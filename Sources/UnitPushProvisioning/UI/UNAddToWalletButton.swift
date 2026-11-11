//
//  UNAddToWalletButton.swift
//  UnitPushProvisioning
//

import PassKit
import UIKit

public final class UNAddToWalletButton: UIView {
    public var onTap: (() -> Void)?

    public override var intrinsicContentSize: CGSize {
        return passButton.intrinsicContentSize
    }

    private let passButton = PKAddPassButton(addPassButtonStyle: .black)

    init(onTap: (() -> Void)?) {
        self.onTap = onTap
        super.init(frame: .zero)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
}

private extension UNAddToWalletButton {
    func setupViews() {
        passButton.translatesAutoresizingMaskIntoConstraints = false
        passButton.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        addSubview(passButton)
        NSLayoutConstraint.activate([
            passButton.topAnchor.constraint(equalTo: topAnchor),
            passButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            passButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            passButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    @objc func didTap() {
        onTap?()
    }
}
