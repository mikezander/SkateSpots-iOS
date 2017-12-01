![sk8spots_logo](https://user-images.githubusercontent.com/16570082/29876124-e6984376-8d69-11e7-9ba1-eea46375c1e1.png)
# SkateSpots-iOS
Now Available on the App Store!
https://itunes.apple.com/us/app/sk8spots-skateboard-spots/id1281370899?mt=8

This repository contains a location based skateboard spot app, that lets skaters share skateboard spots around the world.

## Download

**Minimum Requirements**
* Xcode 8.3
* iOS 10.3 SDK
* macOS Sierra


Open your terminal and enter the command: `git clone https://github.com/mikezander/SkateSpots-iOS` to clone the project.

## Technical Features

* Retrieve location based off photo metadata & location
* Complex image caching & storage
* Firebase cloud functions using NodeJS for push notifications
* Facebook API to authenticate users and extract profile information
* Cosmos framework for star ratings
* Nested table, collection, and scroll views

## App Description

 **Log in screen**
 
 Upon lauch the user is directed to the log in screen to enter their credentials to either sign up for an account or log in to an existing account. The user may also sign in using their facebook account.

![screen shot 2017-08-30 at 10 57 45 am](https://user-images.githubusercontent.com/16570082/29879098-20b99f34-8d72-11e7-8bba-de888f8ba4c2.png)

**Main Feed**

After successfully logging in the user gets directed to the main feed. The main feed consists of uploaded skate spots that the user can sort by either most recently uploaded or closest to their location. They can then further sort by different spot types (i.e. Skatepark, Ledges, Rails).
Each spot on the main feed includes photo/s, spot name, spot location, calcuated distance, driving direction, and the user who contributed the spot.

<img src="https://user-images.githubusercontent.com/16570082/33298570-1d9ddd22-d3b5-11e7-84b7-81381f9a2b43.png" alt="alt text" width="415" height="750"> 
<img src="https://user-images.githubusercontent.com/16570082/33298573-1ef6146e-d3b5-11e7-9055-a12be2337408.png" alt="alt text" width="415" height="750">

**Upload a spot**

In order to upload a spot, the user must capture photo/s at the spot and upload them by either using their camera or photo library.The user must then enter in required description fields for the spot and hit the add spot button to finish spot upload.

<img src="https://user-images.githubusercontent.com/16570082/33299136-42502c08-d3b8-11e7-9f89-bf93d8df6334.png" alt="alt text" width="415" height="750"> 
<img src="https://user-images.githubusercontent.com/16570082/33299055-c8db3a98-d3b7-11e7-98ab-0b5b5a0b9a94.png" alt="alt text" width="415" height="300">


**Map view**

The map view centers on the users location and users can then locate the spots(pins) on the map. Clicking on the spot pin opens a dialog window with the spot's basic information. The user can click on the dialog window to get redirected to the spot's detail page.

<img src="https://user-images.githubusercontent.com/16570082/33299463-bddef51a-d3b9-11e7-9f3b-bd3b73690000.png" alt="alt text" width="415" height="750">

**Spot Detail**

<img src="https://user-images.githubusercontent.com/16570082/33299642-90ae8122-d3ba-11e7-9389-f691f161003e.png" alt="alt text" width="415" height="750">
<img src="https://user-images.githubusercontent.com/16570082/33299708-e23f86ee-d3ba-11e7-9f9f-2e3f5d63c088.png" alt="alt text" width="415" height="750">
<img src="https://user-images.githubusercontent.com/16570082/33299745-1be924e0-d3bb-11e7-8105-8ddaa954bccf.png" alt="alt text" width="415" height="225">


**Favorites**

<img src="https://user-images.githubusercontent.com/16570082/33299821-62496a6c-d3bb-11e7-8a56-707dea26b5e9.png" alt="alt text" width="415" height="750">

**Profile**

![screen shot 2017-08-30 at 5 02 41 pm](https://user-images.githubusercontent.com/16570082/29895032-91a952a6-8da5-11e7-9971-75daff9421c3.png)

**Edit Profile**

![screen shot 2017-08-30 at 5 04 00 pm](https://user-images.githubusercontent.com/16570082/29895057-aad4a744-8da5-11e7-941c-07083d21c318.png)

Recently added messaging feature, download the app to check out full functionality.

