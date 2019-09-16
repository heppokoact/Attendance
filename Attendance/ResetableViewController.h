//
//  ResetableViewController.h
//  Attendance
//
//  Created by heppokoact on 2013/02/07.
//
//

#import <Foundation/Foundation.h>

/**
 * 画面内容をリセットするメソッドを持ったViewControllerを表します。
 */
@protocol ResetableViewController <NSObject>

@required

/**
 * 画面内容をリセットします。
 */
- (void)resetView;

@end
