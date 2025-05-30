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
    private var iconLoadTask: Task<Void, Never>?
    
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
        iconLoadTask?.cancel()
        iconImageView.image = nil
    }
}

// MARK: - Configuration
extension ForecastCell {
    /// Настраивает ячейку на основе ViewModel
    /// - Parameter viewModel: Модель представления ячейки прогноза
    func configure(with viewModel: ForecastCellViewModel) {
        dateLabel.text = viewModel.date
        conditionLabel.text = viewModel.condition
        temperatureLabel.text = viewModel.averageTemperature
        windSpeedLabel.text = viewModel.windSpeed
        humidityLabel.text = viewModel.humidity
        
        iconLoadTask = Task {
            do {
                let imageData = try await viewModel.loadIcon()
                guard !Task.isCancelled else { return }
                iconImageView.image = UIImage(data: imageData)
            } catch {
                iconImageView.image = UIImage(systemName: "photo")
                iconImageView.tintColor = .tertiaryLabel
            }
        }
    }
}

// MARK: - Layout
private extension ForecastCell {
    func configureLayout() {
        [dateLabel, iconImageView, textStackView].forEach {
            contentView.addSubview($0)
        }
        
        setupConstraints()
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
            
            textStackView.topAnchor.constraint(equalTo: iconImageView.topAnchor),
            textStackView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: spacing),
            textStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
            
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: iconImageView.bottomAnchor, constant: spacing),
            contentView.bottomAnchor.constraint(equalTo: textStackView.bottomAnchor, constant: spacing)
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
