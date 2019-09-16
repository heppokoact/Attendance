
#import <UIKit/UIKit.h>

//DetailViewControllerをプロパティとして使用するためディレクティブで指定
/*@classディレクティブは、コンパイラとリンカによって参照されるコードの量を最小限に抑えるため、クラス名の前方宣言を行う最も簡潔な方法です。簡潔であるため、他のファイルをインポートするファイルのインポートに伴う潜在的な問題が回避されます。たとえば、あるクラスが別のクラスの静的に型定義されたインスタンス変数を宣言していて、それぞれのインターフェイスファイルが互いをインポートすると、どちらのクラスも正しくコンパイルされない可能性があります。*/
#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSPredicate *predicate;
@property (strong, nonatomic) NSString *selectedTitle;

@property (strong, nonatomic) NSArray *employees;
@property (strong, nonatomic) NSArray *empNoIndexLabels;

@property (strong, nonatomic) UILabel *empNoLabel;
@property (strong, nonatomic) UILabel *empNameLabel;
@property (strong, nonatomic) UILabel *attCatLabel;
@property (strong, nonatomic) UILabel *handoutExistenceLabel;
@property (strong, nonatomic) UILabel *rcptExistenceLabel;
@property (strong, nonatomic) UILabel *noticeLabel;

/**
 * 抽出条件に応じたデータを取得し、ビューを描画する処理を外部から指示するためのインターフェースです。
 */
- (void)refreshView;

/**
 * 抽出条件に応じたデータを取得し、ビューを描画する処理を外部から指示するためのインターフェースです。
 * このインターフェースではウェイトレイヤーを表示しません。
 */
- (void)refreshViewWithoutProgress;
    
@end
