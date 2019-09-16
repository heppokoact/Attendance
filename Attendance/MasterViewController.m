
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "AppDelegate.h"
#import "AttendanceFetchedResultsController.h"
#import "Cat.h"
#import "AttendanceDao.h"
#import "AttendanceDomain.h"
#import "SearchPanelTableViewController.h"
#import "Util.h"

#define ATTENDANCE_CACHE_KEY                @"ATTENDANCE_CACHE_KEY"
#define USER_DEFAULTS_EMP_NO_FROM           @"empNoFrom"
#define USER_DEFAULTS_EMP_NO_TO             @"empNoTo"
#define IDENTIFIER_POPOVER_SEARCH_PANEL     @"PopoverSearchPanel"

@interface MasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MasterViewController {
    // AppDelegate
    AppDelegate *_delegate;
    
    // 検索パネルのポップオーバー。二重起動防止用
    UIPopoverController *_searchPanelController;
    // UIAlertViewを同期処理にするための変数
    BOOL _alertFinished;
    // DetailViewの変更内容を破棄するかどうか
    BOOL _shouldDetailItemDiscard;
    
    // 現在選択中の行番号
    NSIndexPath *_selectedIndexPath;
    
    // 出欠情報を取得するDao
    AttendanceDao *_dao;
    // 一覧に表示するデータ
    NSArray *_attendances;
    // セクションのタイトル
    NSArray *_sectionTitles;
    // 各セクションの開始インデックス
    NSDictionary *_sectionIndexes;
}

@synthesize managedObjectContext = __managedObjectContext;

@synthesize predicate = _predicate;
@synthesize selectedTitle = _selectedTitle;

@synthesize empNoLabel = _empNoLabel;
@synthesize empNameLabel = _empNameLabel;

/**
 * nibファイルからロードされたインスタンスの初期化メソッドです.
 */
- (void)awakeFromNib
{
    ENTER_METHOD
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    _delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [super awakeFromNib];
    LEAVE_METHOD
}

/**
 * ビューがメモリにロードされた直後に呼び出されるメソッドです.
 * ビューが表示される時、ビューが既にメモリ上に存在する場合は呼び出されないことに注意してください.
 */
- (void)viewDidLoad
{
    ENTER_METHOD
    [super viewDidLoad];
    
    // AppDelegateを用意
    _delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    LEAVE_METHOD
}

/**
 * ビューが表示される直前に呼ばれます。
 *
 * @param animated アニメーションするかどうか
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // セルの区切り線を消す
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

/**
 * ビューを描画します
 */
- (void)configureView {
    ENTER_METHOD
    
    // セクションインデックスを設定
    [self configureIndex];
    
    // ナビゲーションバーのタイトルを設定
    [self configureTitle];
    
    // 選択しているセルをクリア
    _selectedIndexPath = NULL;
    
    // DetailViewをクリア
    DetailViewController *detail = [_delegate obtainDetailViewController];
    [detail resetView];
    
    // データを再表示
    [self.tableView reloadData];
    
    LEAVE_METHOD
}

/**
 * セクションインデックスを計算します
 */
- (void)configureIndex {
    ENTER_METHOD
    
    // 出欠記録の所属セクションを取得
    NSMutableArray *sectionNames = [NSMutableArray array];
    for (Attendance *att in _attendances) {
        [sectionNames addObject:[att sectionName]];
    }
    
    // 出欠情報の所属セクションの重複を除去
    NSMutableOrderedSet *sectionTitles = [[NSMutableOrderedSet alloc] init];
    for (NSString *sectionName in sectionNames) {
        [sectionTitles addObject:sectionName];
    }
    _sectionTitles = [sectionTitles array];
    
    // 各セクションの開始インデックスを計算
    NSMutableDictionary *sectionIndexes = [NSMutableDictionary dictionary];
    int index = 0;
    for (NSString *sectionTitle in _sectionTitles) {
        while (![sectionTitle isEqualToString:[sectionNames objectAtIndex:index]]) {
            index++;
        }
        [sectionIndexes setObject:[NSNumber numberWithInt:index] forKey:sectionTitle];
    }
    _sectionIndexes = sectionIndexes;
    
    LEAVE_METHOD
}

