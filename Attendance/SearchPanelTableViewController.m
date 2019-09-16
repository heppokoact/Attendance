//
//  SearchPanelTableViewController.m
//  Attendance
//
//  Created by heppokoact on 2013/05/18.
//
//

#import "SearchPanelTableViewController.h"
#import "DetailViewController.h"
#import "ItemSelectViewController.h"
#import "AttendanceDao.h"
#import "MasterViewController.h"
#import "AppDelegate.h"
#import "Util.h"

@interface SearchPanelTableViewController ()

@end

/**
 * 検索パネルのViewControllerです。
 */
@implementation SearchPanelTableViewController {
    // AppDelegate
    AppDelegate *_delegate;
    
    // 出欠情報を取得するDao
    AttendanceDao *_dao;
    // プロジェクト選択ボタンのポップオーバー用変数
    UIPopoverController *_popover;
}

/**
 * 検索パネルで使用している検索条件のキャッシュを取得します。
 *
 * @return 検索条件
 */
+ (AttendanceDomain *)searchCondition {
    ENTER_METHOD
    
    static AttendanceDomain *condition = nil;
    
    if (!condition) {
        condition = [[AttendanceDomain alloc] init];
        condition.attCatNone = YES;
        condition.attCatNotYet = NO;
        condition.attCatAtt = NO;
        condition.attCatAbsence = NO;
        condition.attCatTardy = NO;
        condition.attCatEarlyLeaving = NO;
        condition.itemCatNone = YES;
        condition.handoutCatNotYet = NO;
        condition.handoutCatDone = NO;
        condition.rcptCatNotYet = NO;
        condition.rcptCatDone = NO;
        condition.projectName = @"";
        condition.empName = @"";
        condition.empNoStart = @"";
        condition.empNoEnd = @"";
    }
    
    LEAVE_METHOD
    
    return condition;
}

/**
 * ビューがメモリにロードされた直後に呼び出されるメソッドです.
 * ビューが表示される時、ビューが既にメモリ上に存在する場合は呼び出されないことに注意してください.
 */
- (void)viewDidLoad {
    ENTER_METHOD
    
    [super viewDidLoad];
    
    // AppDelegateを用意
    _delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // 出欠情報を取得するDaoを生成
    _dao = [[AttendanceDao alloc] init];
    
    // 社員番号のDelegateを設定
    self.empNoStartTextField.delegate = self;
    self.empNoEndTextField.delegate = self;

    // キーボードの表示中に背景をタップした場合、キーボードを閉じる
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyBoard)];
    recognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:recognizer];
    
    // キャッシュされている検索条件をセット
    [self configureView];
    
    LEAVE_METHOD
}

/**
 * 検索パネルの内容を表示します。
 */
- (void)configureView {
    AttendanceDomain *condition = [SearchPanelTableViewController searchCondition];
    self.attCatNoneButton.selected = condition.attCatNone;
    self.attCatNotYetButton.selected = condition.attCatNotYet;
    self.attCatAttButton.selected = condition.attCatAtt;
    self.attCatAbsenceButton.selected = condition.attCatAbsence;
    self.attCatTardyButton.selected = condition.attCatTardy;
    self.attCatEarlyLeavingButton.selected = condition.attCatEarlyLeaving;
    self.itemCatNoneButton.selected = condition.itemCatNone;
    self.handoutCatNotYetButton.selected = condition.handoutCatNotYet;
    self.handoutCatDoneButton.selected = condition.handoutCatDone;
    self.rcptCatNotYetButton.selected = condition.rcptCatNotYet;
    self.rcptCatDoneButton.selected = condition.rcptCatDone;
    self.projectNameLabel.text = condition.projectName;
    self.empNameTextField.text = condition.empName;
    self.empNoStartTextField.text = condition.empNoStart;
    self.empNoEndTextField.text = condition.empNoEnd;
}

/**
 * ビューが表示された時に呼ばれます。
 */
-(void)viewDidAppear:(BOOL)animated {
    // DetailViewで行った変更をまだ保存していない場合、破棄警告を行う
    DetailViewController *detail = [_delegate obtainDetailViewController];
    if ([detail isChanged]) {
        [_delegate showMessage:@"検索を実行した場合、現在表示中の社員に対する編集内容は破棄されます。\n（検索を行わず、検索パネルを閉じれば破棄されません）"
                            at:SITUATION_DISCARD_DETAIL_AT_SEARCH
                       okBlock:^ {[_delegate dismissMessage];}
                    cancelBlck:nil];
    }
}

/**
 * セルのレイアウトを変更します。
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ENTER_METHOD
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    // 検索ボタンのセクションは背景色、ボーダーを消す
    if (indexPath.section == 1) {
        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    LEAVE_METHOD
    return cell;
}

/**
 * 出欠状況を変更した時に呼ばれます。
 */
