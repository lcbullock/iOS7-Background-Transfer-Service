#iOS7-Background-Transfer-Service


##Sample of using the iOS 7 Background Transfer Service (NSURLSession)


This sample shows the usage of the new background capabillities of NSURLSession in iOS 7. App does not require any
background permissions. NSURLSession code and delegates encapsulated into LCBDownloadHelper to minimize view controller and UI coupling.


###Use cases supported:
- Start download and put app in background (click home), transfer will continue.
- If app is resumed UI will show current status of continuing download.
- If download finished in background, app will change UI display in running apps list (double click HOME) to indicate that download is finished.
- If app crashes or is terminated by iOS (use crash app button to test) download will continue and app will be launched in background upon completion.
- If app is relaunched after crash/iOS termination, UI will resync with running session to show progress.
- In other cases where background download cannot complete, if user restarts download upon next launch of app we resume from partial download when possible. This happens when user kills app (swipe app up in launcher screen after double click home) as iOS will always terminate background transfer in response to user initiated kill.
  
###To do:
- Change UI to show multi-file download progress.
  
  
###Notes:
- The LCBDownloadHelper supports multiple sessions (additional helpers) or multiple download tasks per session. The test UI does not currently showcase this fact.
  