/**
 * ナビゲーションバーにタイトルを設定します。
 */
- (void)configureTitle {
    ENTER_METHOD
    
    self.title = [NSString stringWithFormat:@"%@ (%d)", @"出力件数", _attendances.count];
    
    LEAVE_METHOD
}

/**
 * 抽出条件に応じたデータを取得し、ビューを描画する処理を外部から指示するためのインターフェースです。
 */
- (void)refreshView {
    ENTER_METHOD
    
    // 処理中メッセージを表示
    [_delegate showMessage:@"出欠記録取得中..."
                        at:SITUATION_START_GET_ATTENDANCES
                   okBlock:nil
                cancelBlck:nil];
    
    // データを取得、ビューを描画
    [self refreshViewInternal:^{
        // 社員未選択メッセージを表示
        [_delegate showMessage:@"一覧からご自分のお名前を\n選択してください。\n\n一覧右側のスクロールバーも\nご活用ください！"
                            at:SITUATION_SUCCESS_GET_ATTENDANCES
                       okBlock:nil
                    cancelBlck:nil];
    }];
    
    LEAVE_METHOD
}

/**
 * 抽出条件に応じたデータを取得し、ビューを描画する処理を外部から指示するためのインターフェースです。
 * このインターフェースではウェイトレイヤーを表示しません。
 */
- (void)refreshViewWithoutProgress {
    ENTER_METHOD
    
    [self refreshViewInternal:^{
        // 社員未選択メッセージを表示
        [NSTimer scheduledTimerWithTimeInterval:1.5
            block:^(NSTimeInterval interval) {
                // 登録完了直後、何もメッセージを表示する操作をしていなければ
                NSString *currentSituation = [_delegate getCurrentSituation];
                if ([SITUATION_SUCCESS_UPDATE_ATTENDANCE isEqualToString:currentSituation] ||
                        [SITUATION_ERROR isEqualToString:currentSituation]) {
                    [_delegate showMessage:@"一覧からご自分のお名前を\n選択してください。\n\n一覧右側のスクロールバーも\nご活用ください！"
                                        at:SITUATION_SUCCESS_GET_ATTENDANCES
                                   okBlock:nil
                                cancelBlck:nil];
                }
            }
            repeats:NO];
    }];
    
    LEAVE_METHOD
}

/**
 * 出欠記録を取得し、ビューを再描画します。
 */
- (void)refreshViewInternal:(BKBlock)afterBlock {
    ENTER_METHOD
    
    // 出欠情報取得処理を別スレッドで行う（そうしないとローディング表示の描画が出欠情報取得処理完了まで待たされるため）
    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(q_global, ^{
        
        // 一覧に表示するデータを取得
        _dao = [[AttendanceDao alloc] init];
        NSError *error = nil;
        AttendanceDomain *condition = [SearchPanelTableViewController searchCondition];
        _attendances = [_dao findByConditions:condition error:&error];
        
        // 画面の描画処理をメインスレッドで行う（UIKitはスレッドセーフでなく、メインスレッドからのみアクセスするルールであるため）
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                // エラーをユーザーに通知
                NSString *message = [Util buildErrorMessage:@"出欠情報の取得中にエラーが発生しました。\n下記メッセージを添えてシステム管理者に連絡してください。" error:error];
                [_delegate showMessage:message
                                    at:SITUATION_ERROR
                               okBlock:^{[_delegate dismissMessage];}
                            cancelBlck:nil];
            } else {
                // ポップオーバーが表示されていた場合、閉じる
                if (_searchPanelController && _searchPanelController.isPopoverVisible) {
                    [_searchPanelController dismissPopoverAnimated:YES];
                }
                
                // ビューを再描画
                [self configureView];
                
                // 事後処理を実施
                afterBlock();
            }
        });
    });
    
    LEAVE_METHOD
}

/**
 * ビューが表示されなくなった時に呼ばれます。
 */
