# Team Info & Policies
- List each team member and their role in the project.

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
- List communication channels/tools with corresponding use/communication policies (check main course page for communication channels and policies.)
<ol>
<li>Discord</li>
- Use Policies
<li>In Person</li>
- Use Policies
</ol>

# Product Description
The Better Beer Crawlers app will use MST algorithms and GIS mapping data, which ensures users maximize both time and energy efficiency. 

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
<li>User Data</li>
- The app will store data such as user preferences and remember them when they use the app next
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
1. The user opens the Beer Crawlers App.
2. The user taps on "View Nearby Bars."
3. The app uses GPS to detect the user’s current location.
4. The app displays a list of bars within a user specified radius.
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
<ol>
<li>User opens the app</li>
<li>App requests location permission (if not already granted).</li>
<li>App retrieves user's current location via GPS.</li>
<li>User navigates to the "Find Nearby Bars" section.</li>
<li>App displays a list of nearby bars sorted by proximity.</li>
<li>User applies filters (ex. rating, price, type of bar).</li>
<li>User can select a bar to view more details (address, hours, directions).</li>
<li>User chooses to get directions or save the bar to favorites.</li>
<li>User can add bars on the list to a crawl</li>
</ol>

Extensions of Success: 
- App remembers bars that the user selected previously and will suggest them next time 

Exceptions:
- E1: Location services are off - User is prompted to enable them or manually enter their location.
- E2: No bars found - App suggests expanding the search radius or adjusting filters.
- E3: No internet connection - User is notified and prompted to reconnect before continuing.

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

Describe at least three non-functional requirements, e.g., related to scalability, usability, security and privacy, etc.

<ol>
<li>As the user base expands or more bars are added to the database, the app’s performance should remain stable.</li>
<li>The UI should be intuitive and user-friendly, with a minimal learning curve. The design should focus on simplicity, ensuring that users can easily navigate the app, find nearby bars, and view optimal routes. The app must also provide clear prompts and feedback, especially when the user is interacting with GIS maps and route optimization features.</li>
<li>The app will collect and store user data. Therefore, security measures must be in place to protect user information. Users should have the option to manage or delete their data.</li>
</ol>

# External Requirements
- The product must be robust against errors that can reasonably be expected to occur, such as invalid user input.

- The product must be installable by a user, or if the product is a web-based service, the server must have a public URL that others can use to access it. If the product is a stand-alone application, you are expected to provide a reasonable means for others to easily download, install, and run it.

- The software (all parts, including clients and servers) should be buildable from source by others. If your project is a web-based server, you will need to provide instructions for someone else setting up a new server. Your system should be well documented to enable new developers to make enhancements.

- The scope of the project must match the resources (number of team members) assigned.
  
Make sure that these requirements, if applicable to your product, are specialized to your project and included in your document—do not copy and paste these requirements verbatim. You may leave this as a separate section or fold its items into the other requirements sections.

# Team Process Description
## Software
- Django
  - Backend framework
  - Super easy and simple
  - Built in ORM
  - Great integration with PostgreSQL
- PostgreSQL
  - Database
  - Feature-rich
  - Full text search
  - Works great with Django
- Flutter
  - Cross-platform
  - Already has Google Maps integrations and example code
  - Well documented and supported

## Roles
- Define and justify each team member’s role: why does your team need this role filled, and why is a specific team member suited for this role?

Chastidy: 

Greg: Develelop the Django backend. The backend will be used for all of the pathfinding systems and tracking data. Has background using Django and building backends

Paul:

Tamara: Will work with Greg to ensure the app’s algorithms and real-time data functionalities are well-integrated and optimized for performance. Worked with Network X before. Has background algorhtms development and API integration.  

## Schedule
- Provide a schedule for each member (or sub-group) with at least four concrete milestones and deadlines for the semester.

Chastidy:
<ol>
<li></li>
<li></li>
<li></li>
<li></li>
</ol>

Greg:
<ol>
<li></li>
<li></li>
<li></li>
<li></li>
</ol>

Paul:
<ol>
<li></li>
<li></li>
<li></li>
<li></li>
</ol>

Tamara:
<ol>
<li></li>
<li></li>
<li></li>
<li></li>
</ol>

## Major Risks
- Specify and explain at least three major risks that could prevent you from completing your project.

<ol>
<li>Issues may come up when working with real-time location data, calculating optimal routes efficiently, or handling large geographical areas with multiple bar options.</li>
<li>If the app’s interface is too complex, users may find it difficult to navigate to use the key features, especially when selecting bars.</li>
<li></li>
</ol>

## External Feedback

- Describe at what point in your process external feedback (i.e., feedback from outside your project group, including the project manager) will be most useful and how you will get that feedback.

Export a PDF snapshot of your document named PorjectName-m2.pdf and submit it to Canvas by due date EOD (Check Calendar).

Export a PDF snapshot of your document named ProjectName-m2.pdf and submit it to Canvas by due date EOD (Check Calendar).
