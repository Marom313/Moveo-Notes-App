# assignment_app

Overview:
The "Moveo Notes App" is a mobile note-taking application built with Flutter that integrates note creation, geolocation, image attachments, and a clean DB implementation. The app syncs user-authored notes with geolocation pins, allowing a seamless view both as a list and as markers on a map.


Tech Implementation:
    - Authentication:
        Firebase-based sign-up/login
        with validation for email,
        password, and name.
    - Notes Management:
        Create, edit, and delete notes.
        Each note includes:
            - Title
            - Body
            - Date
            - Geolocation (automatically assigned)
            - Optional image from camera or gallery
    - Image Picker Integration:
        Added ability to attach an image to a note using
        image_picker, stored locally.
        Handles permission requests 
        (camera, storage/photos) using permission_handler.
    - Persistent Storage:
        Notes are saved using the Isar database.
        Each user sees only their own notes.
    - MVVM Architecture:
        NoteViewModel,
        AuthViewModel,
        MainViewModel handle business logic.
        note_model.g.dart auto-generated by isar_generator.
    - UI Layers:
        MainScreen toggles between Notes and Map views.
        Notes list is built with GridView,
        showing title,
        body preview,
        and opening the note on tap.
        MapView shows notes as map pins using flutter_map.


Good Practices Followed:
    - Clear MVVM separation between UI and logic
    - Use of Provider for state management
    - Lazy loading with watchAllNotes() stream from Isar
    - Local persistence of images to reduce API/storage complexity
    
 Alternatives Considered:
    - Considered using Firebase Firestore for note syncing, but chose Isar for local-first speed and offline use.
    - Considered using google_maps_flutter, but flutter_map was chosen due to better marker clustering and OpenStreetMap flexibility.
    

Bugs List:
- "Delete All Notes" Logic is Hidden:
    There is a function to delete all notes in the Isar DB,
     it is not exposed in the UI. Currently only accessible via
     code.
  
- Color Theme Inconsistencies:
    Not all UI elements use the  color constants from the constants file.
     Some colors are still hardcoded.
  
- Pin Marker Overlap on Map:
    When multiple notes are pinned to the same location, only one pin is visible. Ideally,
     a selection window should pop up to
     choose between overlapping pins.
  
- Form Validator Checks All Fields Together:
    The validator evaluates all form fields together rather than
     validating each field individually.


