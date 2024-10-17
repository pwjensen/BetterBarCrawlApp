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
  - Has implementations of OpenRouteService & Google Maps available for easy modification to the application's needs
  - GIS data is easy to get through Google's APIs
  - Most of the features needed for this project have been implemented in Flutter in some way
  - Well documented and supported

## Project Schedule

### Milestones
1. **Requirements and Design Completion (External)**
2. **Backend API Development (Internal)**
3. **Frontend (Flutter) MVP Development (Internal)**
4. **Database Schema Finalization (Internal)**
5. **API Integration (Frontend-Backend Integration)**
6. **Testing & QA**

### Tasks and Effort Estimate

---

### **1. Requirements and Design Completion**
- **Task 1.1: Requirements Gathering & Analysis**
  - **Effort Estimate**: 1 person-week
  - **Description**: Define the app’s features, scope, user stories, and requirements (functional and non-functional).
  - **Dependencies**: None

- **Task 1.2: UI/UX Design**
  - **Effort Estimate**: 1 person-week
  - **Description**: Design wireframes, user flows, and screens for the app (e.g., login, bar listing, map view, user profile).
  - **Dependencies**: Task 1.1 (Requirements Gathering)

**Milestone**: Requirements and Design Completion

---

### **2. Backend API Development (Django)**
- **Task 2.1: Project Setup**
  - **Effort Estimate**: 0.5 person-week
  - **Description**: Set up a Django project, configure PostgreSQL, and basic environment setup.
  - **Dependencies**: Task 1.1 (Requirements Gathering)

- **Task 2.2: Database Schema Design**
  - **Effort Estimate**: 1 person-week
  - **Description**: Define models for users, bars, bar crawls, check-ins, etc. This includes relationships between entities.
  - **Dependencies**: Task 1.1 (Requirements Gathering), Task 2.1 (Django Setup)

- **Task 2.3: Authentication & Authorization**
  - **Effort Estimate**: 1 person-week
  - **Description**: Implement user registration, login, and token-based authentication (e.g., JWT).
  - **Dependencies**: Task 2.1 (Project Setup), Task 2.2 (Schema Design)

- **Task 2.4: Core API Development (CRUD for Bars, Bar Crawls)**
  - **Effort Estimate**: 2 person-weeks
  - **Description**: Develop API endpoints for creating, reading, updating, and deleting bars, crawls, and user check-ins.
  - **Dependencies**: Task 2.2 (Database Schema Design), Task 2.3 (Authentication)

- **Task 2.5: Geolocation & Map Integration API**
  - **Effort Estimate**: 1 person-week
  - **Description**: Set up APIs for retrieving and displaying bars on a map based on user’s location.
  - **Dependencies**: Task 2.4 (Core API)

- **Task 2.6: Unit Tests (Backend)**
  - **Effort Estimate**: 1 person-week
  - **Description**: Write unit tests for all API endpoints and core logic.
  - **Dependencies**: Task 2.4 (Core API Development), Task 2.5 (Geolocation)

**Milestone**: Backend API Development Complete

---

### **3. Frontend (Flutter) MVP Development**
- **Task 3.1: Flutter Project Setup**
  - **Effort Estimate**: 0.5 person-week
  - **Description**: Create a Flutter project, configure dependencies, and set up basic navigation.
  - **Dependencies**: Task 1.2 (UI/UX Design)

- **Task 3.2: User Authentication Screens**
  - **Effort Estimate**: 1 person-week
  - **Description**: Create login, registration, and user onboarding screens.
  - **Dependencies**: Task 3.1 (Project Setup), Task 2.3 (Backend Authentication)

- **Task 3.3: Core Screens (Bar Listing, Crawl Creation, etc.)**
  - **Effort Estimate**: 2 person-weeks
  - **Description**: Implement core UI screens based on the wireframes (e.g., Bar list, individual bar details, create a crawl).
  - **Dependencies**: Task 3.1 (Project Setup), Task 2.4 (Core API Development)

- **Task 3.4: Geolocation & Map View**
  - **Effort Estimate**: 1 person-week
  - **Description**: Integrate Google Maps or OpenStreetMap to display bars nearby and allow users to choose bars for their crawl.
  - **Dependencies**: Task 3.1 (Project Setup), Task 2.5 (Backend Map API)

- **Task 3.5: Flutter Unit Testing**
  - **Effort Estimate**: 1 person-week
  - **Description**: Write unit tests for the UI components and API integration.
  - **Dependencies**: Task 3.2 (User Auth Screens), Task 3.3 (Core Screens)

**Milestone**: Frontend MVP Development Complete

