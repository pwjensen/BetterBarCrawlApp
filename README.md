# Better Bar Crawl App

Welcome to the Better Bar Crawl App! This application allows users to discover and plan their bar crawl adventures, explore local bars, view details, and share their experiences with friends. Built with Flutter for a seamless mobile experience and Django for a robust backend, this app is designed to enhance your nightlife.

## Features

- **User Registration & Authentication**: Sign up and log in securely.
- **Bar Listings**: Browse local bars with detailed information including ratings, reviews, and images.
- **Crawl Planning**: Create and manage personalized bar crawls with ease.
- **Reviews & Ratings**: Share your experiences and read others' reviews.
- **Location Integration**: Utilize maps to find nearby bars and get directions.
- **Social Sharing**: Invite friends and share your planned crawls through social media.

## Technologies Used

- **Frontend**: Flutter
- **Backend**: Django REST Framework
- **Database**: PostgreSQL
- **Authentication**: Django authentication with JWT (JSON Web Tokens)
- **APIs**: Open Route Services for POI searching and route solving

## Installation

### Install dependancies

- [Git](https://git-scm.com/downloads)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Select Android as app type)
- [Android Studio](https://developer.android.com/studio/install)
- [Python 3.12^](https://www.python.org/downloads/)
- [Poetry](https://python-poetry.org/docs/#installation)
- [PostgreSQL](https://www.postgresql.org/download/)

### Clone the Repository

```bash
git clone https://github.com/pwjensen/BetterBarCrawlApp.git
cd BetterBarCrawlApp
```
### Create .env file for both frontend and backend
Rename the current .env.example file in each directory to .env and make changes based on your setup
```bash
mv src/frontend/.env.example .env
mv src/backend/.env.example .env
```

They should look like this:
```bash
ORS_API_KEY = 'your_api_key_here'
DJANGO_SECRET_KEY = 'your_django_key_here'
DEBUG = True
GOOGLE_MAPS_API_KEY = 'your_api_key_here'
```
### Database setup
This software uses the Django ORM which abstracts away the actual database connections and queries. This means it is actually quite simple to swap out postgres for a different database of your choice. Please note, at the time of writting, this software has only been tested on PostgreSQL, but should work out of the box with other databases like SQLite and MariaDB/MySQL. 

#### Setup role/user
TODO

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd src/backend
   ```

2. Install dependancies
   ```bash
   poetry install
   ```

### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd ../src/frontend
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Start Emulator\Connect Device using Dev Debug
   ```bash
   flutter emulators
   ```
   ```bash
   flutter devices
   ```
3. Run the Flutter app:
   ```bash
   flutter run -d {deviceID}
   ```


## Operational Use Cases
### 1. User Authentication 
- **User Registration**
  - Create a new account with a username, email, and password
  - Validation of user credentials

- **User Login/Logout**
  - Secure login with BasicAuthentication
  - Token-based authentication (Knox)
  - Delete user account
    
### 2. Location Search (Partially Operational) 
- **Basic Location Search**
  - Search bars by address
  - Get coordinates for locations
- **Route Planning** (Basic Implementation)
  - Calculate routes between two points
  - Distance and duration calculations
## Use Cases In Development

### 1. Bar Search
- Search bars by address
- Get coordinates for locations
- Display nearby bars
  
### 2. Route Optimization
- Calculate routes between points
- Distance and duration calculations
  
### 3. User Interface for Bar Selection
 The app detects and displays the user's current location on the map
- Users can input the search radius
- The app successfully retrieves and displays nearby bars within a specified radius
- Shows basic bar information including:
    - Bar name
    - Distance from current location
    - Star ratings
      
### 4.  Route Optimization
- Multi-Stop Planning
    - Optimal route calculation
    - Time-based optimization
    - Multiple bar visits

## Contributing

We welcome contributions! Please fork the repository and create a pull request with your proposed changes. Ensure that your code follows our coding standards and includes tests.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For any questions or feedback, feel free to reach out:

- [Paul Jensen](https://github.com/pwjensen)
- [Tamara Estrada](https://github.com/TamaraEstrada)
- [Chastidy Joanem](https://github.com/Chazdj0510)
- [Greg Shiner](https://github.com/GregShiner)
