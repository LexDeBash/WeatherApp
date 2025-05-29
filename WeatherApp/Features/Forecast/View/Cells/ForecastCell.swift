//
//  ForecastCell.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 29.05.2025.
//

import UIKit

final class ForecastCell: UITableViewCell {
    
    // MARK: - Subviews
    private let dateLabel = ForecastCell.makeLabel(style: .subheadline, color: .secondaryLabel)
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView.withoutAutoresizingMask()
    }()
    
    private let conditionLabel = ForecastCell.makeLabel(style: .body, lines: 0)
    private let temperatureLabel = ForecastCell.makeLabel(style: .body)
    private let windSpeedLabel = ForecastCell.makeLabel(style: .footnote)
    private let humidityLabel = ForecastCell.makeLabel(style: .footnote)
    
    private lazy var textStackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                conditionLabel,
                temperatureLabel,
                windSpeedLabel,
                humidityLabel
            ]
        )
        stack.axis = .vertical
        stack.spacing = Metrics.Layout.spacing
        return stack.withoutAutoresizingMask()
    }()
    
    // MARK: - Private Properties
    private var currentIconTask: Task<Void, Never>?
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        currentIconTask?.cancel()
        iconImageView.image = nil
    }
    
    // MARK: - Icon Loading
    
    private func loadIcon(from url: URL?) {
        currentIconTask?.cancel()
        iconImageView.image = nil
        
        guard let url = url else { return }
        
        currentIconTask = Task { @MainActor in
            do {
                // TODO: - работа с кешем
            } catch {
                // Игнорируем ошибки загрузки и оставляем placeholder
            }
        }
    }
}

// MARK: - Setup UI
extension ForecastCell {
    /// Настраивает ячейку на основе ViewModel
    /// - Parameter viewModel: Модель представления ячейки прогноза
    func configure(with viewModel: ForecastCellViewModel) {
        dateLabel.text = viewModel.dateText
        conditionLabel.text = viewModel.conditionText
        temperatureLabel.text = viewModel.avgTemperatureText
        windSpeedLabel.text = viewModel.windSpeedText
        humidityLabel.text = viewModel.humidityText
        loadIcon(from: viewModel.iconURL)
    }
}

// MARK: - Layout
private extension ForecastCell {
    func configureLayout() {
        add(subviews: dateLabel, iconImageView, textStackView)
        setupConstraints()
    }
    
    func add(subviews: UIView...) {
        subviews.forEach {
            contentView.addSubview($0)
        }
    }
    
    func setupConstraints() {
        let spacing = Metrics.Layout.spacing
        let iconSize = Metrics.Icon.size
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacing),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
            
            iconImageView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: spacing),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
            iconImageView.widthAnchor.constraint(equalToConstant: iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: iconSize),
            
            textStackView.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            textStackView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: spacing),
            textStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
            
            contentView.bottomAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: spacing)
        ])
    }
}

// MARK: - Helpers
private extension ForecastCell {
    static func makeLabel(style: UIFont.TextStyle, color: UIColor = .label, lines: Int = 1) -> UILabel {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: style)
        label.textColor = color
        label.numberOfLines = lines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}

private extension UIView {
    /// Возвращает представление с отключенным флагом Autoresizing Mask.
    func withoutAutoresizingMask() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}
