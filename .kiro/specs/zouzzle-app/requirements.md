# Requirements Document

## Introduction

Zouzzle is a daily "Who Am I?" sports guessing game for University of Missouri football and basketball players. Inspired by Wordle, users are given a single mystery player per day and must identify the player by making successive guesses. After each guess, the app provides color-coded attribute comparison feedback — matching each guessed player's attributes against the mystery player — nudging the user toward the correct answer. The app is built in Flutter/Dart targeting iOS first (with Android to follow), uses locally bundled JSON player data for Phase 1, and applies University of Missouri's official gold (#F1B82D) and black (#000000) color palette throughout.

---

## Glossary

- **Zouzzle**: The name of the application.
- **App**: The Zouzzle Flutter/Dart mobile application.
- **Player**: A University of Missouri football or basketball athlete represented in the local JSON dataset.
- **Mystery Player**: The single Player designated as the answer for a given calendar day's puzzle.
- **Guess**: A Player name submitted by the User as a candidate answer for the current puzzle.
- **Attribute**: A single comparable data field associated with a Player (e.g., position, jersey number, years active).
- **Feedback Row**: A horizontal row of colored cells displayed after a Guess, one cell per Attribute, indicating how closely the Guess matches the Mystery Player.
- **Match State**: One of three possible values for each Attribute cell — Exact Match (green), Close Match (yellow), or No Match (gray).
- **Guess Limit**: The maximum number of Guesses a User may submit in a single puzzle session (6 guesses).
- **Sport**: Either "Basketball" or "Football" — the two supported sport categories in the App.
- **User**: A person playing Zouzzle on a mobile device.
- **Home Screen**: The initial screen of the App where the User selects a Sport.
- **Game Screen**: The screen where the User plays the active puzzle for a selected Sport.
- **Result Screen**: The screen shown when the User wins or loses a puzzle.
- **Autocomplete**: A dropdown suggestion list that filters available Player names as the User types a Guess.
- **Player Dataset**: A locally bundled JSON file containing all Player records for a given Sport.
- **Daily Seed**: A deterministic mechanism that selects the Mystery Player for a given calendar date and Sport, derived from the device's local calendar date and the Sport identifier so no backend is required.
- **Win State**: The game outcome when the User correctly identifies the Mystery Player within the Guess Limit.
- **Lose State**: The game outcome when the User exhausts all Guesses without identifying the Mystery Player.
- **Disclaimer**: A visible notice stating that Zouzzle is not affiliated with, endorsed by, or sponsored by the University of Missouri.
- **Completion State**: A locally persisted record containing the Sport identifier, the calendar date (YYYY-MM-DD), the outcome (win or lose), the Mystery Player's name, and the list of Guesses submitted during that session.

---

## Requirements

### Requirement 1: Sport Selection

**User Story:** As a User, I want to choose between Basketball and Football on the Home Screen, so that I can play the puzzle for the sport I'm interested in.

#### Acceptance Criteria

1. WHEN the App launches, THE App SHALL display the Home Screen as the first screen presented to the User.
2. THE Home Screen SHALL present exactly two selectable options: "Basketball" and "Football".
3. WHEN the User selects a Sport, THE App SHALL navigate to the Game Screen for that Sport.
4. THE Home Screen SHALL display the Disclaimer indicating that Zouzzle is not affiliated with the University of Missouri.
5. THE Home Screen SHALL display the application name "Zouzzle" in a font size no smaller than 32sp so it is visually dominant on the screen.
6. THE App SHALL apply the official University of Missouri gold (#F1B82D) and black (#000000) as the primary color palette on the Home Screen and Game Screen.
7. WHEN the User is on the Game Screen, THE Game Screen SHALL provide a navigation control allowing the User to return to the Home Screen.

---

### Requirement 2: Daily Mystery Player Selection

**User Story:** As a User, I want a new mystery player each day for each sport, so that the game feels fresh and I have a reason to return daily.

#### Acceptance Criteria

1. THE App SHALL designate exactly one Mystery Player per Sport per calendar day.
2. THE App SHALL derive the Mystery Player selection using a Daily Seed computed from the device's local calendar date and the Sport identifier, requiring no network connection.
3. WHEN two Users open the same Sport on the same device-local calendar date, THE App SHALL present the same Mystery Player to both Users.
4. WHEN the App launches and the device-local calendar date has changed since the User's last session, THE App SHALL select a new Mystery Player for each Sport.
5. THE App SHALL cycle through the Player Dataset in a fixed order so that no Mystery Player repeats within a cycle; WHEN all Players in the dataset have been used, THE App SHALL restart the cycle from the beginning of the dataset.

---

### Requirement 3: Player Dataset

**User Story:** As a developer, I want Player data bundled as a local JSON file, so that the app works without a backend during Phase 1.

#### Acceptance Criteria

1. WHEN the App launches, THE App SHALL load Player records from a locally bundled JSON file for each Sport.
2. THE Player Dataset SHALL contain at minimum the following Attributes per Player: full name, sport, position, jersey number, start year at the university, end year at the university, whether the Player went pro (boolean), and statistical tier (one of: "All-American", "Starter", "Role Player", "Walk-On"). Each Sport's dataset SHALL contain at minimum 20 valid Player records.
3. WHEN the Player Dataset JSON file is malformed or unreadable, THE App SHALL display a non-blocking error message on the Game Screen indicating data could not be loaded, SHALL allow the User to navigate to the Home Screen, and SHALL NOT crash.
4. THE App SHALL support separate Player Dataset files for Basketball and Football.
5. THE Player Dataset JSON format SHALL be accompanied by a co-bundled schema definition file so that the structure is documented and real player data can replace placeholder data without code changes.
6. WHEN a Player record in the dataset is missing one or more required Attributes, THE App SHALL skip that record and exclude it from gameplay without crashing.

---

### Requirement 4: Guess Input with Autocomplete

**User Story:** As a User, I want to type a player name and see matching suggestions, so that I can submit a valid guess without needing to know exact spelling.

#### Acceptance Criteria

1. THE Game Screen SHALL display a text input field where the User may type a Player name.
2. WHEN the User enters one or more characters in the input field, THE App SHALL display a filtered Autocomplete list of Player name suggestions from the current Sport's Player Dataset whose names contain the entered text as a case-insensitive substring.
3. WHEN the filtered Autocomplete list contains no matching suggestions, THE App SHALL hide the Autocomplete list.
4. WHEN the User selects a suggestion from the Autocomplete list, THE App SHALL populate the input field with the selected Player's full name and close the Autocomplete list.
5. THE App SHALL only allow submission of Player names that exist in the current Sport's Player Dataset.
6. IF the User attempts to submit a name not present in the Player Dataset, THEN THE App SHALL display an inline validation message, SHALL clear the input field, and SHALL NOT record the submission as a Guess.
7. THE App SHALL prevent the User from submitting the same Player name as a previous Guess in the current session.
8. IF the User attempts to submit a duplicate Guess, THEN THE App SHALL display an inline validation message, SHALL clear the input field, and SHALL NOT record the duplicate as a new Guess.
9. WHEN the User submits a valid Guess, THE App SHALL clear the input field and close the Autocomplete list.

---

### Requirement 5: Attribute Comparison and Feedback

**User Story:** As a User, I want to see color-coded feedback for each attribute after every guess, so that I can narrow down who the mystery player is.

#### Acceptance Criteria

1. WHEN the User submits a valid Guess, THE App SHALL display a Feedback Row for that Guess showing one cell per Attribute.
2. THE App SHALL compare the following Attributes between the guessed Player and the Mystery Player: position (categorical), jersey number (numeric), start year at the university (numeric), end year at the university (numeric), went pro (boolean), and statistical tier (categorical).
3. WHEN an Attribute value of the guessed Player exactly matches the corresponding Attribute value of the Mystery Player, THE App SHALL display that Attribute cell in green regardless of Attribute type.
4. WHEN a numeric Attribute value of the guessed Player is within the defined tolerance of the Mystery Player's value but is not an exact match — where tolerance is ±5 for jersey number and ±3 years for start year and end year — THE App SHALL display that Attribute cell in yellow.
5. WHEN a categorical or boolean Attribute value of the guessed Player does not exactly match the Mystery Player's value, THE App SHALL display that Attribute cell in gray.
6. WHEN a numeric Attribute value of the guessed Player is outside the defined tolerance of the Mystery Player's value, THE App SHALL display that Attribute cell in gray.
7. THE App SHALL display an arrow indicator on numeric Attribute cells displayed in yellow: the arrow SHALL point up when the Mystery Player's value is higher than the guessed Player's value, and SHALL point down when the Mystery Player's value is lower.
8. THE App SHALL display all previously submitted Feedback Rows on the Game Screen simultaneously so the User can review their full guess history.
9. THE App SHALL display a column header above the Feedback grid identifying each Attribute by name.

---

### Requirement 6: Guess Limit Enforcement

**User Story:** As a User, I want the game to have a fixed number of guesses, so that the puzzle has appropriate challenge and tension.

#### Acceptance Criteria

1. THE App SHALL allow the User a maximum of 6 Guesses per puzzle session.
2. WHEN a puzzle session begins, THE App SHALL initialize the remaining Guess count to 6.
3. WHILE a puzzle session is active, THE Game Screen SHALL display the remaining Guess count as a numeric value visible to the User at all times.
4. WHEN the User submits a valid Guess, THE App SHALL decrement the remaining Guess count by one.
5. WHEN the User has submitted 6 valid Guesses without identifying the Mystery Player, THE App SHALL transition to the Lose State.
6. WHEN the remaining Guess count is 0, THE App SHALL reject any further submission attempt without decrementing the count.

---

### Requirement 7: Win and Lose States

**User Story:** As a User, I want clear feedback when I win or lose the puzzle, so that I know the game has ended and feel appropriately rewarded or informed.

#### Acceptance Criteria

1. WHEN the User submits a Guess that exactly matches the Mystery Player's full name, THE App SHALL transition to the Win State.
2. WHEN the App transitions to the Win State, THE App SHALL display the Result Screen showing a success message that includes the text "You got it!", the Mystery Player's full name, and the number of Guesses used out of the Guess Limit (e.g., "3 / 6").
3. WHEN the App transitions to the Lose State, THE App SHALL display the Result Screen showing a failure message that includes the text "Better luck tomorrow" and the Mystery Player's full name revealed.
4. THE Result Screen SHALL display a message indicating when the next daily puzzle will be available, formatted as "New puzzle available tomorrow".
5. WHILE the User is in a Win State or Lose State for the current day's puzzle, THE App SHALL reject any Guess submission attempt for that Sport and that calendar date.
6. THE Result Screen SHALL provide a button labeled "Home" allowing the User to return to the Home Screen.

---

### Requirement 8: Completed Puzzle Persistence

**User Story:** As a User, I want the app to remember that I already played today's puzzle, so that I cannot replay the same puzzle for an unfair advantage.

#### Acceptance Criteria

1. WHEN the User completes a puzzle (Win State or Lose State), THE App SHALL persist the Completion State — including Sport identifier, calendar date (YYYY-MM-DD), outcome (win or lose), Mystery Player's full name, and list of Guesses — locally on the device using the platform's standard local storage mechanism.
2. WHEN the User opens the App on the same calendar date as a completed puzzle for a given Sport, THE App SHALL navigate directly to the Result Screen for that Sport, reconstructing the display from the persisted Completion State.
3. WHEN a new calendar date begins, THE App SHALL treat that date's puzzle as a new, unplayed session for all Sports.
4. WHEN the locally persisted Completion State data is corrupt or unreadable, THE App SHALL treat the current session as unplayed and SHALL NOT crash.

---

### Requirement 9: Branding and Legal Compliance

**User Story:** As a developer, I want the app to use University of Missouri colors without infringing on trademarks, so that the app looks official-adjacent while staying legally compliant.

#### Acceptance Criteria

1. THE App SHALL use the University of Missouri official gold color (#F1B82D) and black (#000000) as the primary palette on all screens.
2. THE App SHALL refer to the university as "University of Missouri" and SHALL NOT use the term "Mizzou" as a trademark or branding element in any visible UI text.
3. THE App SHALL NOT include any trademarked logos, mascot imagery, or officially licensed marks belonging to the University of Missouri or its athletic programs.
4. THE App SHALL display a visible Disclaimer on the Home Screen reading: "Zouzzle is not affiliated with, endorsed by, or sponsored by the University of Missouri or its athletic programs." This Disclaimer SHALL meet a minimum contrast ratio of 4.5:1 (WCAG AA) against its background color.
5. WHEN the Disclaimer text is rendered on the Home Screen, THE App SHALL ensure the text color and background color produce a contrast ratio of at least 4.5:1 as defined by WCAG 2.1 Success Criterion 1.4.3.
