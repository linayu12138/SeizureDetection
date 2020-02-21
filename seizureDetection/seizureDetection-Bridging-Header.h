//
//  seizureDetection-Bridging-Header.h
//  seizureDetection
//
//  Created by Danqiao Yu on 2/19/20.
//  Copyright © 2020 EEGIICs. All rights reserved.
//

#ifndef seizureDetection_Bridging_Header_h
#define seizureDetection_Bridging_Header_h

//#import "MSWeakTimer/MSWeakTimer.h"
#import <MSWeakTimer/MSWeakTimer.h>
//#import "NSObject+ENHThrottledReloading.h"
#import "NSObject+ENHThrottledReloading.h"
//#import "ISColorWheel.h"

#if TARGET_OS_MACCATALYST
    // ImageMagick libs are not compiled for macOS
#else
#import "ImageMagick.h"
#import "MagickWand.h"
#endif

#endif /* seizureDetection_Bridging_Header_h */
