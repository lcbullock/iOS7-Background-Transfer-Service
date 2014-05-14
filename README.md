#iOS7-Background-Transfer-Service


##Sample of using the iOS 7 Background Transfer Service (NSURLSession)


This sample shows the usage of the new background capabillities of NSURLSession in iOS 7. App does not require any
background permissions.


###Use cases supported:
- Start download and put app in background (click home), transfer will continue.
- If app is resumed UI will show current status of continuing download.
- If download finished in background, app will change UI display in running apps list (double click HOME) to indicate that download is finished.
- If app crashes or is terminated by iOS (use crash app button to test) download will continue and app will be launched in background upon completion.
- If app is relaunched after crash/iOS termination, UI will resync with running session to show progress.
  
###To do:
- Handle resuming partial download. If download cannot complete in background, we can resume from partial progress when network is available.
- We can also use this to resume a download upon app launch when the app was killed by user (swiping up in running apps list). When app termination is user initiated iOS will not continue the background download but we can resume from current progress when user relaunches app.
  
  
###Notes:
- The LCBDownloadHelper supports multiple sessions (additional helpers) or multiple download tasks per session. The test UI does not currently showcase this fact.
  
