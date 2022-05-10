//
//  MainViewCell.swift
//  ImageLoad(Combine+TableView)
//
//  Created by 오현식 on 2022/05/04.
//

import UIKit

import Then
import SnapKit

class MainViewCell: UITableViewCell {
    
    static let identifier = "MainViewCell"
    
    let imgView = UIImageView().then {
        $0.image = nil
    }
    
    let loadImageLabel = UILabel().then {
        $0.text = "image"
        $0.font = .systemFont(ofSize: UIFont.systemFontSize, weight: .bold).withSize(12)
        $0.textAlignment = .center
        $0.textColor = .white
        $0.backgroundColor = .systemBrown
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraints() {
        
        self.contentView.addSubview(self.imgView)
        self.imgView.snp.makeConstraints {
            $0.top.leading.equalTo(5)
            $0.bottom.equalTo(-5)
            $0.width.equalTo(200)
        }
        
        self.contentView.addSubview(self.loadImageLabel)
        self.loadImageLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(50)
        }
    }
}
