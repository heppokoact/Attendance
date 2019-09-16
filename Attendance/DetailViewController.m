
#import <AudioToolbox/AudioServices.h>
#import "DetailViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "EmployeeSettingsViewController.h"
#import "AppDelegate.h"
#import "Cat.h"
#import "AttendanceDao.h"
#import "SVProgressHUD.h"
#import "ItemSelectViewController.h"
#import "MasterViewController.h"
#import "Util.h"

#define SEGUE_POPOVER_EMPLOYEE_SETTINGS @"popoverEmployeeSettings"
#define TAG_DETAIL_HANDOUT_NAME 101
#define TAG_DETAIL_RCPT_NAME 102
#define DETAIL_ITEM_MAX_LENGTH 100

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
- (void)configureView;
@end

@implementation DetailViewController {
    // AppDelegate
    AppDelegate *_delegate;
    // 出欠情報にアクセスするためのDao
    AttendanceDao *_dao;
    // 出席状況用のレイヤー
    CALayer *_attLayer;
    // 配布物用のレイヤー
    CALayer *_handoutLayer;
    // 提出物用のレイヤー
    CALayer *_rcptLayer;
    // はんこを押す音
    SystemSoundID _ponId;
    // 確定ボタンを押す音
    SystemSoundID _submitStartSoundId;
    // 確定完了の音
    SystemSoundID _submitEndSoundId;
    // 編集中の出欠情報の編集前のオリジナル
    Attendance *_originalDetail;
    // 編集中の出欠情報
    Attendance *_detailItem;
    // 編集ボタンのポップオーバー用変数
    UIPopoverController *_popover;
    // 確定ボタン押下時の警告をスキップするかどうか
    BOOL _skipWarningsAtSubmit;
}

@synthesize empNoLabel = _empNoLabel;
@synthesize empNameLabel = _empNameLabel;
@synthesize attButton = _attButton;
@synthesize absentButton = _absentButton;
@synthesize tardyButton = _tardyButton;
@synthesize earlyLeavingButton = _earlyLeavingButton;
@synthesize handoutExistenceLabel = _handoutExistenceLabel;
@synthesize handoutSitCatButton = _handoutSitCatButton;
@synthesize handoutNameLabel = _handoutNameLabel;
@synthesize rcptExistenceLabel = _rcptExistenceLabel;
@synthesize rcptSitCatButton = _rcptSitCatButton;
@synthesize rcptNameLabel = _rcptNameLabel;
@synthesize remColTextView = _remColTextView;
@synthesize submitButton = _submitButton;

@synthesize masterPopoverController = _masterPopoverController;

/**
 * DetailViewに表示するアイテムを設定します。
 * @param newDetailItem 出席情報
 */
- (void)setDetailItem:(Attendance *)newDetailItem {
    ENTER_METHOD
    
    _originalDetail = newDetailItem;
    _detailItem = [newDetailItem copy];
    [self configureView];
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
    
    // 出席データがセットされたら総務設定にもセットする
    // 総務設定表示中にMasterViewで別の社員を選択された時のため
    EmployeeSettingsViewController *employee = [_delegate obtainEmployeeSettingsViewController];
    if (employee) {
        employee.detailItem = newDetailItem;
    }
    
    // このビューの入力ナビゲーションメッセージを表示します
    [self displayNavigationMessage];
    
    LEAVE_METHOD
}

/**
 * 現在表示中の出欠情報を取得します。
 *
 *　@return 現在表示中の出欠情報
 */
- (Attendance *)getDetailItem {
    return _detailItem;
}

/**
 * このビューの内容が変更されたかどうかを返します
 *
 * @return このビューの内容が変更されていればYES
 */
- (BOOL)isChanged {
    ENTER_METHOD
    
    if (_detailItem) {
        return ![_detailItem isEqual:_originalDetail];
    } else {
        return NO;
    }
    
    LEAVE_METHOD
}

/**
 * ビューが表示されるたびに呼ばれます。
 */
- (void)viewWillAppear:(BOOL)animated {
    ENTER_METHOD
    
    [self configureView];
    
    // 出席状況の画像レイヤーの位置を調整
    [self configureLayerPositionAsToOrientation:self.interfaceOrientation];
    
    LEAVE_METHOD
}

/**
 * ビューの表示処理が終わった時に呼ばれます。
 */
- (void)viewDidAppear:(BOOL)animated {
    ENTER_METHOD
    LEAVE_METHOD
}

/**
 * ビューを設定します.
 */