---

### **4. API Integration**
- **Task 4.1: Integration of Backend with Frontend**
  - **Effort Estimate**: 1 person-week
  - **Description**: Connect the Flutter frontend to the Django backend via API calls (login, bar retrieval, crawl creation).
  - **Dependencies**: Task 2.4 (Core API Development), Task 3.3 (Core Screens)

- **Task 4.2: End-to-End Testing**
  - **Effort Estimate**: 1 person-week
  - **Description**: Perform integration testing across all components (login, bar display, crawl creation).
  - **Dependencies**: Task 4.1 (API Integration)

**Milestone**: Frontend-Backend Integration Complete

---

### **5. Testing and QA**
- **Task 5.1: Backend Load Testing**
  - **Effort Estimate**: 0.5 person-week
  - **Description**: Test the performance of the backend under heavy loads.
  - **Dependencies**: Task 2.6 (Backend Unit Testing)

- **Task 5.2: Frontend Usability Testing**
  - **Effort Estimate**: 1 person-week
  - **Description**: Perform usability testing with a group of users to ensure the UI is intuitive.
  - **Dependencies**: Task 3.5 (Frontend Unit Testing)

- **Task 5.3: Bug Fixing**
  - **Effort Estimate**: 1 person-week
  - **Description**: Resolve any issues uncovered during the end-to-end testing and user testing phases.
  - **Dependencies**: Task 5.2 (Usability Testing), Task 4.2 (End-to-End Testing)

**Milestone**: Testing and QA Complete

---

### **Dependencies Overview**
- **Backend API Development** must be complete before API Integration and Frontend-Backend testing can start.
- **Flutter Frontend MVP** must be complete before API Integration and testing.
- **End-to-End Testing** relies on both the frontend and backend components being integrated.
- **Geolocation & Map Integration** for both frontend and backend depends on the successful completion of the core API (for bar listings).

## Risk Assessment

### **Risk 1: Integration Issues Between Frontend and Backend**
- **Likelihood**: Medium
- **Impact**: High
- **Evidence**:
  - Based on previous experience, connecting a frontend (Flutter) with a backend (Django) through APIs often involves issues with authentication, handling complex data models, and inconsistent API behavior across different environments (development, production).
  - There is also a chance of mismatch between API responses and frontend expectations.
- **Steps to Reduce**:
  - Clearly define the API specifications (contracts) early in the process.
  - Implement mock services during frontend development before the backend is fully ready.
  - Ensure thorough communication between front-end and back-end developers.
- **Detection Plan**:
  - Regular integration testing using tools like Postman and Flutter’s HTTP testing libraries.
  - Writing automated API integration tests to detect discrepancies early.
- **Mitigation Plan**:
  - If significant integration issues occur, set up joint debugging sessions between frontend and backend teams to resolve the issues quickly.
  - Introduce intermediary fixes like temporary API stubs to keep the frontend progress moving while backend fixes are being applied.

---

### **Risk 2: Performance and Scalability Issues with the Backend**
- **Likelihood**: Medium
- **Impact**: High
- **Evidence**:
  - The app will rely heavily on real-time geolocation data and will have to handle potentially large numbers of simultaneous users during peak times (e.g., bar crawls at night).
  - Django, while capable of handling high loads, can experience bottlenecks when not optimized for scalability.
  - No stress testing or load testing has been performed yet.
- **Steps to Reduce**:
  - Plan for load testing early in the project.
  - Use Django's built-in optimizations (e.g., database indexing, query optimizations).
  - Use caching mechanisms for frequently accessed data (like bar locations).
  - Implement asynchronous tasks for non-blocking actions.
- **Detection Plan**:
  - Perform regular load testing as early as possible in development using tools like Apache JMeter.
  - Monitor database performance via PostgreSQL’s query logs and Django’s ORM debug tools.
- **Mitigation Plan**:
  - If performance issues arise, consider scaling the backend with additional servers or using a database cluster.
  - Use Redis or other caching systems for optimizing frequently accessed data.
  - Prioritize optimizations based on profiling the most resource-intensive parts of the system.

---

### **Risk 3: Delays in UI/UX Design and Iteration**
- **Likelihood**: Medium
- **Impact**: Medium
- **Evidence**:
  - Flutter requires well-defined UI/UX elements, and since the design phase is critical to the overall user experience, any delays or incomplete designs can cause bottlenecks in frontend development.
  - Delays in user testing feedback can also push back UI refinements.
- **Steps to Reduce**:
  - Involve the design team early and work in parallel on high-priority screens (login, bar listing, map view).
  - Use iterative design practices and gather user feedback early via prototypes or mockups.
  - Set clear deadlines and milestones for UI/UX approval.
