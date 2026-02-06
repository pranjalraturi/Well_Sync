import DGCharts
import UIKit

class BarValueMarker: MarkerView {

    private let textLabel = UILabel()
    private let padding: CGFloat = 4   // ⭐ 4px padding

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .separator
        layer.cornerRadius = 6
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor

        textLabel.textColor = .black
        textLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        textLabel.textAlignment = .center

        addSubview(textLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {

        textLabel.text = "\(Int(entry.y))"

        textLabel.sizeToFit()

        let width = textLabel.frame.width + padding * 2
        let height = textLabel.frame.height + padding * 2

        self.frame.size = CGSize(width: width, height: height)

        textLabel.frame = CGRect(
            x: padding,
            y: padding,
            width: textLabel.frame.width,
            height: textLabel.frame.height
        )
    }

    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        return CGPoint(x: -(bounds.width / 2), y: -bounds.height - 8)
    }
}
