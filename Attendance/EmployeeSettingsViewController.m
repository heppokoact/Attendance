
#import "EmployeeSettingsViewController.h"
#import "AppDelegate.h"
#import "Attendance.h"
#import "AttendanceDao.h"

@interface EmployeeSettingsViewController ()

@end

@implementation EmployeeSettingsViewController {
    // AppDelegate
    AppDelegate *_delegate;
}

@synthesize detailItem = _detailItem;
@synthesize empNo = _empNo;
@synthesize empName = _empName;
@synthesize postName = _postName;
@synthesize grpName = _grpName;
@synthesize pjName = _pjName;
@synthesize dispCat = _dispCat;

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
    
    _delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    LEAVE_METHOD
}

/**
 * ビューが表示される直前に呼び出されるメソッドです.
 */
- (void)viewWillAppear:(BOOL)animated
{
    ENTER_METHOD
    
    [self configureView];
    
    LEAVE_METHOD
}

/**
 * このビューの内容を描画します
 */
- (void)configureView {
    ENTER_METHOD
    
    if (self.detailItem) {
        self.empNo.text = self.detailItem.empNo;
        self.empName.text = self.detailItem.empName;
        self.postName.text = self.detailItem.postName;
        self.grpName.text = self.detailItem.grpName;
        self.pjName.text = self.detailItem.pjName;
        self.dispCat.text = self.detailItem.dispCat;
        
    } else {
        self.empNo.text = nil;
        self.empName.text = nil;
        self.postName.text = nil;
        self.grpName.text = nil;
        self.pjName.text = nil;
        self.dispCat.text = nil;
    }
    
    LEAVE_METHOD
}

/**
 * このビューの表示内容をカラにします。
 */
- (void)resetView {
    ENTER_METHOD
    
    self.detailItem = nil;
    [self configureView];
    
    // このビューを閉じて前のビューに戻る
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    LEAVE_METHOD
}

/**
 * ビューが非表示になる直前に呼び出されるメソッドです.
 */
- (void)viewWillDisappear:(BOOL)animated
{
    ENTER_METHOD
    self.detailItem = nil;
    LEAVE_METHOD
}

/**
 * 出席データをセットします。
 */
- (void)setDetailItem:(Attendance *)detailItem {
    ENTER_METHOD
    
    _detailItem = detailItem;
    [self configureView];
    
    LEAVE_METHOD
}

/**
 * ビューがメモリからアンロードされた直後に呼び出されるメソッドです.
 */
- (void)viewDidUnload
{
    ENTER_METHOD
    [self setEmpNo:nil];
    [self setEmpName:nil];
    [self setPostName:nil];
    [self setGrpName:nil];
    [self setPjName:nil];
    [self setDispCat:nil];
    _delegate = nil;
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

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}
*/
/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}
*/
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ENTER_METHOD
    // Navigation logic may go here. Create and push another view controller.
    /*
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    LEAVE_METHOD
}

@end
