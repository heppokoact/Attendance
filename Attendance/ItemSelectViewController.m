//
//  ItemSelectViewController.m
//  Attendance
//
//  Created by heppokoact on 2013/05/04.
//
//

#import "ItemSelectViewController.h"
#import "Cat.h"

#define ITEM_SELECT_VIEW_CELL_IDENTIFIER @"ItemSelectViewCellIdentifier"

@interface ItemSelectViewController () {
}

@end

/**
 * 配布物、提出物、メモを選択するためのビューコントローラです。
 */
@implementation ItemSelectViewController

/**
 * ビューがメモリにロードされた直後に呼び出されるメソッドです.
 * ビューが表示される時、ビューが既にメモリ上に存在する場合は呼び出されないことに注意してください.
 */
- (void)viewDidLoad
{
    ENTER_METHOD
    
    [super viewDidLoad];
    
    LEAVE_METHOD
}

/**
 * ビューが表示される直前に呼び出されるメソッドです.
 */
- (void)viewWillAppear:(BOOL)animated
{
    ENTER_METHOD
    LEAVE_METHOD
}

/**
 * ビューがメモリからアンロードされた直後に呼び出されるメソッドです.
 */
- (void)viewDidUnload {
    ENTER_METHOD
    
    self.postSelect = nil;
    self.items = nil;
    [super viewDidUnload];
    
    LEAVE_METHOD
}

/**
 * このテーブルの高さを取得します。
 *
 * @return このテーブルの高さ
 */
- (int)getTableHeight {
    ENTER_METHOD
    
    int height = 0;
    int rows = [self tableView:self.tableView numberOfRowsInSection:0];
    for (int i = 0; i < rows; i++ ) {
        height += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    }

    LEAVE_METHOD
    
    return height;
}

/**
 * 引数で指定したセクションの行数を返します。
 *
 * @param tableView テーブルビュー
 * @param section セクション番号
 * @param 引数で指定したセクションの行数
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ENTER_METHOD
    
    NSInteger rows = self.items.count;
    
    LEAVE_METHOD
    
    return rows;
}

/**
 * テーブルビューのセクション数を返却するデータソースメソッドです.
 *
 * @param tableView テーブルビュー
 * @return テーブルビューのセクション数
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    ENTER_METHOD
    LEAVE_METHOD
    return 1;
}

/**
 * 引数で指定したインデックスパスに表示するセルを返します。
 *
 * @param tableView テーブルビュー
 * @param indexPath 
 * @return　引数で指定したインデックスパスに表示するセル
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ENTER_METHOD
    
    // セルを取得、キャッシュがある場合はそこから取得、キャッシュから取得できた場合はサブビューをクリア
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ITEM_SELECT_VIEW_CELL_IDENTIFIER];
    if (cell) {
        for (UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    } else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ITEM_SELECT_VIEW_CELL_IDENTIFIER];
    }
    
    // セルに選択肢を表示
    CGSize cellSize = cell.frame.size;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, cellSize.width, cellSize.height)];
    label.text = [self.items objectAtIndex:indexPath.row];
    [cell.contentView addSubview:label];
    
    LEAVE_METHOD
    
    return cell;
}

/**
 * セルが選択された時に呼ばれます。
 *
 * @param tableView テーブルビュー
 * @param indexPath インデックスパス
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ENTER_METHOD
    
    self.postSelect([self.items objectAtIndex:indexPath.row]);
    
    LEAVE_METHOD
}

@end
