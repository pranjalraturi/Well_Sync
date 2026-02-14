//
//  BarChartCollectionViewCell.swift
//  wellSync
//
//  Created by Vidit Agarwal on 04/02/26.
//

import UIKit
import DGCharts

class MoodChartCollectionViewCell: UICollectionViewCell, ChartViewDelegate{

    @IBOutlet weak var moodChartView: LineChartView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        moodChart()
    }
    func moodChart(){
        
    }
}