- (void)configureView
{
    ENTER_METHOD
        
    // 出席情報をビューに表示する
    if (_detailItem) {
        self.empNoLabel.text = _detailItem.empNo;
        self.empNameLabel.text = _detailItem.empName;
        self.handoutExistenceLabel.text = _detailItem.handoutExistenceFlgName;
        
        // 配布物のボタンのタイトルを設定
        NSString *okCancelKey = nil;
        NSString *okCancelImageName = nil;
        if ([_detailItem.handoutSitCat isEqualToString:HANDOUT_CAT_NOT_YET]) {
            okCancelKey = OK_CANCEL_CAT_CANCEL;
            okCancelImageName = @"okButtonBlue2.gif";
        } else {
            okCancelKey = OK_CANCEL_CAT_OK;
            okCancelImageName = @"torikeshiButtonBlue2.gif";
        }
        UIImage *buttonImage = [UIImage imageNamed: okCancelImageName];
        [self.handoutSitCatButton setImage:buttonImage forState:UIControlStateNormal];
        // 配布物がない場合は配布物のボタンを表示しない
        NSString *handoutName = _detailItem.handoutName;
        self.handoutSitCatButton.hidden = (!handoutName || handoutName.length == 0);
        
        // 変換中にtextを変更すると確定された上に入力がおかしくなるのを回避
        if (!self.handoutNameLabel.markedTextRange) {
            self.handoutNameLabel.text = handoutName;
        }
        self.rcptExistenceLabel.text = _detailItem.rcptExistenceFlgName;
        
        // 提出物のボタンのタイトルを設定
        if ([_detailItem.rcptSitCat isEqualToString:RCPT_CAT_NOT_YET]) {
            okCancelKey = OK_CANCEL_CAT_CANCEL;
            okCancelImageName = @"okButtonBlue2.gif";
        } else {
            okCancelKey = OK_CANCEL_CAT_OK;
            okCancelImageName = @"torikeshiButtonBlue2.gif";
        }
        buttonImage = [UIImage imageNamed: okCancelImageName];
        [self.rcptSitCatButton setImage:buttonImage forState:UIControlStateNormal];
        // 提出物がない場合は提出物のボタンを表示しない
        NSString *rcptName = _detailItem.rcptName;
        self.rcptSitCatButton.hidden = (!rcptName || rcptName.length == 0);

        // 変換中にtextを変更すると確定された上に入力がおかしくなるのを回避
        if (!self.rcptNameLabel.markedTextRange) {
            self.rcptNameLabel.text = rcptName;
        }
        // 変換中にtextを変更すると確定された上に入力がおかしくなるのを回避
        if (!self.remColTextView.markedTextRange) {
            self.remColTextView.text = _detailItem.remCol;
        }
        
        self.attButton.enabled = YES;
        self.absentButton.enabled = YES;
        self.tardyButton.enabled = YES;
        self.earlyLeavingButton.enabled = YES;
        self.handoutNameLabel.enabled = YES;
        self.rcptNameLabel.enabled = YES;
        self.remColTextView.editable = YES;
        self.handoutEditButton.enabled = YES;
        self.rcptEditButton.enabled = YES;
        self.remColEditButton.enabled = YES;
        
        // 確定ボタンは内容が変更されている時のみ活性
        self.submitButton.enabled = ![_detailItem isEqual:_originalDetail];
        
        self.remColTextView.inputAccessoryView.hidden = NO;
        self.handoutNameLabel.inputAccessoryView.hidden = NO;
        self.rcptNameLabel.inputAccessoryView.hidden = NO;
        
        // 出席状況の画像を表示
        NSDictionary *imageDict = [[Cat sharedInstance] dictForKey:@"attCatImage"];
        NSString *imageName = [imageDict objectForKey:_detailItem.attCat];
        UIImage *image = [UIImage imageNamed:imageName];
        _attLayer.contents = (id)[image CGImage];
        // 配布物の画像を表示
        imageDict = [[Cat sharedInstance] dictForKey:@"handoutSitCatImage"];
        imageName = [imageDict objectForKey:_detailItem.handoutSitCat];
        image = [UIImage imageNamed:imageName];
        _handoutLayer.contents = (id)[image CGImage];
        // 提出物の画像を表示
        imageDict = [[Cat sharedInstance] dictForKey:@"rcptSitCatImage"];
        imageName = [imageDict objectForKey:_detailItem.rcptSitCat];
        image = [UIImage imageNamed:imageName];
        _rcptLayer.contents = (id)[image CGImage];
        
    } else {
        self.empNoLabel.text = @"";
        self.empNameLabel.text = @"";
        self.handoutExistenceLabel.text = @"";
        [self.handoutSitCatButton setTitle:@"OK" forState:UIControlStateNormal];
        self.handoutNameLabel.text = @"";
        self.rcptExistenceLabel.text = @"";
        [self.rcptSitCatButton setTitle:@"OK" forState:UIControlStateNormal];
        self.rcptNameLabel.text = @"";
        self.remColTextView.text = @"";
        
        self.attButton.enabled = NO;
        self.absentButton.enabled = NO;
        self.tardyButton.enabled = NO;
        self.earlyLeavingButton.enabled = NO;
        self.handoutNameLabel.enabled = NO;
        self.rcptNameLabel.enabled = NO;
        self.remColTextView.editable = NO;
        self.submitButton.enabled = NO;
        self.handoutEditButton.enabled = NO;
        self.rcptEditButton.enabled = NO;
        self.remColEditButton.enabled = NO;
        
        self.remColTextView.inputAccessoryView.hidden = YES;
        self.handoutNameLabel.inputAccessoryView.hidden = YES;
        self.rcptNameLabel.inputAccessoryView.hidden = YES;
        
        self.handoutSitCatButton.hidden = YES;
        self.rcptSitCatButton.hidden = YES;
        
        _attLayer.contents = nil;
        _handoutLayer.contents = nil;
        _rcptLayer.contents = nil;
    }
    
    LEAVE_METHOD
}

