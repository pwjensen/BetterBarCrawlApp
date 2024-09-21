# Team Info & Policies

Chastidy
- Front End Developer
  
Greg
- Back End Developer
  
Paul
- Front End Developer
  
Tamara
- Back End Developer

## Artifacts
- Link to each project relevant artifact such as your git repo (this can be empty for now).
<ol>
<li>https://github.com/pwjensen/BetterBarCrawlApp</li>
</ol>

## Communication Channels
<ol>
<li>Discord</li>
<li>In Person</li>
</ol>

# Product Description
The Better Beer Crawl App will use Shortest Spanning Euler's algorithm and GIS mapping data, which ensures users maximize both time and energy efficiency. 

This app will provide users with the availability to customize their bar crawl by selecting specific bars to visit, setting the number of stops, and adjusting the crawl radius. 

## Major Features
<ol>
<li>Route Optimization with MST Algorithm</li>
- The app will calculate the shortest route that visits all user-selected bars, ensuring efficient travel between locations.
<li>Customizable Bar Crawl</li>
- Users can specify the number of bars to visit, select specific bars, or set a distance radius to explore. 
<li>GIS Mapping and Directions</li>
- The app will integrate GIS technology to provide real-time mapping, directions, and an interactive map showing bar locations, user paths, and current location. 
<li></li>
</ol>

## Stretch Goals
<ol>
<li>BeReal-Inspired Feature</li>
- Adding the use of cameras on devices to take pictures/videos with both front-facing and rear-facing cameras to capture specific moments of the bar crawl.
<li></li>
</ol>

# Use Cases

# Use Case 1: View Nearby Bars

Actors
- **User**: A person looking for nearby bars.

Triggers
- The user wants to quickly find a bar close to their current location.

Preconditions
- The user has location services enabled.

Postconditions
- The app displays a list of bars within a specified radius.

Steps
<ol>
<li>The user opens the Beer Crawlers App.</li>
<li>The user taps on "View Nearby Bars."</li>
<li>The app uses GPS to detect the user’s current location.</li>
<li>The app displays a list of bars within a 1-mile radius.</li>
<li>The user selects a bar to view more details or get directions.</li>
</ol>

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
<ol>
<li>User opens the app</li>
<li>App requests location permission (if not already granted).</li>
<li>App retrieves user's current location via GPS.</li>
<li>User navigates to the "Find Nearby Bars" section.</li>
<li>App displays a list of nearby bars sorted by proximity.</li>
<li>User applies filters (ex. rating, price, type of bar).</li>
<li>User selects a bar to view more details (address, hours, directions).</li>
<li>User chooses to get directions or save the bar to favorites.</li>
</ol>

Extensions of Success: 
- User finds a bar they like and gets directions or saves it for later.
- User adjusts the search radius or filters and finds more suitable bars.

Exceptions:
- E1: Location services are off - User is prompted to enable them or manually enter their location.
- E2: No bars found - App suggests expanding the search radius or adjusting filters.
- E3: No internet connection - User is notified and prompted to reconnect before continuing.

## Use Case 3:

Actors:
- a

Triggers:
-  a

Preconditions:
- a

Postconditions:
- a

Steps:
<ol>
<li>Something</li>
</ol>

Extensions of Success: 
- a

Exceptions:
- a

## Use Case 4:

Actors:
- a

Triggers:
-  a

Preconditions:
- a

Postconditions:
- a

Steps:
<ol>
<li>Something</li>
</ol>

Extensions of Success: 
- a

Exceptions:
- a

# Non-Functional Requirements

<ol>
<li>As the user base expands or more bars are added to the database, the app’s performance should remain stable.</li>
<li>The UI should be intuitive and user-friendly, with a minimal learning curve. The design should focus on simplicity, ensuring that users can easily navigate the app, find nearby bars, and view optimal routes. The app must also provide clear prompts and feedback, especially when the user is interacting with GIS maps and route optimization features.</li>
<li>The app will collect and store user data. Therefore, security measures must be in place to protect user information. Users should have the option to manage or delete their data.</li>
</ol>

# External Requirements
<ol>
<li>The product must be robust against errors that can reasonably be expected to occur, such as invalid user input, loss of GPS signal, or loss of internet connectivity.</li>

<li>The product must be installable by a user, natively or sideloaded on android, and sideloadable on iOS.</li>

<li>The software should be buildable from source by others. The system should be well documented to enable new developers to make enhancements.</li>
</ol>

# Team Process Description
## Software
- Specify and justify the software toolset you will use.

Django
- Easy to implement

Flutter
- Cross platform app development
- GIS data is easy to get through Google's APIs
- Most of the features needed for this project have been implemented in flutter in some way

SQL THING
- 
## Roles
- Define and justify each team member’s role: why does your team need this role filled, and why is a specific team member suited for this role?

Chastidy: 

Greg: 

Paul:
 - Interested in learning front end for the first time. Will likely use the app once it is finished, so already has a general idea about how it should look.

Tamara: 
- Will work with Greg to ensure the app’s algorithms and real-time data functionalities are well-integrated and optimized for performance. Worked with Network X before. Has background algorhtms development and API integration.  

## Schedule
- Provide a schedule for each member (or sub-group) with at least four concrete milestones and deadlines for the semester.

Front End:
<ol>
<li>App Login Page</li>
<li>App Home Page</li>
<li>Settings pages including different preferances for the app</li>
<li></li>
</ol>

Back End:
<ol>
<li>Database Design Setup</li>
<li>API integration and route optimization</li>
<li>Real-time Data Management and API testing</li>
<li>Security Testing</li>
</ol>

## Major Risks
- Specify and explain at least three major risks that could prevent you from completing your project.

<ol>
<li>Issues may come up when working with real-time location data, calculating optimal routes efficiently, or handling large geographical areas with multiple bar options.</li>
<li>If the app’s interface is too complex, users may find it difficult to navigate to use the key features, especially when selecting bars.</li>
<li>Encouraging or gamifying bar hopping could lead to excessive alcohol consumption. The app might be held accountable if it doesn't promote responsible drinking or provide necessary warnings.</li>
</ol>

## External Feedback

- Describe at what point in your process external feedback (i.e., feedback from outside your project group, including the project manager) will be most useful and how you will get that feedback.
