# Barcode Scanner

The following text contains documentation for the Barcode Scanner application. The goal of this document is to provide an APK file for the user after all of the steps have been followed. 
   
## Build Environment

This application has been written using the Flutter framework, and as such requires a working Flutter installation in order to be build. To find out how to set up a  Flutter environment for building this application, please head over to [this](https://flutter.dev/docs/get-started/) page. 


## Specifications
This application has been tested and developed with Flutter 2. As such, this document assumes that the user has a valid Flutter 2 installation for the following steps.

## Pre-build phase

With a suitable enviroment in place, the next step is to fetch the required packages for this application. To do this, navigate to the project directory and run the following command in the terminal of your choice:


```
flutter pub get
```

This command will fetch and setup all of the packages needed for this program. The next step is to generate the required code files. In the project directory, run the following command in the terminal:

```
flutter pub run build_runner build --delete-conflicting-outputs
```

This command will generate all of the necessary code files required by the build process.


## Build phase

The final step is to generate APK files for distribution. This can be achieved by running the following command in the project directory in the terminal:

```
flutter build apk --release
```

The generated files can be found in {Project Directory}/build/


