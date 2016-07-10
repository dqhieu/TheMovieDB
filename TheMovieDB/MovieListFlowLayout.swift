//
//  MovieListFlowPlayout.swift
//  TheMovieDB
//
//  Created by Dinh Quang Hieu on 7/10/16.
//  Copyright © 2016 Dinh Quang Hieu. All rights reserved.
//

import UIKit

class MovieListFlowLayout: UICollectionViewFlowLayout {

    //let itemHeight:CGFloat = 562
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    func setupLayout() {
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = .Horizontal
    }
    
    func itemWidth() -> CGFloat {
        return CGRectGetWidth(collectionView!.frame)
    }
    
    func itemHeight() -> CGFloat {
        return self.itemWidth() * 3 / 2 + 40
    }
    
    override var itemSize: CGSize {
        set {
            self.itemSize = CGSizeMake(itemWidth(), itemHeight())
        }
        get {
            return CGSizeMake(itemWidth(), itemHeight())
        }
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
        return collectionView!.contentOffset
    }
    
}
