//
//  SettingsViewController.m
//  Attendance
//
//  Created by heppokoact on 2013/08/09.
//
//

#import "AppDelegate.h"
#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

/**
 * 設定画面のビューコントローラの実装です。
 */
@implementation SettingsViewController

/**
 * このビューコントローラをストーリーボードから作成するときに呼ばれます。
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/**
 * このビューがロードされるときに呼ばれます。
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ユーザーデフォルトから初期値を表示
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    self.attendanceServerUrl.text = [ud objectForKey:UD_KEY_ATTENDANCE_SERVER_URL];
}

/**
 * メモリが足りなくなった時に呼ばれます。
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * ビューがアンロードされたときに呼ばれます。
 */
- (void)viewDidUnload {
    [self setAttendanceServerUrl:nil];
    [super viewDidUnload];
}

/**
 * 閉じるボタンがタップされた時に呼ばれます。
 * 変更内容をユーザーデフォルトに保存して設定画面を閉じます。
 */
- (IBAction)closeButtonTapped:(id)sender {
    // ユーザーデフォルトに保存
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:self.attendanceServerUrl.text forKey:UD_KEY_ATTENDANCE_SERVER_URL];
    
    // 画面を閉じる
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

@end
