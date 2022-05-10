//
//  ViewModel.swift
//  ImageLoad(Combine+TableView)
//
//  Created by 오현식 on 2022/05/04.
//

import UIKit

import Combine

class ViewModel {
    
    var image = PassthroughSubject<[UIImage?], Never>()
    
    private var cancelBag = Set<AnyCancellable>()
    
    func loadImage(cellCount: Int, cellIndex: Int) {
        asyncLoadImage() { [weak self] image in
            guard let self = self, let image = image else { return }
            var cellImage = [UIImage?](repeating: nil, count: cellCount)
            cellImage.insert(image, at: cellIndex)
            self.image.send(cellImage)
        }
    }
}

// 이미지 로드 (1. 동기 2. 비동기)
extension ViewModel {
    
    private func syncLoadImage(from imageUrl: String) -> UIImage? {
        guard let url = URL(string: imageUrl),
              let data = try? Data(contentsOf: url) else { return nil }
        
        let image = UIImage(data: data)
        return image
    }
    
    func asyncLoadImage(completion: @escaping (UIImage?) -> Void) {
        let LARGE_IMAGE_URL = "https://picsum.photos/1024/768/?random"
        
        DispatchQueue.global().async {
            let image = self.syncLoadImage(from: LARGE_IMAGE_URL)
            completion(image)
        }
    }
}
