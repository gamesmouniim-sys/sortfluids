#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>

// -1 = request not yet complete, 0-3 = ATTrackingManagerAuthorizationStatus value
static int s_att_pending_result = -1;

// Called from C# (no callback — avoids IL2CPP delegate-marshal crash).
// Triggers the system ATT prompt; result is stored in s_att_pending_result.
void _RequestATT(void) {
    s_att_pending_result = -1;
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                s_att_pending_result = (int)status;
            });
        }];
    } else {
        s_att_pending_result = 3; // Authorized on iOS < 14
    }
}

// Returns -1 while the prompt is pending, or the status once the user responds.
int _PollATTResult(void) {
    return s_att_pending_result;
}

int _GetATTStatus() {
    if (@available(iOS 14, *)) {
        return (int)[ATTrackingManager trackingAuthorizationStatus];
    }
    return 3; // Authorized
}
