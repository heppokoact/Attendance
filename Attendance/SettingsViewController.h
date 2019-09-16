//
//  SettingsViewController.h
//  Attendance
//
//  Created by heppokoact on 2013/08/09.
//
//

#import <UIKit/UIKit.h>

/**
 * 設定画面のビューコントローラのヘッダーファイルです。
 */
@interface SettingsViewController : UIViewController

/** 出欠記録サーバーのURL */
@property (strong, nonatomic) IBOutlet UITextField *attendanceServerUrl;

/** 閉じるボタンをタップした時のAction */
- (IBAction)closeButtonTapped:(id)sender;

@end
