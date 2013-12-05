# KinectDraw

This is a Processing sketch that allows you to draw pictures using a computer and an Xbox360 Kinect camera.

## Usage

Your right hand is the brush, and the height of your left hand determines the brush size.  To change paint color, touch a color bar at the top of the screen.  To change which paint colors are available, touch a color group at the bottom of the screen.

![Screenshot](https://raw.github.com/pjvandehaar/KinectDraw/master/screenshot.jpg)

## Installing

### Materials

* a computer with Windows, Mac OSX, or Linux.
* an Xbox 360 Kinect
* an adapter cable to connect them. (<$10)

### Instructions

1. Visit to the simpleopenni install page.
2. Follow the directions there for your OS. You should probably remove any other Kinect drivers (eg the official MS ones) that you have installed.
3. Two options here; on my Windows 7 64-bit I used the first.

    * Follow the link on the opensimpleni install page to download Java SE 7. Then, on the Processing homepage, download the "No Java" version. Ignore the part about a Java folder.
    * Just download Processing with Java from the homepage. (I haven't tried this but think it ought to work fine.)

4. Run processing once to generate a sketches folder.
5. When told to copy the file "SimpleOpenNI.zip", it actually means to extract it to there. (eg, it should wind up as a directory instead of a zip file.)
6. Copy `KinectDraw.pde` into your sketches (eg ".../Documents/Processing/") folder.
7. Open up processing; file->open `KinectDraw.pde`.
8. Click sketch->present to run in fullscreen.
