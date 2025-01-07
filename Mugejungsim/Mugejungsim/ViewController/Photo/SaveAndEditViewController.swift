//
//  SaveAndEditViewController.swift
//  Mugejungsim
//
//  Created by 도현학 on 12/26/24.
//

import UIKit

class SaveAndEditViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // 스크롤 뷰 선언
    private let scrollView = UIScrollView()
    private let contentView = UIView() // 스크롤뷰 내부 콘텐츠를 담는 뷰
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupScrollView()
        setupCollectionView()
        setupCustomNavigationBar()
    }
    
    private func setupScrollView() {
        scrollView.backgroundColor = .clear
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor) // 가로 고정
        ])
    }
    
    private func setupCollectionView() {
        // 컬렉션 뷰 레이아웃 설정
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8 // 세로 간격
        layout.minimumInteritemSpacing = 8 // 가로 간격
        
        // 컬렉션 뷰 초기화
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // 셀 등록
        collectionView.register(ImageTextCell.self, forCellWithReuseIdentifier: ImageTextCell.identifier)
        
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 800) // 임시 높이 설정
        ])
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20 // 예제: 20개의 아이템
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageTextCell.identifier, for: indexPath) as! ImageTextCell
        cell.configure(image: UIImage(systemName: "photo"), text: "Item \(indexPath.item + 1)") // 임시 이미지와 텍스트 설정
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 8 // 간격
        let totalSpacing = spacing * 3 // 가로 4개의 셀, 3개의 간격
        let width = (collectionView.bounds.width - totalSpacing) / 4
        return CGSize(width: width, height: width + 20) // 텍스트 높이를 포함하여 셀의 높이 설정
    }
    
    private func setupCustomNavigationBar() {
        let navBar = UIView()
        navBar.backgroundColor = .white
        navBar.translatesAutoresizingMaskIntoConstraints = false
        
        let separator = UIView()
        separator.backgroundColor = .lightGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "back_button"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(navBar)
        navBar.addSubview(separator)
        navBar.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 40),
            
            separator.bottomAnchor.constraint(equalTo: navBar.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 24),
            separator.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -24),
            separator.heightAnchor.constraint(equalToConstant: 0.3),
            
            backButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 24),
        ])
    }
    
    @objc private func didTapBackButton() {
        print("backButton 누름")
//        let stopWritingVC = StopWritingViewController()
//        stopWritingVC.modalTransitionStyle = .crossDissolve
//        stopWritingVC.modalPresentationStyle = .overFullScreen
//        self.present(stopWritingVC, animated: true, completion: nil)
    }
}

// MARK: - ImageTextCell 클래스 정의
class ImageTextCell: UICollectionViewCell {
    
    static let identifier = "ImageTextCell"
    private let imageView = UIImageView()
    private let textLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        textLabel.textAlignment = .center
        textLabel.font = UIFont.systemFont(ofSize: 12)
        textLabel.textColor = .darkGray
        contentView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(image: UIImage?, text: String) {
        imageView.image = image
        textLabel.text = text
    }
}