- (IBAction)changeAttCat:(id)sender {
    ENTER_METHOD
    
    // 無指定を押下した場合は出席、欠席、遅刻、早退の選択状態を解除する
    if (sender == self.attCatNoneButton) {
        self.attCatNotYetButton.selected = NO;
        self.attCatAttButton.selected = NO;
        self.attCatAbsenceButton.selected = NO;
        self.attCatTardyButton.selected = NO;
        self.attCatEarlyLeavingButton.selected = NO;
        
    // 出席、欠席、遅刻、早退を押下した場合は無指定の選択状態を解除する
    } else {
        self.attCatNoneButton.selected = NO;
    }
    
    // 何も選択されていない場合は無指定を選択状態にする
    if (!(self.attCatNotYetButton.selected ||
          self.attCatAttButton.selected ||
          self.attCatAbsenceButton.selected ||
          self.attCatTardyButton.selected ||
          self.attCatEarlyLeavingButton.selected)) {
        self.attCatNoneButton.selected = YES;
    }
    
    LEAVE_METHOD
}

/**
 * 配布状況を変更した時に呼ばれます。
 */
- (IBAction)changeItemCat:(id)sender {
    ENTER_METHOD
    
    // 無指定を押下した場合は未配布、配布済、未提出、提出済の選択状態を解除する
    if (sender == self.itemCatNoneButton) {
        self.handoutCatNotYetButton.selected = NO;
        self.handoutCatDoneButton.selected = NO;
        self.rcptCatNotYetButton.selected = NO;
        self.rcptCatDoneButton.selected = NO;
        
    // 未配布、配布済、未提出、提出済を押下した場合は無指定の選択状態を解除する
    } else {
        self.itemCatNoneButton.selected = NO;
    }
    
    // 何も選択されていない場合は無指定を選択状態にする
    if (!(self.handoutCatNotYetButton.selected ||
          self.handoutCatDoneButton.selected ||
          self.rcptCatNotYetButton.selected ||
          self.rcptCatDoneButton.selected)) {
        self.itemCatNoneButton.selected = YES;
    }
    
    LEAVE_METHOD
}

/**
 * プロジェクトの選択ボタンが押下された時に呼ばれます。
 */
- (IBAction)projectSelectButtonTapped:(UIControl *)sender {
    ENTER_METHOD
    
    // ポップオーバーするビューを作成
    ItemSelectViewController *view = [[ItemSelectViewController alloc] init];
    
    // 選択肢リストを取得してポップオーバーにセット
    NSError *error = nil;
    view.items = [_dao findAllProject:&error];
    if (error) {
        // エラーをユーザーに通知
        NSString *message = [Util buildErrorMessage:@"プロジェクト情報の取得中にエラーが発生しました。\n下記メッセージを添えてシステム管理者に連絡してください。" error:error];
        [_delegate showMessage:message
                            at:SITUATION_ERROR
                       okBlock:^{[_delegate dismissMessage];}
                    cancelBlck:nil];
    }
    
    // ポップオーバーの高さを表示に必要な高さに調整
    view.contentSizeForViewInPopover = CGSizeMake(300, [view getTableHeight]);
    
    // ポップオーバーを作成
    _popover = [[UIPopoverController alloc] initWithContentViewController:view];
    
    // ポップオーバーで選択後の処理に、ポップオーバーを閉じる処理とメモリ解放処理を追加
    view.postSelect = ^(NSString *selected) {
        // ラベルに選択した値を表示
        self.projectNameLabel.text = selected;
        
        // ポップオーバーを閉じてメモリを開放
        [_popover dismissPopoverAnimated:YES];
        _popover = nil;
    };
    
    // ポップオーバーを表示
    [_popover presentPopoverFromRect:sender.frame
                              inView:sender.superview
            permittedArrowDirections:UIPopoverArrowDirectionAny
                            animated:YES];
    
    
    LEAVE_METHOD
}

/**
 * 社員名の編集が終了した時に呼ばれます。
 */
- (IBAction)empNameDidEndOnExit:(id)sender {
    ENTER_METHOD
    
    [self closeKeyBoard];
    
    LEAVE_METHOD
}

/**
 * 社員番号Fromの編集が終了した時に呼ばれます。
 */
- (IBAction)empNoFromDidEndOnExit:(id)sender {
    ENTER_METHOD
    
    [self closeKeyBoard];
    
    LEAVE_METHOD
}

/**
 * 社員番号Toの編集が終了した時に呼ばれます。
 */
- (IBAction)empNoToDidEndOnExit:(id)sender {
    ENTER_METHOD
    
    [self closeKeyBoard];
    
    LEAVE_METHOD
}

/**
 * 検索ボタンが押下された時に呼ばれます。
 */
