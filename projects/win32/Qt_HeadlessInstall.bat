
@echo off

REM Setup some environment variables in order to collect those into a single location
set NX_SDK=@NX_SDK@


@QT5_ONLINE_INSTALLER@ --script @JSFILE@

