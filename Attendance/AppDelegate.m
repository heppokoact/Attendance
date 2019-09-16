
#import "AppDelegate.h"

#import "MasterViewController.h"
#import "EmployeeSettingsViewController.h"
#import "DetailViewController.h"
#import "ResetableViewController.h"
#import "FairyMessageDelegate.h"
//#import "MessageDelegate.h"
#import "AlertViewMessageDelegate.h"

@implementation AppDelegate {
    // メッセージ表示処理を行うオブジェクト
    id<MessageDelegate> _messageDelegate;
}

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

/**
 * アプリケーションが起動完了した直後に呼び出されるデリゲートメソッドです.
 * @param application アプリケーション
 * @param launchOptions 起動オプション
 * @return
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ENTER_METHOD
    
    // Override point for customization after application launch.
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    splitViewController.delegate = (id)navigationController.topViewController;
    
    //    UINavigationController *masterNavigationController = [splitViewController.viewControllers objectAtIndex:0];
    //    MasterViewController *controller = (MasterViewController *)masterNavigationController.topViewController;
    //    controller.managedObjectContext = self.managedObjectContext;
    
    // 例外発生時のハンドリング処理を追加
    NSSetUncaughtExceptionHandler(&exceptionHandler);
    
    [self.window makeKeyAndVisible];
    
    // メッセージ表示処理を行うオブジェクトを作成
    //_messageDelegate = [[AlertViewMessageDelegate alloc] init];
    _messageDelegate = [[FairyMessageDelegate alloc] init];
    
    LEAVE_METHOD
    return YES;
}

/**
 * 例外発生時のハンドリング処理。
 * コンソールにスタックトレースを出力すると共に、同じ内容をUserDefaultsに書き出します。
 */
void exceptionHandler(NSException *exception) {
    // 例外情報をコンソールに出力
    NSLog(@"%@", exception.name);
    NSLog(@"%@", exception.reason);
    NSLog(@"%@", exception.callStackSymbols);
    
    // 例外情報をUserDefaulsに出力
    NSDate *date = [NSDate date];
    NSString *log = [NSString stringWithFormat:@"Date: %@\nExceptionName: %@\nReason: %@\n%@", date, exception.name, exception.reason, exception.callStackSymbols];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:log forKey:@"failLog"];
    [userDefaults synchronize];
}

/**
 * アプリケーションが非アクティブになる直前に呼び出されるデリゲートメソッドです.
 * @param application アプリケーション
 */
- (void)applicationWillResignActive:(UIApplication *)application
{
    ENTER_METHOD
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    LEAVE_METHOD
}

/**
 * アプリケーションがバックグラウンドになった直後に呼び出されるデリゲートメソッドです.
 * @param application アプリケーション
 */
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    ENTER_METHOD
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    // 管理オブジェクトコンテキストの保存
    [self saveContext];
    LEAVE_METHOD
}

/**
 * アプリケーションがフォアグラウンドになる直前に呼び出されるデリゲートメソッドです.
 * @param application アプリケーション
 */
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    ENTER_METHOD
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    LEAVE_METHOD
}

/**
 * アプリケーションがアクティブになった直後に呼び出されるデリゲートメソッドです.
 * @param application アプリケーション
 */
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    ENTER_METHOD
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    LEAVE_METHOD
}

/**
 * アプリケーションが終了する直前に呼び出されるデリゲートメソッドです.
 * iOS4以降はマルチタスクの為、基本的には本メソッドでなく
 * applicationDidEnterBackground:が呼び出される.
 * 但し、システムが何らかの理由でバックグラウンドで実行中の
 * アプリケーションを終了する為にこのメソッドを呼び出す可能性がある.
 * @param application アプリケーション
 */
- (void)applicationWillTerminate:(UIApplication *)application
{
    ENTER_METHOD
    // Saves changes in the application's managed object context before the application terminates.
    // 管理オブジェクトコンテキストの保存
    [self saveContext];
    LEAVE_METHOD
}

/**
 * 管理オブジェクトコンテキストを保存します.
 */
