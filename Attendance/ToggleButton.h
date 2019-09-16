//
//  ToggleButton.h
//  Attendance
//
//  Created by heppokoact on 2013/05/18.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

/**
 * SegmentedControlでは複数の選択肢を同時に選択できないようなので、ボタンを利用して擬似的に実現するためのクラス。
 * 一度押下するとそのまま押下状態になり、そこでもう一度押下すると押下状態が解除される。
 */
@interface ToggleButton : UIButton

@end