/**
 * このビューの表示内容をカラにします。
 */
- (void)resetView {
    ENTER_METHOD
    
    _detailItem = nil;
    [self configureView];
    
    LEAVE_METHOD
}

/**
 * テーブルビューのインスタンスを初期化します.
 * @param style テーブルビューのスタイル
 */
- (id)initWithStyle:(UITableViewStyle)style
{
    ENTER_METHOD
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    LEAVE_METHOD
    return self;
}

/**
 * ビューがメモリにロードされた直後に呼び出されるメソッドです.
 * ビューが表示される時、ビューが既にメモリ上に存在する場合は呼び出されないことに注意してください.
 */
- (void)viewDidLoad
{
    ENTER_METHOD
    
    // AppDelegateを用意
    _delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // 出欠情報にアクセスするためのDaoを用意
    _dao = [[AttendanceDao alloc] init];
    
    [super viewDidLoad];
    
    // メモ欄のTextViewのボーダー装飾
    self.remColTextView.layer.cornerRadius = 10;
    
    /* 入力欄のキーボードに閉じるボタンを追加 */
    // ツールバー（アクセサリビュー）を作成
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.barStyle = UIBarStyleBlackOpaque;
    // フレキシブルスペースの作成（閉じるボタンを右寄せにする）
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    // 閉じるボタンを作成
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"閉じる" style:UIBarButtonItemStyleDone target:self action:@selector(keybordCloseButtonTapped:)];
    // ツールバーに要素を配置
    [toolbar setItems:@[spacer, closeButton]];
    // アクセサリビューを入力欄のテキストビューに設定
    self.remColTextView.inputAccessoryView = toolbar;
    self.handoutNameLabel.inputAccessoryView = toolbar;
    self.rcptNameLabel.inputAccessoryView = toolbar;
    
    // キーボードの表示中に背景をタップした場合、キーボードを閉じる
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyBoard)];
    recognizer.cancelsTouchesInView = NO;
    [self.splitViewController.view addGestureRecognizer:recognizer];
    
    // 背景色を設定
    UIColor* color = [UIColor colorWithRed:0.000f green:0.392f blue:0.000f alpha:1.0f];
    self.tableView.backgroundColor = color;
    self.tableView.backgroundView = nil;
    
    // 出席状況のアニメーション用のパースを登録
    CATransform3D transform = CATransform3DMakeRotation(0, 0, 0, 0);
    float zDistance = 500;
    transform.m34 = 1.0 / -zDistance;
    self.view.layer.sublayerTransform = transform;
    
    // 出席状況のアニメーション用のレイヤーを登録
    _attLayer = [CALayer layer];
    _attLayer.frame = CGRectMake(0, 0, 117, 76);
    [self.view.layer addSublayer:_attLayer];
    // 配布物のアニメーション用のレイヤーを登録
    _handoutLayer = [CALayer layer];
    _handoutLayer.frame = CGRectMake(0, 0, 60, 60);
    [self.view.layer addSublayer:_handoutLayer];
    // 提出物のアニメーション用のレイヤーを登録
    _rcptLayer = [CALayer layer];
    _rcptLayer.frame = CGRectMake(0, 0, 60, 60);
    [self.view.layer addSublayer:_rcptLayer];
    
    // レイヤーの位置を調整
    [self configureLayerPositionAsToOrientation:self.interfaceOrientation];
    
    // 効果音を用意
    NSString *ponPath = [[NSBundle mainBundle] pathForResource:@"pon" ofType:@"wav"];
    NSURL *ponURL = [NSURL fileURLWithPath:ponPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)ponURL, &_ponId);