- (void)saveContext
{
    ENTER_METHOD
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    LEAVE_METHOD
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
/**
 * 管理オブジェクトコンテキストを返却します.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    ENTER_METHOD
    if (__managedObjectContext != nil) {
        LEAVE_METHOD
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    LEAVE_METHOD
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
/**
 * 管理オブジェクトモデルを返却します.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    ENTER_METHOD
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Attendance" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    LEAVE_METHOD
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
/**
 * 永続ストアコーディネータを返却します.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    ENTER_METHOD
    if (__persistentStoreCoordinator != nil) {
        LEAVE_METHOD
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Attendance.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    LEAVE_METHOD
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
/**
 * アプリケーションのドキュメントディレクトリを返却します.
 */
- (NSURL *)applicationDocumentsDirectory
{
    ENTER_METHOD
    LEAVE_METHOD
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/**
 * エラーログをコンソールとUserDefaultsに出力します。
 */
- (void) outputErrorLog:(NSError *)err forKey:(NSString *)key {
    ENTER_METHOD
    
    NSLog(@"%@", key);
    NSString *log = nil;
    NSDate *date = [NSDate date];
    
    if (err) {
        NSLog(@"ErrorCode: %d", err.code);
        NSLog(@"Domain: %@", err.domain);
        NSLog(@"%@", err.userInfo);
        
        log = [NSString stringWithFormat:@"Date: %@\nErrorCode: %d\nDomain: %@\n%@", date, err.code, err.domain, err.userInfo];
    } else {
        NSLog(@"ErrorCode: %d", errno);
        NSLog(@"%s", strerror(errno));
        
        log = [NSString stringWithFormat:@"Date: %@\nErrorCode: %d\n%s", date, errno, strerror(errno)];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:log forKey:key];
    [userDefaults synchronize];
    
    LEAVE_METHOD
}

/**
 * 現在使用されているMasterViewControllerを取得します。
 */
- (MasterViewController *)obtainMasterViewController {
    // SplitViewControllerから左側のNavigationControllerを取得
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers objectAtIndex:0];
    
    // 左側で使用されているViewの中からMasterViewControllerを探して返す
    for (UIViewController *viewController in navigationController.viewControllers) {
        if ([viewController isKindOfClass:[MasterViewController class]]) {
            return (MasterViewController *)viewController;
        }
    }
    
    return nil;
}

/**
 * 現在使用されているEmployeeSettingsViewControllerを取得します。
 */
- (EmployeeSettingsViewController *)obtainEmployeeSettingsViewController {
    return (EmployeeSettingsViewController *)[self obtainRightPainViewControllerOf:[EmployeeSettingsViewController class]];
}

/**
 * 現在使用されているDetailViewControllerを取得します。
 */
- (DetailViewController *)obtainDetailViewController {
    return (DetailViewController *)[self obtainRightPainViewControllerOf:[DetailViewController class]];
}

/**
 * 右ペインに表示されているビューのコントローラを取得します。
 * 引数のクラスで指定したビューがない場合はnilを返します。
 *
 * @param class 右ペインに表示されるビューコントローラのクラス
 */
- (UIViewController *)obtainRightPainViewControllerOf:(Class)class {
    UINavigationController *navigationController = [self obtainRightNavigationController];
    for (UIViewController *viewController in navigationController.viewControllers) {
        if ([viewController isKindOfClass:class]) {
            return viewController;
        }
    }

    return nil;
}

/**
 * 画面右側のNavigationControllerを取得します。
 *
 * @return 画面右側のNavigationController
 */
- (UINavigationController *)obtainRightNavigationController {
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    return [splitViewController.viewControllers lastObject];
}

/**
 * 画面右側のビューをリセットします。
 */
- (void)resetRightView {
    UINavigationController *navgationController = [self  obtainRightNavigationController];
    for (UIViewController<ResetableViewController> *viewController in navgationController.viewControllers) {
        [viewController resetView];
    }
}

/**
 * 引数の状況にひもづけられたメッセージを表示します。
 *
 * @param message メッセージ
 * @param situation 状況を表すキー
 * @param okBlock OKボタンを押下した時に実行するブロック
 * @param cancel キャンセルボタンを押下した時に実行するブロック
 */
- (void)showMessage:(NSString *)message at:(NSString *)situation okBlock:(BKBlock)okBlock cancelBlck:(BKBlock)cancelBlock {
    [_messageDelegate showMessage:message
                               at:situation
                          okBlock:okBlock
                       cancelBlck:cancelBlock];
}

- (void)dismissMessage {
    [_messageDelegate showMessage:nil
                               at:SITUATION_VOID
                          okBlock:nil
                       cancelBlck:nil];
}

- (NSString *)getCurrentSituation {
    return [_messageDelegate getCurrentSituation];
}

@end
