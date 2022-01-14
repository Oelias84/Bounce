//
//  CollapsibleSpreadsheetTableViewCell.swift
//  FitApp
//
//  Created by Ofir Elias on 13/01/2022.
//

import UIKit
import SpreadsheetView

enum CollapsibleSpreadsheetType {
	 
	case junkFood
	case conversion
}

class CollapsibleSpreadsheetTableViewCell: UITableViewCell {
	
	var header = [String]()
	var data = [[String]]()
	var sortedColumn = (column: 0, sorting: Sorting.ascending)
	
	var text: String = ""
	private var spreadsheetView: SpreadsheetView = SpreadsheetView()
	
	var type: CollapsibleSpreadsheetType = .junkFood
	
	@IBOutlet weak var cellBackgroundView: UIView!
	@IBOutlet weak var spreadsheetViewContainer: UIView!
	
	enum Sorting {
		case ascending
		case descending
		
		var symbol: String {
			switch self {
			case .ascending:
				return "\u{25B2}"
			case .descending:
				return "\u{25BC}"
			}
		}
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		setupView()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		spreadsheetView.reloadData()
	}
	override func awakeFromNib() {
		super.awakeFromNib()
	}
}
//MARK: - Delegates
extension CollapsibleSpreadsheetTableViewCell: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
	
	// MARK: DataSource
	func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
		return header.count
	}
	func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
		return 1 + data.count
	}
	func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
		switch type {
		case .junkFood:
			if case 0 = column {
				return 100
			} else {
				return 60
			}
		case .conversion:
			return (spreadsheetViewContainer.frame.width-5) / 2
		}

	}
	func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
		if case 0 = row {
			return 40
		} else {
			return 38
		}
	}

	func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
		return 1
	}
	func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
		return 1
	}
	func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
		if case 0 = indexPath.row {
			let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
			cell.label.text = header[indexPath.column]
			
			if case indexPath.column = sortedColumn.column {
				cell.sortArrow.text = sortedColumn.sorting.symbol
			} else {
				cell.sortArrow.text = ""
			}
			cell.setNeedsLayout()
			return cell
		} else {
			let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
			cell.label.text = data[indexPath.row - 1][indexPath.column]
			return cell
		}
	}
	func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
		if case 0 = indexPath.row {
			if sortedColumn.column == indexPath.column {
				sortedColumn.sorting = sortedColumn.sorting == .ascending ? .descending : .ascending
			} else {
				sortedColumn = (indexPath.column, .ascending)
			}
			data.sort {
				let ascending = $0[sortedColumn.column] < $1[sortedColumn.column]
				return sortedColumn.sorting == .ascending ? ascending : !ascending
			}
			spreadsheetView.reloadData()
		}
	}
}

//MARK: - Functions
extension CollapsibleSpreadsheetTableViewCell {
	
	func setupView() {
		cellBackgroundView.cellView()
		spreadsheetView.dataSource = self
		spreadsheetView.delegate = self
		spreadsheetView.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing:HeaderCell.self))
		spreadsheetView.register(TextCell.self, forCellWithReuseIdentifier: String(describing:TextCell.self))
		
		spreadsheetViewContainer.addSubview(spreadsheetView)
		spreadsheetView.frame = CGRect(x: 0, y: 0, width: spreadsheetViewContainer.frame.size.width+10, height: spreadsheetViewContainer.frame.size.height)
		spreadsheetView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
	}
	func setupData(fileName: String) {
		let data = try! String(contentsOf: Bundle.main.url(forResource: fileName, withExtension: "tsv")!,encoding: .utf8)
			.components(separatedBy: "\r\n")
			.map { $0.components(separatedBy: "\t") }
		self.header = data[0]
		self.data = Array(data.dropFirst())
	}
}