//    NSString *submitStartPath = [[NSBundle mainBundle] pathForResource:@"kon" ofType:@"wav"];
//    NSURL *submitStartURL = [NSURL fileURLWithPath:submitStartPath];
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)submitStartURL, &_submitStartSoundId);
    NSString *submitEndPath = [[NSBundle mainBundle] pathForResource:@"dodon5" ofType:@"wav"];
    NSURL *submitEndURL = [NSURL fileURLWithPath:submitEndPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)submitEndURL, &_submitEndSoundId);
    
    // 配布物名、提出物名に最大長を設定
    self.handoutNameLabel.delegate = self;
    self.rcptNameLabel.delegate = self;
    
    // メモ欄にdelegateを設定
    // （Editin ChangedイベントがないのでTextFieldと違ってStoryboardでイベントを設定できない）
    self.remColTextView.delegate = self;
    
    // ビューの内容を設定
    [self configureView];
    
    LEAVE_METHOD
}

/**
 * iPadの向きを変えた時に出席状況の画像レイヤーの位置を調整します
 *
 * @param orientation iPadの向き
 */
- (void)configureLayerPositionAsToOrientation:(UIInterfaceOrientation)orientation {
    ENTER_METHOD
    
    _attLayer.position = CGPointMake(350, 90);
    _handoutLayer.position = CGPointMake(280, 255);
    _rcptLayer.position = CGPointMake(280, 397);
    
    LEAVE_METHOD
}

/**
 * ビューがメモリからアンロードされた直後に呼び出されるメソッドです.
 */
- (void)viewDidUnload
{
    ENTER_METHOD
    [self setEmpNoLabel:nil];
    [self setEmpNameLabel:nil];
    [self setHandoutExistenceLabel:nil];
    [self setHandoutNameLabel:nil];
    [self setRcptExistenceLabel:nil];
    [self setRcptNameLabel:nil];
    [self setRemColTextView:nil];
    [self setAttButton:nil];
    [self setHandoutSitCatButton:nil];
    [self setRcptSitCatButton:nil];
    [self setAbsentButton:nil];
    [self setTardyButton:nil];
    [self setEarlyLeavingButton:nil];
    [self setSubmitButton:nil];
    _delegate = nil;
    _dao = nil;
    _attLayer = nil;
    _handoutLayer = nil;
    _rcptLayer = nil;
    _ponId = nil;
    _submitStartSoundId = nil;
    _submitEndSoundId = nil;
    _originalDetail = nil;
    _detailItem = nil;
    [self setHandoutEditButton:nil];
    [self setRcptEditButton:nil];
    [self setRemColEditButton:nil];
    _popover = nil;
    _skipWarningsAtSubmit = nil;
    [self setHandoutEditButton:nil];
    [self setRcptEditButton:nil];
    [self setRemColEditButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    LEAVE_METHOD
}

/**
 * デバイスの回転を検出した時に呼び出されるメソッドです.
 * インターフェースを自動回転させる場合はYESを返却します.
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    ENTER_METHOD
    LEAVE_METHOD
	return YES;
}

/**
 * デバイスの回転を検出した時に呼び出されるメソッドです.
 * このメソッドが呼び出される時点では、ビューの位置やサイズは回転後のものになっています。
 */
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    ENTER_METHOD
    [self configureLayerPositionAsToOrientation:toInterfaceOrientation];
    LEAVE_METHOD
}

/**
 * Storyboardの画面遷移前に呼び出されるメソッドです.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ENTER_METHOD
    NSString *identifier = [segue identifier];
    if ([identifier isEqualToString:SEGUE_POPOVER_EMPLOYEE_SETTINGS]) {
        // イベント発生元が総務設定セルの場合
        EmployeeSettingsViewController *controller = (EmployeeSettingsViewController *)segue.destinationViewController;
        controller.detailItem = _detailItem;
    }
    LEAVE_METHOD
}

/**
 * テーブルビューの各セクションのヘッダー部分をカスタマイズします
 */
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //　ヘッダー用ビューを作成します
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 45)];
    tableView.sectionHeaderHeight = headerView.frame.size.height;
    
    // アイコン用画像をヘッダービューに追加
    NSDictionary *iconDict = [[Cat sharedInstance]dictForKey:@"detailViewIcon"];
    NSString *iconName = [iconDict valueForKey: [[NSString alloc] initWithFormat:@"%d", section]];
    if (iconName) {
        NSString *imageFileName = [[NSBundle mainBundle] pathForResource:iconName ofType:@"png"];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile: imageFileName];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(27, 8, image.size.width, image.size.height)];
        imageView.image = image;
        [headerView addSubview:imageView];
    }
    
    // ヘッダータイトルをヘッダービューに追加
    int titleLeftPos = 62;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(titleLeftPos, 14, headerView.frame.size.width - 20, 20)];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.font = [UIFont boldSystemFontOfSize:18.0];
    label.shadowOffset = CGSizeMake(1, 2);
    label.shadowColor = [UIColor lightGrayColor];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    CGRect frame = label.frame;
    frame.size = [label.text sizeWithFont:label.font];
    label.frame = frame;
    [headerView addSubview:label];
    
    return headerView;
}

