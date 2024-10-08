# Team Info & Policies
## Members

**Chastidy Joanem**: Front-End Dev

**Gregory Shiner**: Back-End Dev

**Paul Jensen**: Front-End Dev

**Tamara Estrada**: Back-End Dev

## Artifacts

https://github.com/pwjensen/BetterBarCrawlApp

## Communication Channels

1. Discord
2. In person


# Product Description
The Better Beer Crawl App will use Shortest Spanning Euler's algorithm and GIS mapping data, which ensures users maximize both time and energy efficiency. 

This app will provide users with the availability to customize their bar crawl by selecting specific bars to visit, setting the number of stops, and adjusting the crawl radius. 

## Major Features
1. Route Optimization with MST Algorithm
     - The app will calculate the shortest route that visits all user-selected bars, ensuring efficient travel between locations.
3. Customizable Bar Crawl
    - Users can specify the number of bars to visit, select specific bars, or set a distance radius to explore. 
3. GIS Mapping and Directions
    - The app will integrate GIS technology to provide real-time mapping, directions, and an interactive map showing bar locations, user paths, and current location. 
4. User Data
    - The app will store data such as user preferences and remember them when they use the app next

## Stretch Goals

1. BeReal-Inspired Feature
    - Adding the use of cameras on devices to take pictures/videos with both front-facing and rear-facing cameras to capture specific moments of the bar crawl.
2. Social Media Feed
    - Inclusion of some sort of feed to see what friends have been up to.

# Use Cases

## Use Case 1: View Nearby Bars

Actors
- **User**: A person looking for nearby bars.

Triggers
- The user wants to quickly find a bar close to their current location.

Preconditions
- The user has location services enabled.
- The user has an account and is logged into the app.

Postconditions
- The app displays a list of bars within a specified radius.

Steps
1. The user opens the Bar Crawl App.
2. The user taps on "View Nearby Bars."
3. The app uses GPS to detect the user’s current location.
4. The app displays a list of bars within a 1-mile radius.
5. The user selects a bar to view more details or get directions.

Extensions of Success
- The user can adjust the radius to expand or reduce the search area.

Exceptions
- If no bars are found within the search radius, the app displays a message recommending the user increase the search area.


## Use Case 2:

Actors:
- User

Triggers:
-  User wants to find nearby bars and opens the app.

Preconditions:
- User has the app installed.
- User has location services enabled.
- Internet connection is available.

Postconditions:
- User is presented with a list of nearby bars based on their location and filters.
- User can view details and get directions to a selected bar.

Steps:
1. User opens the app
2. App requests location permission (if not already granted).
3. App retrieves user's current location via GPS.
4. User navigates to the "Find Nearby Bars" section.
5. App displays a list of nearby bars sorted by proximity.
6. User applies filters (ex. rating, price, type of bar).
7. User selects a bar to view more details (address, hours, directions).
8. User chooses to get directions or save the bar to favorites.

Extensions of Success: 
- User finds a bar they like and gets directions or saves it for later.
- User adjusts the search radius or filters and finds more suitable bars.

Exceptions:
- Location services are off - User is prompted to enable them or manually enter their location.
- No bars found - App suggests expanding the search radius or adjusting filters.
- No internet connection - User is notified and prompted to reconnect before continuing.

## Use Case 3:

Actors:
- User

Triggers:
- User wants to select multiple bars to visit to start a crawl

Preconditions:
- User has the app installed.
- User has location services enabled.
- Internet connection is available.

Postconditions:
- User has selected a set of bars to visit

Steps:
1. User opens the app
2. App requests location permission (if not already granted).
3. App retrieves user's current location via GPS.
4. User navigates to the "Find Nearby Bars" section.
5. App displays a list of nearby bars sorted by proximity.
6. User applies filters (ex. rating, price, type of bar).
7. User can select a bar to view more details (address, hours, directions).
8. User chooses to get directions or save the bar to favorites.
9. User can add bars on the list to a crawl

Extensions of Success: 
- App remembers bars that the user selected previously and will suggest them next time 

Exceptions:
- Location services are off - User is prompted to enable them or manually enter their location.
- No bars found - App suggests expanding the search radius or adjusting filters.
- No internet connection - User is notified and prompted to reconnect before continuing.

## Use Case 4:

Actors:
- ***User***: Bar crawl participant

Triggers:
- The user arrives at a bar and wants to check in.

