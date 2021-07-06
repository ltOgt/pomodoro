# TODO
currently the timer suspends when you switch to another tab or minimize the browser.
need to implement background process (which might not yet be available for web).
alternatively can use https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver/didChangeAppLifecycleState.html to safe time on focus loss and restore from that with elapsed time. Wont fix notification though.
https://stackoverflow.com/a/57271270/7215915 mentions playing an audio track in background to stay active even on focus loss.

### workaround
Simply run the site in app mode `$ chrome --app=https://omnesia.org/pomodoro`

# pomodoro
A quick little pomodoro timer written in flutter.

Try it at https://omnesia.org/pomodoro/#/