- (IBAction)searchButtonTapped:(id)sender {
    ENTER_METHOD
    
    // 検索条件のキャッシュに選択状態を反映
    AttendanceDomain *condition = [SearchPanelTableViewController searchCondition];
    condition.attCatNone = self.attCatNoneButton.selected;
    condition.attCatNotYet = self.attCatNotYetButton.selected;
    condition.attCatAtt = self.attCatAttButton.selected;
    condition.attCatAbsence = self.attCatAbsenceButton.selected;
    condition.attCatTardy = self.attCatTardyButton.selected;
    condition.attCatEarlyLeaving = self.attCatEarlyLeavingButton.selected;
    condition.itemCatNone = self.itemCatNoneButton.selected;
    condition.handoutCatNotYet = self.handoutCatNotYetButton.selected;
    condition.handoutCatDone = self.handoutCatDoneButton.selected;
    condition.rcptCatNotYet = self.rcptCatNotYetButton.selected;
    condition.rcptCatDone = self.rcptCatDoneButton.selected;
    condition.projectName = self.projectNameLabel.text;
    condition.empName = self.empNameTextField.text;
    condition.empNoStart = self.empNoStartTextField.text;
    condition.empNoEnd = self.empNoEndTextField.text;
    
    // 検索パネルを閉じ、MasterViewをリロード
    // 色々調べたが、PopoverViewControllerはpopoverを呼び出したVIEWの
    // prepareForSegueメソッドでしか取得できない模様
    // さらにprepareForSegueではこのSearchPanelTableViewControllerは
    // 取得できないようなので、結局popoverを閉じる処理は呼び出し元でしかできない模様
    MasterViewController *master = [_delegate obtainMasterViewController];
    [master refreshView];
    
    LEAVE_METHOD
}

/**
 * キーボードを閉じます。
 */
- (void)closeKeyBoard {
    ENTER_METHOD
    
    // キーボードを閉じます
    [self.view endEditing:YES];
    
    // 社員番号を５桁にフォーマット
    [self formatEmpNo:self.empNoStartTextField];
    [self formatEmpNo:self.empNoEndTextField];
    
    LEAVE_METHOD
}

/**
 * 社員番号のテキストフィードを5桁に前ゼロ埋めします。
 */
- (void)formatEmpNo:(UITextField *)empNoField {
    ENTER_METHOD
    
    NSString *empNoString = empNoField.text;
    if (empNoString && [empNoString length] > 0) {
        NSInteger empNoInteger = [empNoString integerValue];
        empNoField.text = [NSString stringWithFormat:@"%05d", empNoInteger];
    }
    
    LEAVE_METHOD
}

/**
 * テキストフィードに入力を反映する直前に呼ばれます。
 *
 * @param textField 入力があったテキストフィード
 * @param range 入力が行われた位置
 * @param string 入力内容
 * @return 入力を反映する場合YES
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    ENTER_METHOD
    
    // 社員番号の場合
    if (textField == self.empNoStartTextField || textField == self.empNoEndTextField) {
        NSLog(@"%d", string.length);
        // 文字を削除する場合は入力可
        if (string.length == 0) {
            return YES;
        }
        
        // 完了ボタン押下の場合は入力可
        if ([@"\n" isEqualToString:string]) {
            return YES;
        }
        
        // 数字のみ入力可
        NSRange numberRange = [string rangeOfString:@"^[0-9]+$" options:NSRegularExpressionSearch];
        if (numberRange.location == NSNotFound) {
            return NO;
        }
        
        // ５文字まで入力可
        if (textField.text.length + string.length - range.length > 5) {
            return NO;
        }
    }
    
    LEAVE_METHOD
    
    return YES;
}

/**
 * プロジェクト名のラベル（実はテキストフィード）の編集開始時に呼ばれます。
 * テキストフィードにフォーカスが入らないようにします。
 */
- (IBAction)projectNameLabelTapped:(id)sender {
    [self.view endEditing:YES];
}

/**
 * ビューがメモリからアンロードされた直後に呼び出されるメソッドです.
 */
- (void)viewDidUnload {
    ENTER_METHOD
    
    [self setAttCatNoneButton:nil];
    [self setAttCatNotYetButton:nil];
    [self setAttCatAttButton:nil];
    [self setAttCatAbsenceButton:nil];
    [self setAttCatTardyButton:nil];
    [self setAttCatEarlyLeavingButton:nil];
    [self setItemCatNoneButton:nil];
    [self setHandoutCatNotYetButton:nil];
    [self setHandoutCatDoneButton:nil];
    [self setRcptCatNotYetButton:nil];
    [self setRcptCatDoneButton:nil];
    [self setProjectSelectButton:nil];
    [self setProjectNameLabel:nil];
    [self setEmpNameTextField:nil];
    [self setEmpNoStartTextField:nil];
    [self setEmpNoEndTextField:nil];
    [self setSearchButton:nil];
    [self setProjectNameLabel:nil];
    _delegate = nil;
    _dao = nil;
    _popover = nil;
    [super viewDidUnload];
    
    LEAVE_METHOD
}

@end