/**
 * テーブルビューの各セクションのヘッダー部分の高さをカスタマイズします
 */
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section >= 4) {
        return 20.0;
    }
    return 45.0;
}

/*
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 60.0;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}
*/

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    ENTER_METHOD
    // Return the number of sections.
    LEAVE_METHOD
    return 0;
}
*/

/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    ENTER_METHOD
    // Return the number of rows in the section.
    LEAVE_METHOD
    return 0;
}
*/

/**
 * セルのレイアウトを変更します。
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ENTER_METHOD
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    // 確定ボタンのセクションは背景色を消す
    // それ以外のセルにはボーダーを設定
    // 区切り線(separator)の機能を使用すると確定ボタンのセクションの上下に区切り線が現れてしまい消せないので、
    // 区切り線の機能は使用していない
    if (indexPath.section == 4) {
        cell.backgroundColor = [UIColor clearColor];
    } else {
        cell.layer.borderWidth = 0.5f;
        cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
    LEAVE_METHOD
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/**
 * セルのスワイプで削除ボタンが出ないようにする
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ENTER_METHOD
    // Navigation logic may go here. Create and push another view controller.
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    ENTER_METHOD
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
    LEAVE_METHOD
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    ENTER_METHOD
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
    LEAVE_METHOD
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    ENTER_METHOD
    // 縦でも2ペインで表示する
    LEAVE_METHOD
    return NO;
}

#pragma mark - Actions

/**
 * 欠席ボタンを押下した時に呼ばれます。
 * @param 欠席ボタン
 * @return IBAction
 */
- (IBAction)absenceButtonTapped:(id)sender {
    ENTER_METHOD
    
    [self changeAttCat:@"2"];
    
    LEAVE_METHOD
}

/**
 * 遅刻ボタンを押下した時に呼ばれます。
 * @param 遅刻ボタン
 * @return IBAction
 */
- (IBAction)tardyButtonTapped:(id)sender {
    ENTER_METHOD
    
    [self changeAttCat:@"3"];
    
    LEAVE_METHOD
}

/**
 * 早退ボタンを押下した時に呼ばれます。
 * @param 早退ボタン
 * @return IBAction
 */
- (IBAction)earlyLeavingButtonTapped:(id)sender {
    ENTER_METHOD
    
    [self changeAttCat:@"4"];
    
    LEAVE_METHOD
}

/**
 * 出席ボタンを押下した時に呼ばれます。
 * @param 出席ボタン
 * @return IBAction
 */
- (IBAction)attButtonTapped:(id)sender {
    ENTER_METHOD
    
    [self changeAttCat:@"1"];
    
    LEAVE_METHOD
}

/**
 * 出欠状況を変更する
 *
 * @param cat 出欠状況
 */
- (void)changeAttCat:(NSString *)cat {
    NSString *newCat = cat;
    
    // 現在の出席状態と同じボタンを押した場合は未記帳に戻す。
    // そうでなければアニメーションを行う。
    if ([cat isEqualToString:_detailItem.attCat]) {
        newCat = ATT_CAT_NOT_YET;
    } else {
        [self startFadeInAniMationAt: _attLayer];
    }
    
    _detailItem.attCat = newCat;
    [self configureView];
    
    // このビューの入力ナビゲーションメッセージを表示します
    [self displayNavigationMessage];
}

/**
 * レイヤーをフェードインするアニメーションを開始します。
 *
 * @param layer アニメーションを実施するレイヤー
 */
- (void)startFadeInAniMationAt:(CALayer *)layer {
    ENTER_METHOD
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"zPosition"];
    animation.fromValue = [NSNumber numberWithFloat:1000];
    animation.toValue = [NSNumber numberWithFloat:0];
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    animation.repeatCount = 1;
    animation.delegate = self;
    [layer addAnimation:animation forKey:@"zPosition"];
    
    LEAVE_METHOD
}

/**
 * アニメーションが終わった時に呼ばれます
 */
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    ENTER_METHOD
    
    // アニメーションが最後まで実施されたときは、はんこを押した効果音を鳴らす
    // （ボタン連打などのときは鳴らさない）
    if (flag) {
        AudioServicesPlaySystemSound(_ponId);
    }
    
    LEAVE_METHOD
}

/**
 * 配布物のOKボタンを押下した時に呼ばれます。
 * @param 配布物のOKボタン
 * @return IBAction
 */
- (IBAction)handoutButtonTapped:(id)sender {
    ENTER_METHOD
    
    if ([_detailItem.handoutSitCat isEqualToString:HANDOUT_CAT_YET]) {
        _detailItem.handoutSitCat = HANDOUT_CAT_NOT_YET;
        
    } else {
        _detailItem.handoutSitCat = HANDOUT_CAT_YET;
        // OKを押下した時のみアニメーションする
        [self startFadeInAniMationAt: _handoutLayer];
    }
    
    [self configureView];
    
    // このビューの入力ナビゲーションメッセージを表示します
    [self displayNavigationMessage];
    
    LEAVE_METHOD
}

