![2021102718:52:01_screenshot_sel](https://user-images.githubusercontent.com/24209580/139111264-b264bed4-5e02-4eac-88b9-560d4229d1aa.png)

# pomodoro
A quick little pomodoro timer written in flutter.

Try it at https://omnesia.org/pomodoro/#/

Currently works best when run in app mode:
`$ chrome --app=https://omnesia.org/pomodoro`


# ISSUE
currently the timer suspends when you switch to another tab or minimize the browser.

need to implement background process (which might not yet be available for flutter web).

This issue has low priority for me, since I only use this tool in app mode anyway

## notes / TODO
alternatively can use https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver/didChangeAppLifecycleState.html to safe time on focus loss and restore from that with elapsed time. Wont fix notification though.

https://stackoverflow.com/a/57271270/7215915 mentions playing an audio track in background to stay active even on focus loss.

https://github.com/flutter/flutter/issues/33577

### workaround
Simply run the site in app mode 
