# ClinometerApp

This is an iOS application that enables a user to measure tall objects like trees! It is based off of the concept of a clinometer which uses a a distance, and an angle to form a right angled triangle to the object one is measuring. Instead of using a tape measure and a protractor approach, we use the features of your iPhone to find the distance travelled, the angle to the top of the object, and code to do all of the calculations for you.

This was one of two design options that were created for this project with the intent of measuring tall objects.


The following is a dimensioned drawing of the iPhone X with the eyepiece attachment:
![image](https://user-images.githubusercontent.com/52092223/224412222-f5c7f16f-fb1f-47b0-9896-d9f73142dde2.png)


## How it works

The iOS application uses your iPhone's built-in pedometer, gyroscope, and an input field asking for your height to calculate the height of the tree you are measuring.

Each of the instructions below are on a different screen, with buttons for users to press to proceed to the next step:

1. Stand at the base of the tree you want to measure.
2. Walk 10 steps in a straight line away from the tree. Ensure that when you turn around, you can see the top of the tree, otherwise, keep walking. When you are done walking, press the button below!
3. Look straight in front of you, and bring the eyepiece very close to your eye so you can see through it. Tilt your phone as you tilt your neck back until the top of the tree is at the bottom of the eyepiece, then press the button below!
4. Input your height into the field below:
5. Your tree is ___ metres or ____ feet tall!

Below is the UX flow of the application:

![UX Flow of Clinometer](https://user-images.githubusercontent.com/52092223/224417679-731bb80d-d66b-43a2-9991-6e39db2fdb0e.png)

## Acknowledgements

The app was written in SwiftUI and created by Matthew Kee and Emily Louie with contributions from Keaton Lees and Gregory Schaper.
