# assignment_app

Overview:
The "Moveo Notes App" is a mobile note-taking application built with Flutter that integrates note creation, geolocation, image attachments, and a clean DB implementation. The app syncs user-authored notes with geolocation pins, allowing a seamless view both as a list and as markers on a map.



Bugs List:
- "Delete All Notes" Logic is Hidden:
    Although there is a function to delete all notes in the Isar DB,
     it is not exposed in the UI. Currently only accessible via
     code.
  
- Color Theme Inconsistencies:
    Not all UI elements use the centralized color constants from the constants file.
     Some colors are still hardcoded.
  
- Pin Marker Overlap on Map:
    When multiple notes are pinned to the same location, only one pin is visible. Ideally,
     a selection window should pop up to
     choose between overlapping pins.
  
- Form Validator Checks All Fields Together:
    The validator evaluates all form fields together rather than
     validating each field individually.
