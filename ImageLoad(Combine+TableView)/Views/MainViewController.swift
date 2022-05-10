//
//  MainViewController.swift
//  ImageLoad(Combine+TableView)
//
//  Created by 오현식 on 2022/05/04.
//

import Combine
import UIKit

import Then
import SnapKit

class MainViewController: UIViewController {
    
    private var viewModel = ViewModel()
    
    private var cellImgae = [UIImage?]()
    
    private var cancelBag = Set<AnyCancellable>()
    
    let titleLabel = UILabel().then {
        $0.text = "Combine 스터디 중 ~~"
        $0.textColor = .systemMint
        $0.font = .systemFont(ofSize: UIFont.systemFontSize, weight: .bold).withSize(30)
        $0.textAlignment = .center
    }
    
    let tableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.register(MainViewCell.self, forCellReuseIdentifier: MainViewCell.identifier)
        $0.rowHeight = 100
    }
    
    let addCellButton = UIButton().then {
        $0.setTitle("+", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: UIFont.systemFontSize, weight: .bold).withSize(25)
        $0.setBackgroundColor(.systemBlue, for: .normal)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    let editCellButton = UIButton().then {
        $0.setTitle("edit", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: UIFont.systemFontSize, weight: .bold).withSize(16)
        $0.setBackgroundColor(.systemGreen, for: .normal)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    let activityIndicator = UIActivityIndicatorView().then {
        $0.style = .large
    }

    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setConstraints()
        self.buttonTapActions()
        self.updateState()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    private func setConstraints() {
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(25)
        }
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.view.addSubview(self.addCellButton)
        self.addCellButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-50)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(50)
        }
        
        self.view.addSubview(self.editCellButton)
        self.editCellButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-50)
            $0.leading.equalTo(self.addCellButton.snp.trailing).offset(10)
            $0.width.height.equalTo(50)
        }
        
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
    }
    
    
    // MARK: - Action

    private func buttonTapActions() {
        
        self.addCellButton.addTarget(
            self,
            action: #selector(self.onAddCellButtonTapped),
            for: .touchUpInside
        )
        
        self.editCellButton.addTarget(
            self,
            action: #selector(onEditCellButtonTapped),
            for: .touchUpInside
        )
    }
    
    @objc
    func onAddCellButtonTapped() {
        self.cellImgae.append(nil)
        self.tableView.reloadData()
    }
    
    @objc
    func onEditCellButtonTapped() {
        if self.tableView.isEditing {
            self.editCellButton.setTitle("Edit", for: .normal)
            self.tableView.setEditing(false, animated: true)
        } else {
            self.editCellButton.setTitle("Done", for: .normal)
            self.tableView.setEditing(true, animated: true)
        }
    }
    
    
    // MARK: - State
    
    private func updateState() {
        
        self.viewModel.image
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] images in
                for idx in 0..<images.count {
                    if let image = images[idx] {
                        self?.cellImgae[idx] = image
                    }
                }
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
            }).store(in: &self.cancelBag)
    }
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.activityIndicator.startAnimating()
        self.viewModel.loadImage(cellCount: self.cellImgae.count-1, cellIndex: indexPath.row)
    }
    
    // 셀 삭제
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MainViewCell.identifier,
            for: indexPath
        ) as? MainViewCell else { return UITableViewCell() }
        
        cell.selectionStyle = .none
        
        cell.imgView.image = self.cellImgae[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellImgae.count
    }
    
    // 셀 삭제
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            self.cellImgae.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // 셀 이동
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedImage = self.cellImgae[sourceIndexPath.row]
        self.cellImgae.remove(at: sourceIndexPath.row)
        self.cellImgae.insert(movedImage, at: destinationIndexPath.row)
    }
}