/**
 * 提出物のOKボタンを押下した時に呼ばれます。
 * @param 提出物のOKボタン
 * @return IBAction
 */
- (IBAction)rcptButtonTapped:(id)sender {
    ENTER_METHOD
    
    if ([_detailItem.rcptSitCat isEqualToString:RCPT_CAT_YET]) {
        _detailItem.rcptSitCat = RCPT_CAT_NOT_YET;
    } else {
        _detailItem.rcptSitCat = RCPT_CAT_YET;
        // OKを押下した時のみアニメーションする
        [self startFadeInAniMationAt: _rcptLayer];
    }
    
    [self configureView];
    
    // このビューの入力ナビゲーションメッセージを表示します
    [self displayNavigationMessage];
    
    LEAVE_METHOD
}

/**
 * 確定ボタンを押下した時に呼ばれます。
 *
 * @param 確定ボタン
 * @return IBAction
 */
- (IBAction)submitButtonTapped:(id)sender {
    ENTER_METHOD
    
    //AudioServicesPlaySystemSound(_submitStartSoundId);
    
    [self submitAttendance];
    
    LEAVE_METHOD
}

/**
 * 編集中の出欠情報を保存します。
 */
- (void)submitAttendance {
    ENTER_METHOD
    
    // 入力内容をチェック
    if (![self checkAtSubmit]) {
        return;
    }
    
    // ローディングを表示
    [_delegate showMessage:@"確定中..."
                        at:SITUATION_START_UPDATE_ATTENDANCE
                   okBlock:nil
                cancelBlck:nil];
    
    // 更新処理を別スレッドで行う（そうしないとローディング表示の描画が更新処理完了まで待たされるため）
    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(q_global, ^{
        
        // 更新
        NSError *error = nil;
        [_dao update:_detailItem error:&error];
        
        // 画面の描画処理をメインスレッドで行う（UIKitはスレッドセーフでなく、メインスレッドからのみアクセスするルールであるため）
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // エラー処理
            if (error) {
                if ([ERROR_DOMAIN_ATTENDANCE isEqualToString:error.domain] &&
                    ERROR_CODE_OPTIMISTIC_LOCK == error.code) {
                    // 楽観的排他エラーの場合
                    NSString *message = @"他のユーザがこの出欠記録を更新したため確定処理を中止しました。\nOKボタンを押すと入力内容を破棄しますので最初からやり直してください。";
                    [_delegate showMessage:message
                                        at:SITUATION_ERROR
                                   okBlock:^{[self initAll];}
                                cancelBlck:nil];
                    return;
                    
                } else {
                    // その他のエラーの場合
                    NSString *message = @"出欠情報の更新中にエラーが発生しました。\n下記メッセージを添えてシステム管理者に連絡してください。";
                    message = [Util buildErrorMessage:message error:error];
                    [_delegate showMessage:message
                                        at:SITUATION_ERROR
                                   okBlock:^{[_delegate dismissMessage];}
                                cancelBlck:nil];
                }
                
                return;
            }
            
            // DetailViewをクリア、MasterViewを再描画
            [self initAll];
            
            // 確定処理完了をユーザーに通知
            [_delegate showMessage:@"いってらっしゃいませ！"
                                at:SITUATION_SUCCESS_UPDATE_ATTENDANCE
                           okBlock:nil
                        cancelBlck:nil];
            
            AudioServicesPlaySystemSound(_submitEndSoundId);
        });
    });
    
    LEAVE_METHOD
}

/**
 * MasterViewおよびDetailViewを初期化します。
 */
- (void)initAll {
    _detailItem = nil;
    [self configureView];
    [[_delegate obtainMasterViewController] refreshViewWithoutProgress];
}

/**
 * 確定ボタン押下時のチェックを行います。
 *
 * @return チェックOKならYES
 */
