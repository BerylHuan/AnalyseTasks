//
//  SettingViewController.m
//  AnalyseTasks
//
//  Created by 宁丽环 on 2022/9/16.
//

#import "SettingViewController.h"

@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLB;
@property (weak, nonatomic) IBOutlet UILabel *lowLB;
@property (weak, nonatomic) IBOutlet UILabel *lagerLB;
@property (weak, nonatomic) IBOutlet UISlider *lowSlider;
@property (weak, nonatomic) IBOutlet UISlider *lagerSlider;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLB.textAlignment = NSTextAlignmentCenter;
    self.titleLB.font = [UIFont systemFontOfSize:17.0];
    self.titleLB.text = @"设置电量提醒";
    self.lowSlider.value = 60;
    self.lagerSlider.value = 98;
    [self showCunrrentValueWithSlider:self.lowSlider];
    [self showCunrrentValueWithSlider:self.lagerSlider];
}

- (void)showCunrrentValueWithSlider:(UISlider *)slider
{
    if([slider isEqual:self.lowSlider]){
        self.lowLB.text = [NSString stringWithFormat:@"%.0f",slider.value];
    }else if ([slider isEqual:self.lagerSlider]){
        self.lagerLB.text = [NSString stringWithFormat:@"%.0f",slider.value];
    }
}

- (IBAction)lowAction:(UISlider *)sender {
    [self showCunrrentValueWithSlider:sender];
}

- (IBAction)lagerAction:(UISlider *)sender {
    [self showCunrrentValueWithSlider:sender];
}
- (IBAction)finishedAction:(UIButton *)sender {
    if(self.lowBlock){
        self.lowBlock(self.lowSlider.value);
    }
    if(self.lagerBlock){
        self.lagerBlock(self.lagerSlider.value);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
