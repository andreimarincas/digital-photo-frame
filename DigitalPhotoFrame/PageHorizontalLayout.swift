//
//  PageHorizontalLayout.swift
//  DigitalPhotoFrame
//
//  Created by Andrei Marincas on 1/7/18.
//  Copyright © 2018 Andrei Marincas. All rights reserved.
//

import UIKit

protocol CollectionViewLayoutDelegate: class {
    
    var preferredCollectionViewFrame: CGRect { get }
}

class PageHorizontalLayout: UICollectionViewLayout {
    
    var lineSpacing: CGFloat = 40
    var interitemSpacing: CGFloat = 90
    var itemSize: CGSize = CGSize(width: 135, height: 175)
    var columnCount: Int = 4
    var rowCount: Int = 3
    
    var collectionViewFrame: CGRect {
        return (collectionView?.delegate as? CollectionViewLayoutDelegate)!.preferredCollectionViewFrame
    }
    
    var collectionViewWidth: CGFloat {
        return collectionViewFrame.size.width
    }
    var collectionViewHeight: CGFloat {
        return collectionViewFrame.size.height
    }
    
    private var allLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    
    override func prepare() {
        super.prepare()
        guard let collectionView = self.collectionView else { return }
        
        self.allLayoutAttributes = []
        
        let sectionItemCount: Int = collectionView.numberOfItems(inSection: 0)
        for i in 0..<sectionItemCount {
            let indexPath = IndexPath(item: i, section: 0)
            let layoutAttributes = self.layoutAttributesForItem(at: indexPath)
            self.allLayoutAttributes.append(layoutAttributes!)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.allLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let pageItemCount: Int = self.rowCount * self.columnCount
        let currentPage: Int = indexPath.row / pageItemCount
        let currentLine: Int = (indexPath.row - currentPage * pageItemCount) / self.columnCount
        let currentColumn: Int = indexPath.row % self.columnCount
        let pageWidth: CGFloat = CGFloat(self.columnCount) * self.itemSize.width + CGFloat(self.columnCount - 1) * self.interitemSpacing
        let marginLeft: CGFloat = (collectionViewWidth - pageWidth) / 2
        let pageHeight: CGFloat = CGFloat(self.rowCount) * self.itemSize.height + CGFloat(self.rowCount - 1) * self.lineSpacing
        let marginTop: CGFloat = (collectionViewHeight - pageHeight) / 2
        layoutAttributes.frame = CGRect(x: CGFloat(currentPage) * collectionViewWidth + marginLeft + CGFloat(currentColumn) * (self.itemSize.width + self.interitemSpacing),
                                        y: marginTop + CGFloat(currentLine) * (self.itemSize.height + self.lineSpacing),
                                        width: self.itemSize.width,
                                        height: self.itemSize.height)
        return layoutAttributes
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: CGFloat(self.pageCount) * self.collectionViewWidth, height: self.collectionViewHeight)
    }
    
    var pageCount: Int {
        guard let collectionView = self.collectionView else {
            return 0
        }
        let sectionItemCount: Int = collectionView.numberOfItems(inSection: 0)
        let pageItemCount: Int = self.rowCount * self.columnCount
        return (sectionItemCount + pageItemCount - 1) / pageItemCount
    }
}