- (BOOL)checkAtSubmit {
    // 警告
    if (!_skipWarningsAtSubmit) {
        NSMutableArray *warningMessages = [[NSMutableArray alloc] init];
        
        // 出欠状態が未記帳なら警告
        if ([ATT_CAT_NOT_YET isEqualToString:_detailItem.attCat]) {
            [warningMessages addObject:@"出欠状態が未記帳です。"];
        }
        
        // 配布物が未配布なら警告
        if ([_detailItem hasHandout] && [_detailItem.handoutSitCat isEqualToString:HANDOUT_CAT_NOT_YET]) {
            [warningMessages addObject:@"配布物が未配布です。"];
        }
        
        // 提出物が未提出なら警告
        if ([_detailItem hasRcpt] && [_detailItem.rcptSitCat isEqualToString:RCPT_CAT_NOT_YET]) {
            [warningMessages addObject:@"提出物が未提出です。"];
        }
        
        // 警告有りならそれを表示
        if (warningMessages.count > 0) {
            [warningMessages addObject:@"確定を実行しますか？"];
            NSString *warningMessage = [warningMessages componentsJoinedByString:@"\n"];
            
            // OKボタンを押下した場合の処理
            BKBlock retryBlock = ^(void) {
                _skipWarningsAtSubmit = YES;
                // 一旦メインスレッドの処理を終了させないと警告ダイアログがずっと消えないので、更新処理をTimerによる起動にする
                [NSTimer scheduledTimerWithTimeInterval:0
                                                 target:self
                                               selector:@selector(submitAttendanceUsingTimer:)
                                               userInfo:nil
                                                repeats:NO];
            };
            // 警告ダイアログを表示
            [_delegate showMessage:warningMessage
                                at:SITUATION_REMAIN_ITEM
                           okBlock:retryBlock
                        cancelBlck:^{[self displayNavigationMessage];}];
            
            return NO;
        }
    }
    
    _skipWarningsAtSubmit = NO;
    
    return YES;
}

/**
 * submitAttendanceをタイマーから起動するためだけのメソッド。
 * （NSTimerを引数にとるメソッドでないと呼べないようなので・・・）
 *
 * @param timer この処理を起動したタイマー（いらない）
 */
- (void)submitAttendanceUsingTimer:(NSTimer *)timer {
    ENTER_METHOD
    
    [self submitAttendance];
    
    LEAVE_METHOD
}

/**
 * キーボードの閉じるボタンを押下した時に呼ばれます。
 * @param キーボードの閉じるボタン
 * @return IBAction
 */
- (IBAction)keybordCloseButtonTapped:(id)sender {
    ENTER_METHOD
    
    // キーボードを閉じる
    [self closeKeyBoard];
    
    LEAVE_METHOD
}

/**
 * キーボードを閉じます。
 */
- (void)closeKeyBoard {
    ENTER_METHOD
    
    // キーボードを閉じる
    [self.remColTextView resignFirstResponder];
    [self.handoutNameLabel resignFirstResponder];
    [self.rcptNameLabel resignFirstResponder];
    
    LEAVE_METHOD
}

/**
 * メモ欄が変更された時に呼ばれます。
 */
-(void)textViewDidChange:(UITextView *)textView {
    // 編集内容をエンティティに保存
    _detailItem.remCol = self.remColTextView.text;
    
    [self configureView];
}

/**
 * 配布物、提出物が変更された時に呼ばれます。
 */
- (IBAction)textChanged:(id)sender {
    ENTER_METHOD

    // 編集内容をエンティティに保存
    _detailItem.handoutName = self.handoutNameLabel.text;
    _detailItem.rcptName = self.rcptNameLabel.text;

    // 配布物と提出物は空になっている場合提出・配布状況を「未」にする
    if ([@"" isEqualToString:_detailItem.handoutName]) {
        _detailItem.handoutSitCat = HANDOUT_CAT_NOT_YET;
    }
    if ([@"" isEqualToString:_detailItem.rcptName]) {
        _detailItem.rcptSitCat = RCPT_CAT_NOT_YET;
    }
    
    [self configureView];

    // このビューの入力ナビゲーションメッセージを表示します
    [self displayNavigationMessage];
    
    LEAVE_METHOD
}

/**
 * 配布物の編集ボタンを押下した時に呼ばれます。
 *
 * @param 配布物の編集ボタン
 */
- (void)handoutEditButtonTapped:(UIButton *)sender {
    ENTER_METHOD
    
    // ポップオーバーで選択した時の処理
    ItemSelectBlock block = ^(NSString *selected) {
        _detailItem.handoutName = selected;
        [self configureView];
        
        // このビューの入力ナビゲーションメッセージを表示します
        [self displayNavigationMessage];
    };
    
    // ポップオーバーを表示
    [self popoverItemSelectViewFrom:sender
                        withItemKey:@"handoutList"
                         postSelect:block];
    
    LEAVE_METHOD
}

/**
 * 提出物の編集ボタンを押下した時に呼ばれます。
 *
 * @param 提出物の編集ボタン
 */
- (void)rcptEditButtonTapped:(UIButton *)sender {
    ENTER_METHOD
    
    // ポップオーバーで選択した時の処理
    ItemSelectBlock block = ^(NSString *selected) {
        _detailItem.rcptName = selected;
        [self configureView];
        
        // このビューの入力ナビゲーションメッセージを表示します
        [self displayNavigationMessage];
    };
    
    // ポップオーバーを表示
    [self popoverItemSelectViewFrom:sender
                        withItemKey:@"rcptList"
                         postSelect:block];
    
    LEAVE_METHOD
}

