//
//  PatientNoteCollectionViewCell.swift
//  wellSync
//
//  Created by Rishika Mittal on 13/03/26.
//

import UIKit

class PatientNoteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var noteNumber: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var noteDate: UILabel!
    @IBOutlet weak var note: UILabel!
    func configure(with patient: PatientNote,index:Int)
    {
        noteNumber.text = "Note \(index+1)"
        var title:String{
            let temp = patient.note.split(separator: " ")
            var s = ""
            if temp.count > 4{
                for i in 0..<4{
                    s += temp[i] + " "
                }
            }
            return s
        }
        noteLabel.text = title
        note.text = patient.note
        noteDate.text = patient.date.formatted(date: .numeric, time: .omitted)
    }
}
