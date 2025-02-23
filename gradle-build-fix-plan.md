# Gradle Build Fix Plan

This plan describes the steps needed to resolve the “Invalid maximum heap size” error indicated by Gradle. The error message shows that extra JVM options (e.g. “-Xmx4096m -Dorg.gradle.daemon=true -Dorg.gradle.parallel=true -Dorg.gradle.configureondemand=true”) are being appended to the maximum heap size flag, which is invalid. Follow these steps carefully:

1. **Clear Extra Environment Variables**  
   • Check your system’s environment and/or your IDE’s launch configuration for a variable named `GRADLE_OPTS`.  
   • If it exists and includes extra flags (like `-Dorg.gradle.daemon=true ...`), remove those so that only a simple heap size value remains (or clear the variable entirely).  
   • On Windows you can run in the terminal:  
     ```
     set GRADLE_OPTS=
     ```
     This will clear any previously set extra options for the current session.

2. **Update android/gradle.properties**  
   • Open the file `android/gradle.properties`.  
   • Ensure that the JVM arguments are as minimal as possible. For example, change the relevant line to:  
     org.gradle.jvmargs=-Xmx1024M  
   • Do not include extra configuration flags (e.g. remove any “-Dorg.gradle.daemon=true …” that might be appended).

3. **Check the Gradle Wrapper Configuration**  
   • Open `android/gradle/wrapper/gradle-wrapper.properties` to verify you are using a recent and compatible Gradle version. (Typically no changes are needed unless you see extra flags there.)

4. **Clean and Rebuild**  
   • Run the following commands:
     - Clear the build cache:  
       ```
       flutter clean
       ```
     - Then get packages:  
       ```
       flutter pub get
       ```
     - Finally, run the app:
       ```
       flutter run --verbose
       ```

5. **Verify the Build Process**  
   • Monitor the terminal output. The error “Invalid maximum heap size…” should no longer appear.
   • If build issues persist, confirm that no user-specific or IDE-specific configuration is reintroducing the extra flags.

By following these steps, the application’s Gradle build settings are simplified and the invalid flags are removed, which should resolve the error and allow the app to build and launch responsively.