/**
 * メモの編集ボタンを押下した時に呼ばれます。
 *
 * @param メモの編集ボタン
 */
- (void)remColEditButtonTapped:(UIButton *)sender {
    ENTER_METHOD
    
    // ポップオーバーで選択した時の処理
    ItemSelectBlock block = ^(NSString *selected) {
        // メモ欄に入力があればその後に改行して追記
        NSString *text = self.remColTextView.text;
        if (text && text.length > 0) {
            text = [NSString stringWithFormat:@"%@\n%@", self.remColTextView.text, selected];
        } else {
            text = selected;
        }
        
        _detailItem.remCol = text;
        [self configureView];
        
        // このビューの入力ナビゲーションメッセージを表示します
        [self displayNavigationMessage];
    };
    
    // ポップオーバーを表示
    [self popoverItemSelectViewFrom:sender
                        withItemKey:@"remColList"
                         postSelect:block];
    
    LEAVE_METHOD
}

/**
 * 配布物、提出物、メモを選択するためのビューをポップオーバーします。
 *
 * @param button 押下したボタン
 * @param itemKey ビューに表示するリストのキー
 * @param postSelect 選択後の処理をするブロック
 */
- (void)popoverItemSelectViewFrom:(UIButton *)button withItemKey:(NSString *)itemKey postSelect:(ItemSelectBlock)postSelect {
    ENTER_METHOD
    
    // ポップオーバーするビューを作成
    ItemSelectViewController *view = [[ItemSelectViewController alloc] init];
    
    // 選択肢リストを取得してポップオーバーにセット
    NSArray *items = [[Cat sharedInstance] arrayForKey:itemKey];
    view.items = items;
    
    // ポップオーバーの高さを表示に必要な高さに調整
    view.contentSizeForViewInPopover = CGSizeMake(300, [view getTableHeight]);
    
    // ポップオーバーを作成
    _popover = [[UIPopoverController alloc] initWithContentViewController:view];
    
    // ポップオーバーで選択後の処理に、ポップオーバーを閉じる処理とメモリ解放処理を追加
    view.postSelect = ^(NSString *selected) {
        postSelect(selected);
        [_popover dismissPopoverAnimated:YES];
        _popover = nil;
    };
    
    // ポップオーバーを表示
    [_popover presentPopoverFromRect:button.frame
                              inView:button.superview
            permittedArrowDirections:UIPopoverArrowDirectionAny
                            animated:YES];
    
    LEAVE_METHOD
}

/**
 * このビュー内のテキストフィールドに入力可能な最大桁を設定します
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    ENTER_METHOD
    
    int tag = textField.tag;
    
    // 配布物名、提出物名だった場合
    if (tag == TAG_DETAIL_HANDOUT_NAME ||
        tag == TAG_DETAIL_RCPT_NAME) {
        
        // 入力済みのテキストを取得
        NSMutableString *str = [textField.text mutableCopy];
        // 入力済みのテキストと入力が行われたテキストを結合
        [str replaceCharactersInRange:range withString:string];
        // テキストが最大長を超えている場合は入力を打ち消す
        if (str.length > DETAIL_ITEM_MAX_LENGTH) {
            return NO;
        }
    }
    
    LEAVE_METHOD
    
    return YES;
}

/**
 * このビューの入力ナビゲーションメッセージを表示します。
 */
- (void)displayNavigationMessage {
    ENTER_METHOD
    
    if (!_detailItem) {
        LEAVE_METHOD
        return;
    }
    
    NSString *message = nil;
    NSString *situation = nil;
    
    if ([ATT_CAT_NOT_YET isEqualToString:_detailItem.attCat]) {
        message = @"出席ボタンを\n押下してください。";
        situation = SITUATION_ENTER_ATTENDANCE_CAT;
    } else if ([_detailItem hasHandout] && [HANDOUT_CAT_NOT_YET isEqualToString:_detailItem.handoutSitCat]) {
        message = @"配布物を受け取り、\nOKボタンを\n押下してください。";
        situation = SITUATION_ENTER_HANDOUT_CAT;
    } else if ([_detailItem hasRcpt] && [RCPT_CAT_NOT_YET isEqualToString:_detailItem.rcptSitCat]) {
        message = @"提出物を提出し、\nOKボタンを\n押下してください。";
        situation = SITUATION_ENTER_RCPT_CAT;
    } else if (![_detailItem isEqual:_originalDetail]) {
        message = @"入力内容がよろしければ\n確定ボタンを押下してください。";
        situation = SITUATION_PUSH_SUBMIT_BUTTON;
    } else {
        situation = SITUATION_VOID;
    }
    
    [_delegate showMessage:message
                        at:situation
                   okBlock:nil
                cancelBlck:nil];
    
    LEAVE_METHOD
}

@end
