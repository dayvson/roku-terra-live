Introduction
------------
This software is a ROKU front-end to the TERRA NETWORKS Live Events.  It provides the following features:
 * Full catalog live events 
 * Play live event in HD

Tested on Roku firmware version 3.1 ROKU 1 and 4.8 ROKU 2
Install this channel https://owner.roku.com/add/TERRALIVE
Watch this video to see how this channels works https://vimeo.com/46876811


Run this code on your ROKU
--------------------------
Enable developer mode in ROKU
http://sdkdocs.roku.com/display/RokuSDKv43/Developer+Guide#DeveloperGuide-52ApplicationSecurity

Set ROKU_DEV_TARGET in your environment in .bashrc or .profile
<pre>
export ROKU_DEV_TARGET=YOUR_ROKU_IP
</pre>

To create the zip file with your project
<pre>
make
</pre>

To install in your roku via developer mode
<pre>
make install
</pre>