- **Detection Plan**:
  - Schedule regular design reviews and feedback sessions to ensure the design is progressing.
  - Track design deliverables and how they align with the development timelines.
- **Mitigation Plan**:
  - If delays occur, the development team can proceed with placeholder UI elements while awaiting final designs.
  - Reduce scope on lower-priority screens to avoid blocking core functionality development.

---

### **Risk 4: Flutter Developer Inexperience (Team Skills)**
- **Likelihood**: Medium
- **Impact**: Medium to High
- **Evidence**:
  - The team includes developers with limited Flutter experience, which could slow down development and lead to suboptimal practices or technical debt in the long term.
  - Initial Flutter setup and implementation challenges are common when working with a new framework.
- **Steps to Reduce**:
  - Schedule time for learning and small prototypes early in the project to familiarize developers with Flutter's ecosystem.
  - Use Flutter documentation, tutorials, and online resources to improve knowledge.
  - Collaborate closely to ensure that the best practices are being followed.
- **Detection Plan**:
  - Monitor initial progress on simple Flutter tasks and adjust workload estimates if team members are struggling.
  - Perform regular code reviews to ensure adherence to Flutter best practices.
- **Mitigation Plan**:
  - If Flutter learning curve proves challenging, bring in more experienced Flutter consultants or developers to accelerate development.
  - Consider pairing developers with more experience in Dart/Flutter for faster ramp-up.

---

### **Risk 5: Data Privacy and Security Concerns**
- **Likelihood**: Low to Medium
- **Impact**: High
- **Evidence**:
  - The app will handle sensitive user data (location, login credentials, user profile information). Any security breaches or mishandling of data can have legal and reputational consequences.
  - Aspects such as secure storage, encryption, and GDPR compliance need to be addressed.
- **Steps to Reduce**:
  - Follow industry-standard practices for security, including HTTPS for all API requests, secure user authentication (e.g., OAuth or JWT), and encrypted storage.
  - Implement security-focused testing early in the project (e.g., pen testing, vulnerability scanning).
  - Research and comply with data privacy regulations (e.g., GDPR).
- **Detection Plan**:
  - Use security auditing tools (like OWASP ZAP) to scan for potential vulnerabilities regularly.
  - Conduct code reviews with a security focus.
- **Mitigation Plan**:
  - If a security issue arises, immediately release hotfixes and notify users about the issue transparently.
  - Conduct a full security audit and implement stronger measures (e.g., two-factor authentication, encryption enhancements).

---

### **Summary of Risks**

| Risk                              | Likelihood | Impact | Mitigation Steps |
|-----------------------------------|------------|--------|------------------|
| **Integration Issues (Frontend-Backend)** | Medium     | High   | Clear API specifications, mock services, integration testing |
| **Backend Performance/Scalability**       | Medium     | High   | Load testing, caching, query optimizations |
| **UI/UX Design Delays**                   | Medium     | Medium | Iterative design, clear milestones, proceed with placeholder UIs |
| **Flutter Inexperience**                  | Medium     | High   | Learning sessions, Flutter best practices, pair programming |
| **Data Privacy/Security Concerns**        | Low-Medium | High   | HTTPS, encrypted storage, regular security audits |

## Roles
**Chastidy(Front End Dev):** 
- Will work with Paul on the front end. Have slight experience working on front end but none with flutter.

**Greg(Back End Dev):**
- Develelop the Django backend. The backend will be used for all of the pathfinding systems and tracking data. Has background using Django and building backends

**Paul(Front End Dev):**
 - Interested in learning front end for the first time. Will likely use the app once it is finished, so already has a general idea about how it should look.

**Tamara(Back End Dev):**
- Will work with Greg to ensure the app’s algorithms and real-time data functionalities are well-integrated and optimized for performance. Worked with Network X before. Has background algorhtms development and API integration.  

# Software Architecture

- Identify and describe the major software components and their functionality at a conceptual level.
- Specify the interfaces between components.
- Describe in detail what data your system stores, and how. If it uses a database, give the high level database schema. If not, describe how you are storing the data and its organization.
- If there are particular assumptions underpinning your chosen architecture, identify and describe them.
- For each of two decisions pertaining to your software architecture, identify and briefly describe an alternative. For each of the two alternatives, discuss its pros and cons compared to your choice.

## Application Components
These are the functional components that make up the application.
- User Account
    - User logs in with a username and password, sends API req to dj-rest-auth, gets back an auth token
    - User can create account using username, email, and password, or with social media login via dj-rest-auth
    - User can logout
