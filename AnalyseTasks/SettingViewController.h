//
//  SettingViewController.h
//  AnalyseTasks
//
//  Created by 宁丽环 on 2022/9/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^LowBatteryBlock)(CGFloat level);
typedef void (^LagerBatteryBlock)(CGFloat level);

@interface SettingViewController : UIViewController
@property (nonatomic,copy)LowBatteryBlock lowBlock;
@property (nonatomic,copy)LagerBatteryBlock lagerBlock;

@end

NS_ASSUME_NONNULL_END
