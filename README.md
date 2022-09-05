# in_stock_tracker

# View this application on the web!
- [It may take a bit to load because of Flutter](https://husamsaleem.github.io/in-stock-flutterweb/#)
- *Also, if it is taking a while to ```register/login/other```, it is because of ```Heroku```. Heroku sleeps applications (my server) that haven't been active for a while. So if this happens, just wait patiently until my server boots up again.*

# Server Repo
- [View the documented server api repo](https://github.com/HusamSaleem/In-stock-tracker-server-new)

# Why?
- I created this because of the global shortages that is happening
- If I really want to buy an item (Specifically some tech products), they are usually not always in stock or the price is way too high, so this will help people not have to keep checking up on a item that they want because of availability or price issues. 

# Description
- Provides notifications of items that the user puts in their watchlist
- The watchlist consists of items that the user wants to know whether or not the item is in stock, and for what price
- The user will get notified by the server via email.

# Technologies used
- Flutter, [Spring Boot for api](https://github.com/HusamSaleem/In-stock-tracker-server-new), Postgresql, Heroku for hosting

# Features
- Notifications via email (Every 5 minutes)
- User Authentication (You can log in anywhere!)
- Clean dark themed UI (I think its nice :))
- Simple to use
- Put any item from the supported websites on your watchlist!
- Created in Flutter so it can be easily used on any platform

# Websites Supported
- Amazon

# My Personal TODO List
- Implement more websites like BestBuy, Newegg
- Phone notifications or maybe push notifications
- Update the UI (This will always be in the TODO lol)

# Getting Started

# Prerequisites
- Download [Flutter](https://docs.flutter.dev/get-started/install)
- [Android Studio](https://developer.android.com/studio) *recommended* or you can use VsCode

# Steps (Create your own version and run on any platform!)
- Clone this repo
- To build for Android, here is a better [tutorial](https://docs.flutter.dev/deployment/android) than I can ever make here
- To build for Web, just type in the terminal ```flutter build web```
