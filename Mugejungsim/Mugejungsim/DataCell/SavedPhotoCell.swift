import UIKit
import SDWebImage // 네트워크 이미지 로드를 위해 필요


class SavedPhotoCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
         
        contentView.addSubview(imageView)
        contentView.addSubview(textLabel)
        contentView.addSubview(categoryLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            categoryLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 2),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with photoData: PhotoData) {
        // 이미지 로드할 URL
        guard let imageUrl = URL(string: photoData.imagePath) else {
            print("Invalid URL: \(photoData.imagePath)")  // URL이 잘못된 경우
            imageView.image = UIImage(named: "placeholder") // 유효한 URL이 아니면 기본 이미지
            return
        }

        // SDWebImage로 이미지 로드
        imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder")) { (image, error, cacheType, url) in
            if let error = error {
                print("이미지 로드 실패: \(error.localizedDescription)")
            } else {
                print("이미지 로드 성공: \(String(describing: url))")
            }
        }
               
        // 텍스트와 카테고리 설정
//        textLabel.text = photoData.content
//        categoryLabel.text = photoData.categories.joined(separator: ", ")
        
    }
}
