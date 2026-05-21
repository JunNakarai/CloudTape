# Demo Mode Plan

## Current Status

CloudTape now includes a minimal in-app demo path for future reviews:

- The empty library screen shows a `Try Sample Audio` button.
- The button plays `CloudTape-Demo-Audio.m4a` from the app bundle.
- The normal folder picker, iCloud Drive flow, library scan, and user playback behavior are unchanged.

This keeps App Review unblocked even if reviewers do not immediately save the external demo file into Files/iCloud Drive.

## Future Improvements

- Add a short App Review note in the submission metadata mentioning `Try Sample Audio`.
- Consider showing the sample button only when no folder has been selected.
- Add a lightweight UI test that launches the app with no saved folder and verifies the sample button exists.
- If CloudTape later supports onboarding, place the sample action there as a secondary action.