- Sessions
    - Sessions track most of the data being used throughout a crawl
    - Can be shared between multiple users
    - Sessions can be joined via the owner of the group sharing a QR code or link with others
    - The user that creates the group is the "owner"
- Searching
    - An owner can begin a search on the available bars near them
    - Front end will send an API request to backend to request a list of bars with a latitude, longitude, and radius and/or max bars
- Routing
    - The owner of a session can request for a list of bars to be routed by sending them to the API
    - The backend will associate the route to a session
    - All users will then make a request to the API for the route given their session

## Software Components
These are the components of the application that implement the application
- Database
    - User
        - user_id (PK)
        - username (CK)
        - password
        - social_media_accounts
        - current_session (FK)
    - Session
        - session_id (PK)
        - route (list of bar FKs)
        - current_bar (FK)
        - owner (user FK)
        - participants (list of user FKs)
    - Bar
        - bar_id (PK)
        - latitude
        - longitude
- REST API Backend
    - Requests come in from frontend end into REST API
    - On request, updates or fetches relevant information via ORM
    - ORM communicates with local Database
    - Some requests will result in an API call to an outside service, specifically for searching for bars, and calculating routes
        - These services will be interacted with via their own REST API
    - Once relevant information is retreived, or information in DB is updated, a response is returned back to the front end
- Frontend
    - User logs into their account on first screen
        - If user does not have an account, they can create one on this screen as well
    - Home Screen
        - User can start creating a new session/route
        - If a session/route already exists, they can view and edit it
    - Session Screen
        - Manage settings about session
        - Add/remove people from session
    - Route Screen
        - Can search for and add bars
        - Can edit route
        - Can view more detailed information about the route
    - Bar Details
        - When a user clicks a bar, they will see more detailed info about it
        - Hours
        - Ratings
        - Phone number
        - Address
        - Photos
        - Etc.

## Back End (API)
- Endpoint: /auth/login (POST)
    - Param: Username
    - Param: Email
    - Param: Password
    - Returns: Token
    - Authenticates a user's login and returns a token back. This token will be used to authorize all future requests
- Endpoint: /auth/registration (POST)
    - Param: Username
    - Param: Email
    - Param: Password
    - Returns: Nothing
    - Creats a new user in the database
