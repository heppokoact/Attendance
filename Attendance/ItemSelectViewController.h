//
//  ItemSelectViewController.h
//  Attendance
//
//  Created by heppokoact on 2013/05/04.
//
//

#import <UIKit/UIKit.h>

/**
 * 選択肢を選択した後に実行する処理のブロック
 */
typedef void (^ItemSelectBlock)(NSString *selected);

/**
 * 配布物、提出物、メモを選択するためのビューコントローラです。
 */
@interface ItemSelectViewController : UITableViewController 

@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) ItemSelectBlock postSelect;

/**
 * このテーブルの高さを取得します。
 *
 * @return このテーブルの高さ
 */
- (int)getTableHeight;

@end