-(void)viewDidDisappear:(BOOL)animated {
    ENTER_METHOD
    
    // 右側のビューをリセットします。
    [_delegate resetRightView];
    
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
    _delegate = nil;
    _selectedIndexPath = nil;
    _dao = nil;
    _attendances = nil;
    _sectionTitles = nil;
    _sectionIndexes = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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

/*
- (void)insertNewObject:(id)sender
{
    ENTER_METHOD
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    LEAVE_METHOD
}
*/

#pragma mark - Table View

/**
 * テーブルビューのセクション数を返却するデータソースメソッドです.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    ENTER_METHOD
    LEAVE_METHOD
    return 1;
}

/**
 * 指定されたセクションの行数を返却するデータソースメソッドです.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ENTER_METHOD
    LEAVE_METHOD
    return _attendances.count;
}

/**
 * 指定されたセクション、行のセルを返却するデータソースメソッドです.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ENTER_METHOD
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2"];
    [self configureCell:cell atIndexPath:indexPath];
    LEAVE_METHOD

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    ENTER_METHOD
    // Return NO if you do not want the specified item to be editable.
    LEAVE_METHOD
    return YES;
}

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ENTER_METHOD
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
    LEAVE_METHOD
}
*/

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    ENTER_METHOD
    // The table view should not be re-orderable.
    LEAVE_METHOD
    return NO;
}

/**
 * 行が選択された時に呼び出されます。
 */
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ENTER_METHOD
    
    // 選択したのがDetailViewで表示されている社員と同じ場合は何もしない
    DetailViewController *detail = [_delegate obtainDetailViewController];
    Attendance *detailItem = [detail getDetailItem];
    Attendance *newDetailItem = [_attendances objectAtIndex:indexPath.row];
    if (detailItem && [detailItem.empNo isEqualToString:newDetailItem.empNo]) {
        LEAVE_METHOD
        return nil;
    }
    
    _shouldDetailItemDiscard = YES;
    
    // DetailViewが変更されている場合、変更を破棄するかどうかを確認
    if ([detail isChanged]) {
        _alertFinished = NO;
        [_delegate showMessage:@"現在表示中の社員に対する編集内容は破棄されます。\nよろしいですか？"
                            at:SITUATION_DISCARD_DETAIL
                       okBlock:^(void) {
                           _alertFinished = YES;
                       }
                    cancelBlck:^(void) {
                        _shouldDetailItemDiscard = NO;
                        _alertFinished = YES;
                        [detail displayNavigationMessage];
                    }];
        
        // AlertViewを同期処理にするため、OKかキャンセルが押下されるまでここで処理を止める
        while (!_alertFinished) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
        }
    }
    
    LEAVE_METHOD
    
    return _shouldDetailItemDiscard ? indexPath : nil;
}

/**
 * 行が選択された時に呼び出されます（willSelectRowAtIndexPathのメソッドよりは後）。
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ENTER_METHOD
    
    // 選択行を保持
    NSIndexPath *prevIndexPath = _selectedIndexPath;
    _selectedIndexPath = indexPath;
    
    // 選択した行の出欠情報を強調表示
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self highlightEmployee:cell];
    // 以前まで選択されていた行の出欠情報の強調表示を解除
    UITableViewCell *prevCell = nil;
    if (prevIndexPath) {
        prevCell = [tableView cellForRowAtIndexPath:prevIndexPath];
        [self dehighlightEmployee:prevCell];
    }
    
    // DetailViewに選択した行の出席データをセット
    Attendance *newDetailItem = [_attendances objectAtIndex:indexPath.row];
    DetailViewController *detail = [_delegate obtainDetailViewController];
    [detail setDetailItem:newDetailItem];
    
    LEAVE_METHOD
}

/**
 * 行が選択解除された時に呼ばれます。
 */
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    ENTER_METHOD
    
    // 選択解除されたセルの社員番号と社員名を黒字に戻す
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self dehighlightEmployee:cell];
    
    LEAVE_METHOD
}

/**
 * 引数のセルの社員番号と社員名の色を引数の色に変更します。
 */