- There are many more endpoints to be implemented for /auth endpoints
- See [dj-rest-auth docs](https://dj-rest-auth.readthedocs.io/en/latest/api_endpoints.html)
- Endpoint: /session (POST)
    - Param: Token
    - Returns: Nothing
    - Creates a new session and makes the user the owner
- Endpoint: /session (GET)
    - Param: Token
    - Returns: Session
    - Gets the session that the user is currently associated with
- Endpoint: /session (PUT)
    - Param: Token
    - Param: username
    - Returns: Nothing
    - Only the owner of a session can call this method. They can use this method to add other people to their session.
- Endpoint: /route (POST)
    - Param: Token
    - Param: Bars
    - Returns: Nothing (The actual route is fetched from the /session endpoint)
    - Only the owner of a session can call this method. Creates a new route for the user's session.
    - Calls to the ORS TSP routing API
- Endpoint: /route (GET)
    - Param: Token
    - Returns: Route
    - Fetches the current user's route (NOTE: This provides identical data as just the route field from GET /session)
- Endpoint: /search (GET)
    - Param: Longitude
    - Param: Latitude
    - Param: Radius
    - Param: Limit
    - Return: List of bars
    - Radius or Limit (or both) is required
    - Calls to ORS POI search to get a list of bars


## Alternatives
### Django vs. Flask
Our choice: Django
Alternative: Flask
Description: Flask is a simpler, more flexible tool for building websites with Python. It doesn't come with as many built-in features as Django does.

Pros of Flask compared to Django:
1. Easier to learn: flask has a smaller learning curve and is easier to get started with for simple projects.
2. Performance: Flask is a very small library, especially compared to Django, and is generally much more performant
3. Pragmatism: Flask is very pragmatic making it flexible to be used in many use cases. You can also pick other tools to complement it that work better for you.

Cons of Flask compared to Django:
1. Less features: Flask has far fewer features and builtin functions compared to Django. For example, Django has a full ORM, while Flask lacks one entirely.
2. Smaller ecosystem: Django has a larger community and more readily available third-party modules.
3. Pragmatism (again): While Flask is very flexible, Django provides many features builtin, such as an ORM, that would be very useful for our specific use case.

### Flutter vs. Kotlin
Our choice: Flutter 
Alternative: Kotlin 
Description: Kotlin is the preferred language for native Android development.

Pros of Kotlin compared to Flutter:
1. Better performance: can run smoother, especially for complex app designs.
2. Full Android features: easier to use all of Android's capabilities.
3. Smaller app size: native apps are generally smaller than cross-platform apps.

Cons of Kotlin compared to Flutter:
1. Not cross-platform: Does not support porting apps to other platforms such as iOS. Only supports Android
2. Slower development: making apps just for Android can be slower than using Flutter.
3. Learning curve: there might be a steeper learning curve compared to Flutter.


# Software Design

- What packages, classes, or other units of abstraction form these components?
- What are the responsibilities of each of those parts of a component?

## Backend
- Django
    - Backend framework
    - Normally used as a full MVC templating web framework
        - We will only be using the MVC components without actually serving web pages since we are building a mobile app
    - A view is a function that simply takes a request object, and returns a response object
        - Django handles calling the functions when a corresponding endpoint is hit, and sending the response back to the caller
    - Full ORM interacts with PostgreSQL
        - Data model classes are automatically migrated to the DB schema, ensuring parity between data models and DB schema
        - Provides methods for executing queries written in Python instead of raw SQL
- Django Rest Framework
    - Addon to Django
    - Used to create REST API endpoints as Django Views
    - Ensures requests and responses conform to a REST API definition
- PostgreSQL
    - SQL Relational database
    - Integrates really well into Django ORM
    - Very feature rich
- Open Route Service
    - Public FOSS API for searching and routing over Open Street Maps data
    - Will be used to search for bars
    - Solves traveling salesman for routing to bars

## Frontend
- Flutter
    - Cross platform
    - Mobile app development framework
    - Our app will be primarily targetting Android (iOS port in the future)
- Open Route Service
    - Used by frontend to render maps with route info


# Coding Guideline

**Dart**:
- Style Guide: [Effective Dart](https://dart.dev/effective-dart/style)
    - Creates a consistant, easy to read, formatting style that follows standard practices.
- Formatting: [Default Formatter](https://docs.flutter.dev/tools/formatting)
    - Formatter built into VSCode Dart plugin, follows the Effective Dart styling guide.

**Python**: 
- Style Guide: [Pep 8](https://peps.python.org/pep-0008/)
    - Industry Standard
- Formatting: [Black Formatter](https://black.readthedocs.io/en/stable/index.html)
    - Strict Formatter following the Pep 8 standard.

# Major Risks

1. Issues may come up when working with real-time location data, calculating optimal routes efficiently, or handling large geographical areas with multiple bar options.
2. If the app’s interface is too complex, users may find it difficult to navigate to use the key features, especially when selecting bars.
3. Encouraging or gamifying bar hopping could lead to excessive alcohol consumption. The app might be held accountable if it doesn't promote responsible drinking or provide necessary warnings.
4. The data from Open Street Maps seems like it may be somewhat limited. This may mean that there is out of date or missing information about bars.

# Documentation Plan

## 1. User Guide

### Purpose
To provide end-users with comprehensive instructions on how to use the Better Beer Crawl App.

### Contents
- App installation guide
- Account creation and login process
- How to search for bars and create a bar crawl
- Using the route optimization feature
- Customizing bar crawl preferences
- Checking in at bars
- Troubleshooting common issues

## 2. Administrator Guide

### Purpose
To assist system administrators in managing and maintaining the Better Beer Crawl App.

### Contents
- System requirements and setup
- Database management
- User account management
- Performance monitoring and optimization
- Security protocols and best practices

## 3. Developer Guide

### Purpose
To provide developers with the necessary information to understand, maintain, and extend the Better Beer Crawl App.

### Contents
- System architecture overview
- Code structure and organization
- API documentation
- Database schema
- Third-party integrations (e.g., GIS mapping, ORS API)
- Testing procedures

## 4. In-App Help

### Purpose
To provide context-sensitive help and guidance within the app itself.

### Contents
- Feature explanations
- Tool tips
- FAQ section

## 5. README File

### Purpose
To provide a quick overview of the project for anyone accessing the repository.

### Contents
- Project description
- Installation instructions
- Basic usage guide
- Contributing guidelines

## Development and Maintenance Plan

1. Assign documentation tasks to team members based on their expertise.
2. Develop documentation concurrently with feature development.
3. Review and update documentation before each release.
4. Establish a process for users to provide feedback on documentation.

# External Feedback
The most impactful time to receive feedback is likely during the first iteration of the user interface. Getting constructive feedback on this aspect and making sure everything is clear to a user would be a major help in understanding what makes a good UI.
