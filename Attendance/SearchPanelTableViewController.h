//
//  SearchPanelTableViewController.h
//  Attendance
//
//  Created by heppokoact on 2013/05/18.
//
//

#import <UIKit/UIKit.h>
#import "AttendanceDomain.h"
#import "ToggleButton.h"

/**
 * 検索パネルのViewControllerです。
 */
@interface SearchPanelTableViewController : UITableViewController<UITextFieldDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) IBOutlet ToggleButton *attCatNoneButton;
@property (strong, nonatomic) IBOutlet ToggleButton *attCatNotYetButton;
@property (strong, nonatomic) IBOutlet ToggleButton *attCatAttButton;
@property (strong, nonatomic) IBOutlet ToggleButton *attCatAbsenceButton;
@property (strong, nonatomic) IBOutlet ToggleButton *attCatTardyButton;
@property (strong, nonatomic) IBOutlet ToggleButton *attCatEarlyLeavingButton;
@property (strong, nonatomic) IBOutlet ToggleButton *itemCatNoneButton;
@property (strong, nonatomic) IBOutlet ToggleButton *handoutCatNotYetButton;
@property (strong, nonatomic) IBOutlet ToggleButton *handoutCatDoneButton;
@property (strong, nonatomic) IBOutlet ToggleButton *rcptCatNotYetButton;
@property (strong, nonatomic) IBOutlet ToggleButton *rcptCatDoneButton;
@property (strong, nonatomic) IBOutlet UIButton *projectSelectButton;
@property (strong, nonatomic) IBOutlet UITextField *projectNameLabel;
@property (strong, nonatomic) IBOutlet UITextField *empNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *empNoStartTextField;
@property (strong, nonatomic) IBOutlet UITextField *empNoEndTextField;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;

/**
 * 検索パネルで使用している検索条件のキャッシュを取得します。
 *
 * @return 検索条件
 */
+ (AttendanceDomain *)searchCondition;

/**
 * 出欠状況を変更した時に呼ばれます。
 */
- (IBAction)changeAttCat:(id)sender;

/**
 * 配布提出状況を変更した時に呼ばれます。
 */
- (IBAction)changeItemCat:(id)sender;

/**
 * プロジェクトの選択ボタンが押下された時に呼ばれます。
 */
- (IBAction)projectSelectButtonTapped:(UIControl *)sender;

/**
 * 社員名の編集が終了した時に呼ばれます。
 */
- (IBAction)empNameDidEndOnExit:(id)sender;

/**
 * 社員番号Fromの編集が終了した時に呼ばれます。
 */
- (IBAction)empNoFromDidEndOnExit:(id)sender;

/**
 * 社員番号Toの編集が終了した時に呼ばれます。
 */
- (IBAction)empNoToDidEndOnExit:(id)sender;

/**
 * 検索ボタンが押下された時に呼ばれます。
 */
- (IBAction)searchButtonTapped:(id)sender;

/**
 * プロジェクト名のラベル（実はテキストフィード）の編集開始時に呼ばれます。
 * テキストフィードにフォーカスが入らないようにします。
 */
- (IBAction)projectNameLabelTapped:(id)sender;

@end