- (void)highlightEmployee:(UITableViewCell *)cell {
    ENTER_METHOD
    
    UILabel *empNoLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *empNameLabel = (UILabel *)[cell viewWithTag:2];
    empNameLabel.textColor = [UIColor blueColor];
    empNoLabel.textColor = [UIColor blueColor];
    
    LEAVE_METHOD
}

/**
 * 引数のセルの社員番号と社員名の色を引数の色に変更します。
 */
- (void)dehighlightEmployee:(UITableViewCell *)cell {
    ENTER_METHOD
    
    UILabel *empNoLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *empNameLabel = (UILabel *)[cell viewWithTag:2];
    empNameLabel.textColor = [UIColor blackColor];
    empNoLabel.textColor = [UIColor darkGrayColor];
    
    LEAVE_METHOD
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ENTER_METHOD
    LEAVE_METHOD
    return 62.0;
}

/**
 *　各セクションのタイトルを配列で取得します。
 *
 * @return セクションのタイトルの配列
 */
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    ENTER_METHOD
    LEAVE_METHOD
    
    return _sectionTitles;
}

/**
 * セクションリストをタップした時に呼ばれ、タップしたセクションのセクションインデックスを返します・・・が、
 * UITableViewでいうところの「セクション」は作成していないので、手動でそのセクションの先頭に移動します。
 *
 * @return タップしたセクションの開始インデックス（ダミー）
 */
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    ENTER_METHOD
    
    NSInteger sectionIndex = [[_sectionIndexes objectForKey:title] integerValue];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sectionIndex inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    LEAVE_METHOD
    
    return index;
}

#pragma mark - Fetched results controller

/**
 * MasterViewに表示するデータを管理するオブジェクトを取得します。
 *
 * @return MasterViewに表示するデータを管理するオブジェクトを取得します。
 */
/*
- (NSFetchedResultsController *)fetchedResultsController {
    ENTER_METHOD
    
    // MasterViewに表示するデータを管理するオブジェクトを取得します。
    NSFetchedResultsController *controller = [self fetchedResultsControllerInternal];
    
    // TopViewから遷移した初回は抽出条件をセットします。
    if (!_predicateReflected) {
        // この端末で表示する社員の範囲
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *empNoFrom = [userDefaults objectForKey:USER_DEFAULTS_EMP_NO_FROM];
        if (!empNoFrom || empNoFrom.length == 0) {
            empNoFrom = @"00000";
        }
        NSString *empNoTo = [userDefaults objectForKey:USER_DEFAULTS_EMP_NO_TO];
        if (!empNoTo || empNoTo.length == 0) {
            empNoTo = @"99999";
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"empNo >= %@ AND empNo <= %@", empNoFrom, empNoTo];
        
        // TopViewで選択した抽出条件があれば合成
        if (self.predicate) {
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, self.predicate]];
        }
        
        // NSFetchedResultsControllerに抽出条件をセット
        controller.fetchRequest.predicate = predicate;
        // 昔の抽出結果がキャッシュされているので削除
        [NSFetchedResultsController deleteCacheWithName:ATTENDANCE_CACHE_KEY];
        _predicateReflected = YES;
    }
    
    LEAVE_METHOD
    return controller;
}
*/

/**
 * MasterViewに表示するデータを管理するオブジェクトを取得します。
 * ただし、絞り込み条件はセットしません。
 * 絞り込み条件はこのメソッドの呼び出し元である、fetchedResultsControllerでセットします。
 *
 * @return MasterViewに表示するデータを管理するオブジェクトを取得します。
 */
/*
- (NSFetchedResultsController *)fetchedResultsControllerInternal
{
    ENTER_METHOD
    if (__fetchedResultsController != nil) {
        LEAVE_METHOD
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Attendance" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"empNo" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[AttendanceFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"sectionName" cacheName:ATTENDANCE_CACHE_KEY];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate outputErrorLog:error forKey: @"masterViewFetchError"];
        LEAVE_METHOD
        return nil;
	}
    
    LEAVE_METHOD
    return __fetchedResultsController;
}    
*/

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    ENTER_METHOD
    [self.tableView beginUpdates];
    LEAVE_METHOD
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    ENTER_METHOD
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    LEAVE_METHOD
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    ENTER_METHOD
    UITableView *tableView = self.tableView;
    
    [self configureTitle];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    LEAVE_METHOD
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    ENTER_METHOD
    [self.tableView endUpdates];
    LEAVE_METHOD
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

