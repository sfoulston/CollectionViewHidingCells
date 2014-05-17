//
//  GridToExplodedTransitionLayout.m
//  CollectionViewHidingCells
//
//  Created by Stuart Foulston on 17/05/2014.
//  Copyright (c) 2014 Intryss. All rights reserved.
//

#import "GridToExplodedTransitionLayout.h"


@interface GridToExplodedTransitionLayout ()

@property(nonatomic, strong) NSMutableSet *hiddenCellIndexPaths;

@end


@implementation GridToExplodedTransitionLayout

- (instancetype)initWithCurrentLayout:(UICollectionViewLayout *)currentLayout nextLayout:(UICollectionViewLayout *)newLayout
{
	self = [super initWithCurrentLayout:currentLayout nextLayout:newLayout];
	if (self) {
		_hiddenCellIndexPaths = [NSMutableSet set];
	}
	return self;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
	NSArray *layoutAttributes = [super layoutAttributesForElementsInRect:rect];
	
	/* Send a log message for each cell frame whose minX AND maxY lie outside rect. This seems to be the criteria for UICollectionView
	 * hiding cells incorrectly. */
	for (UICollectionViewLayoutAttributes *attr in layoutAttributes) {
		if (CGRectGetMinX(attr.frame) < CGRectGetMinX(rect) && CGRectGetMaxY(attr.frame) > CGRectGetMaxY(rect)) {
			if (![self.hiddenCellIndexPaths containsObject:attr.indexPath]) {
				NSLog(@"Collection view incorrectly hiding cell %lu", (unsigned long)attr.indexPath.item);
			}
			[self.hiddenCellIndexPaths addObject:attr.indexPath];
		} else {
			[self.hiddenCellIndexPaths removeObject:attr.indexPath];
		}
	}
	
	return layoutAttributes;
}

@end
