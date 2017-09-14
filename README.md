![sk8spots_logo](https://user-images.githubusercontent.com/16570082/29876124-e6984376-8d69-11e7-9ba1-eea46375c1e1.png)
# SkateSpots-iOS
This repository contains a location based skateboard spot app, that lets skaters share skateboard spots around the world.

## Download

**Minimum Requirements**
* Xcode 8.3
* iOS 10.3 SDK
* macOS Sierra


Open your terminal and enter the command: `git clone https://github.com/mikezander/SkateSpots-iOS` to clone the project.

## Technical Features

* Firebase cloud hosted storage database
* Facebook API to authenticate users and extract profile information
* Cosmos framework for star ratings
* Retrieve location based off photo metadata
* Image caching & storage
* Nested tableviews

## App Description

 **Log in screen**
 
 Upon lauch the user is directed to the log in screen to enter their credentials to either sign up for an account or log in to an existing account. The user may also sign in using their facebook account.

![screen shot 2017-08-30 at 10 57 45 am](https://user-images.githubusercontent.com/16570082/29879098-20b99f34-8d72-11e7-8bba-de888f8ba4c2.png)

**Main Feed**

After successfully logging in the user gets directed to the main feed. The main feed consists of uploaded skate spots that the user can sort by either most recently uploaded or closest to their location. They can then further sort by different spot types (i.e. Skatepark, Ledges, Rails).
Each spot on the main feed includes photo/s, spot name, spot location, calcuated distance, driving direction, and the user who contributed the spot.

![screen shot 2017-08-30 at 11 34 10 am](https://user-images.githubusercontent.com/16570082/29881014-60581daa-8d77-11e7-9a92-906add2cb759.png)
![screen shot 2017-08-30 at 11 35 04 am](https://user-images.githubusercontent.com/16570082/29881041-751aa096-8d77-11e7-9978-3eb37398a672.png)

**Upload a spot**

In order to upload a spot, the user must capture photo/s at the spot and upload them by either using their camera or photo library.The user must then enter in required description fields for the spot and hit the add spot button to finish spot upload.

![screen shot 2017-08-30 at 11 51 22 am](https://user-images.githubusercontent.com/16570082/29881992-be52dc86-8d79-11e7-8c9a-4cffe9aeae5c.png)

![screen shot 2017-08-30 at 11 51 44 am](https://user-images.githubusercontent.com/16570082/29882085-06954a1a-8d7a-11e7-9e94-6af201a3dfc4.png)


**Map view**

The map view centers on the users location and users can then locate the spots(pins) on the map. Clicking on the spot pin opens a dialog window with the spot's basic information. The user can click on the dialog window to get redirected to the spot's detail page.

![screen shot 2017-08-30 at 12 26 37 pm](https://user-images.githubusercontent.com/16570082/29883530-a5c5ec12-8d7e-11e7-9d59-39b0177a6a10.png)

**Spot Detail**

![screen shot 2017-08-30 at 4 43 10 pm](https://user-images.githubusercontent.com/16570082/29894269-c0112df6-8da2-11e7-8e0d-eec256532515.png)
![screen shot 2017-08-30 at 4 40 45 pm](https://user-images.githubusercontent.com/16570082/29894306-e1a383ce-8da2-11e7-9561-11cd1b2902b0.png)
//////////////////////////////////////////////Moving bottom view//////
![screen shot 2017-08-30 at 4 41 30 pm](https://user-images.githubusercontent.com/16570082/29894319-ecef639c-8da2-11e7-8951-9f8a88548d02.png)

**Favorites**

![screen shot 2017-08-30 at 4 55 01 pm](https://user-images.githubusercontent.com/16570082/29894669-20c53074-8da4-11e7-855e-db2314175cdc.png)

**Profile**

![screen shot 2017-08-30 at 5 02 41 pm](https://user-images.githubusercontent.com/16570082/29895032-91a952a6-8da5-11e7-9971-75daff9421c3.png)

**Edit Profile**

![screen shot 2017-08-30 at 5 04 00 pm](https://user-images.githubusercontent.com/16570082/29895057-aad4a744-8da5-11e7-941c-07083d21c318.png)

