
#import <UIKit/UIKit.h>
#import "Attendance.h"
#import "ResetableViewController.h"

@interface EmployeeSettingsViewController : UITableViewController <ResetableViewController>

/** 選択データ */
@property (strong, nonatomic) Attendance *detailItem;

/** 社員番号 */
@property (weak, nonatomic) IBOutlet UILabel *empNo;
/** 社員名称 */
@property (weak, nonatomic) IBOutlet UILabel *empName;
/** 役職名称 */
@property (weak, nonatomic) IBOutlet UILabel *postName;
/** 所属名称 */
@property (weak, nonatomic) IBOutlet UILabel *grpName;
/** プロジェクト名称 */
@property (weak, nonatomic) IBOutlet UILabel *pjName;
/** 開封状況区分 */
@property (weak, nonatomic) IBOutlet UILabel *dispCat;

- (void)resetView;

@end
