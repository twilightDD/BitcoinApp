//
//  SOXCoinBalanceCollectionViewCell.h
//  iOS BitcoinApp
//
//  Created by Peter Hauke on 07.03.18.
//  Copyright © 2018 2sox / Peter Hauke. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *SOXCoinBalanceCollectionViewCellReuseIdentifier = @"SOXCoinBalanceCollectionViewCell";

@interface SOXCoinBalanceCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *coinNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *coinAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *euroValueLabel;

@end