Preconditions:
- The user is part of the bar crawl event, and the bar is in the itinerary.
- Location services are active.
- The app has internet connection to record check-ins.

Postconditions:
- The user successfully checks in at the bar, and their status is updated for people to see.

Steps:

1. The user arrives at a bar on the crawl and opens the app.
2. The app detects the user's location and identifies the bar.
3. The user clicks the "Check In" button.
4. The app confirms the check-in and updates the user's profile with the bar information.
5. Friends on the same crawl receive notifications that the user has checked in.

Extensions of Success: 
- The app suggests the next bar on the route and estimated time of arrival.

Exceptions:
- The GPS may fail to locate the bar, requiring the user to manually search and check in.
- The bar might be too crowded, leading the user to skip it and check in at another venue.

## Non-Functional Requirements

1. As the user base expands or more bars are added to the database, the app’s performance should remain stable.
2. The UI should be intuitive and user-friendly, with a minimal learning curve. The design should focus on simplicity, ensuring that users can easily navigate the app, find nearby bars, and view optimal routes. The app must also provide clear prompts and feedback, especially when the user is interacting with GIS maps and route optimization features.
3. The app will collect and store user data. Therefore, security measures must be in place to protect user information. Users should have the option to manage or delete their data.

## External Requirements

1. The product must be robust against errors that can reasonably be expected to occur, such as invalid user input, loss of GPS signal, or loss of internet connectivity.
2. The product must be installable by a user, natively or sideloaded on android, and sideloadable on iOS.
3. The software should be buildable from source by others. The system should be well documented to enable new developers to make enhancements.

# Team Process Description
## Software
**Django**
  - Backend framework
  - Super easy and simple
  - Built in ORM
  - Great integration with PostgreSQL

**PostgreSQL**
  - Database
  - Feature-rich
  - Full text search
  - Works great with Django

**Flutter**
  - Cross-platform
  - Already has Google Maps integrations and example code
  - GIS data is easy to get through Google's APIs
  - Most of the features needed for this project have been implemented in flutter in some way
  - Well documented and supported

## Roles
Chastidy(Front End Dev): 
- Will work with Paul on the front end. Have slight experience working on front end but none with flutter.

Greg(Back End Dev): 
- Develelop the Django backend. The backend will be used for all of the pathfinding systems and tracking data. Has background using Django and building backends

Paul(Front End Dev):
 - Interested in learning front end for the first time. Will likely use the app once it is finished, so already has a general idea about how it should look.

Tamara(Back End Dev): 
- Will work with Greg to ensure the app’s algorithms and real-time data functionalities are well-integrated and optimized for performance. Worked with Network X before. Has background algorhtms development and API integration.  

## Schedule

Front End:
1. App Login Page
2. App Home Page
3. Settings pages including different preferances for the app
4. Getting the app to run on a live device

Back End:
1. Database Design Setup
2. API integration and route optimization
3. Real-time Data Management and API testing
4. Security Testing

# Software Architecture

- Identify and describe the major software components and their functionality at a conceptual level.
- Specify the interfaces between components.
- Describe in detail what data your system stores, and how. If it uses a database, give the high level database schema. If not, describe how you are storing the data and its organization.
- If there are particular assumptions underpinning your chosen architecture, identify and describe them.
- For each of two decisions pertaining to your software architecture, identify and briefly describe an alternative. For each of the two alternatives, discuss its pros and cons compared to your choice.

# Software Design

- What packages, classes, or other units of abstraction form these components?
- What are the responsibilities of each of those parts of a component?

# Coding Guideline

For each programming language that you will use in the implementation of your project, provide a link to a pre-existing coding style guideline that the members of your project will follow. Do not try to make up your own guidelines. Briefly state why you chose those guidelines and how you plan to enforce them.

**Flutter**:

**Python**: 

# Major Risks

1. Issues may come up when working with real-time location data, calculating optimal routes efficiently, or handling large geographical areas with multiple bar options.
2. If the app’s interface is too complex, users may find it difficult to navigate to use the key features, especially when selecting bars.
3. Encouraging or gamifying bar hopping could lead to excessive alcohol consumption. The app might be held accountable if it doesn't promote responsible drinking or provide necessary warnings.

# External Feedback
The most impactful time to receive feedback is likely during the first iteration of the user interface. Getting constructive feedback on this aspect and making sure everything is clear to a user would be a major help in understanding what makes a good UI.