/**
 * セルの表示内容を設定します。
 *
 * @param cell 設定するセル
 * @param indexPath セルのindex
 */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ENTER_METHOD
    Attendance *att = [_attendances objectAtIndex:indexPath.row];
    
    // 各種ラベルを取得
    UILabel *empNoLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *empNameLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *noticeLabel = (UILabel *)[cell viewWithTag:12];
    UIImageView *attImage = (UIImageView *)[cell viewWithTag:21];
    UIImageView *handoutImage = (UIImageView *)[cell viewWithTag:22];
    UIImageView *rcptImage = (UIImageView *)[cell viewWithTag:23];
    
    // 社員番号と社員名ラベルに値をセット
    empNoLabel.text = att.empNo;
    empNameLabel.text = att.empName;
    // 配布物の画像をセット
    NSDictionary *imageDict = nil;
    NSString *imageName = nil;
    UIImage *image = nil;
    if (att.handoutName && att.handoutName.length > 0) {
        imageDict = [[Cat sharedInstance] dictForKey:@"handoutSitCatImageMini"];
        imageName = [imageDict objectForKey:att.handoutSitCat];
        image = [UIImage imageNamed:imageName];
    } else {
        image = nil;
    }
    handoutImage.image = image;
    // 提出物の画像をセット
    if (att.rcptName && att.rcptName.length > 0) {
        imageDict = [[Cat sharedInstance] dictForKey:@"rcptSitCatImageMini"];
        imageName = [imageDict objectForKey:att.rcptSitCat];
        image = [UIImage imageNamed:imageName];
    } else {
        image = nil;
    }
    rcptImage.image = image;
    // 用途不明
    noticeLabel.text = @""; 
    // 出席状況の画像を表示
    imageDict = [[Cat sharedInstance] dictForKey:@"attCatImageMini"];
    imageName = [imageDict objectForKey:att.attCat];
    attImage.image = [UIImage imageNamed:imageName];
    
    // 背景を設定
    image = [UIImage imageNamed:@"master_background.png"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:image];
    cell.backgroundView = backgroundView;
    
    // 選択中のセルなら文字を青くする。そうでなければ黒くする。
    if (_selectedIndexPath &&
        _selectedIndexPath.section == indexPath.section &&
        _selectedIndexPath.row == indexPath.row) {
        [self highlightEmployee:cell];
    } else {
        [self dehighlightEmployee:cell];
    }
    
    LEAVE_METHOD
}

/**
 * セルのスワイプで削除ボタンが出ないようにする
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

/**
 * Segueによる画面遷移時に呼ばれます。
 *
 * @param segue 実行中のSegue
 * @param sender Segueを実行するトリガーとなったオブジェクト
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ENTER_METHOD
    
    // 検索パネルのポップオーバーである場合
    if ([IDENTIFIER_POPOVER_SEARCH_PANEL isEqualToString:segue.identifier]) {
        
        // popoverを開いて良いかどうかの判定用に検索パネルのViewControllerを保持する
        UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
        _searchPanelController = popoverSegue.popoverController;
    }
    
    LEAVE_METHOD
}

/**
 * Segueによる画面遷移直前に呼ばれ、Segueを実行して良いかどうかを判定します。
 *
 * @param identifier Segueのidentifier
 * @param sender Segueを実行するトリガーとなったオブジェクト
 * @return Segueを実行して良ければYES
 */
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    ENTER_METHOD
    
    // 検索パネルのポップオーバーである場合
    if ([IDENTIFIER_POPOVER_SEARCH_PANEL isEqualToString:identifier]) {
        // BarButtonはpopoverが開いている間も常に有効な為、popoverが複数重なって開いてしまう
        // その為、既にpopoverを開いている場合はpopoverの表示を許可しない
        if (_searchPanelController && [_searchPanelController isPopoverVisible]) {
            return NO;
        }
    }
    
    LEAVE_METHOD
    
    return YES;
}

@end
