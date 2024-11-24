# Better Bar Crawl App
This application allows users to discover and plan their bar crawl adventures, explore local bars, view details, and share their experiences with friends. Built with Flutter for a seamless mobile experience and Django for a robust backend, this app is designed to enhance your nightlife.

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
### Setup environment
This project provides an example .env file called `.env.example`.

Rename .env.example to .env:
```bash
mv .env.example .env
```

This `.env` file has example entries for all of the available options that can be set.
1. `ORS_API_KEY`: This is the API key used for Open Route Services. Register for one [here](https://openrouteservice.org/dev/#/signup)
2. `GOOGLE_MAPS_API_KEY`: This is the API key used for Google maps calls. Get an API key [here](https://mapsplatform.google.com/)
3. `DJANGO_SECRET_KEY`: Generate a new secret key for Django signing by running 
  ```bash
  cd src/backend
  poetry run python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
  ```
4. `DEBUG`: This tells the Django dev server to run in debug mode if set to true. This will provide much more detailed information in response bodies for errored requests. Set to false for use in production as this may leak potentially sensitive information.
5. `DB_NAME`: Name of the database to use. This can be removed and it will default to `postgres`, which should work with the default installation of PostgreSQL.
6. `DB_USER`: Username for the database connection to use. This can be removed and it will default to `postgres`, but this probably will NOT work with the default installation of PostgreSQL. You will likely need to update this with the user you want the connection to use. PosgreSQL will by default set the first user role name to the name of the user that installed PostgreSQL. You can check this with `psql postgres -c "\du;"` and setting this value to the `Role Name`.
7. `DB_PASS`: Password of the PostgreSQL user. This will default to `postgres` when left out of the `.env` file. PostgreSQL will set this as the default password for new users, so if you are using a fresh install of PostgreSQL, this can be left out of the `.env` file.
8. `DB_HOST`: Hostname of the PostgreSQL server for Django to connect to. If the database is running locally to Django, this can be removed from the `.env` file, and it will default to `127.0.0.1`
9. `DB_PORT`: Port of the PostgreSQL server for Django to connect to. The default port for PostgreSQL is 5432, so you can also remove this from the `.env` file, and the port will be set to 5432. Only change this value if your database is running on a different port.

Note that these values are just being read into the process' environment, so you can also set the environment variables however you normally like to set them as well.

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd src/backend
   ```

2. Install Python dependancies
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

## Using the App
### Starting Database
#### Linux
```bash
sudo systemctl start postgres
```

#### MacOS (Homebrew)
```bash
brew services start postgres
```

### Starting Server
To run the server on 127.0.0.1:8000, the default, run
```bash
poetry run python manage.py runserver
```

However, this may not allow your emulator/device to connect to it depending on your network setup. To allow networked connections, add an address to this command.
```bash
poetry run python manage.py runserver 0.0.0.0:8000
```
This will have the server listen on all available addresses on port 8000. You may want to change this to a different address depending on your networking needs.

### Running the App
Device Setup

1. Navigate to frontend
```bash
cd frontend
```
2. Running on phone connected via USB
```bash
# Gets a list of devices connected to PC
flutter devices
# Find your device and replace deviceId
flutter run -d <deviceId>
```
2. Running on Emulator
```bash
# Create Emulator
flutter flutter emulators --create [--name xyz]
# Run Emulator
flutter flutter emulators --launch <emulator id>
# Run App on Emulator
flutter run
```

## Operational Use Cases

### Backend

####  1. User Authentication 
- **User Registration**
  - Create a new account with a username, email, and password
  - Validation of user credentials

- **User Login/Logout**
  - Secure login with BasicAuthentication
  - Token-based authentication (Knox)
  - Delete user account
    
#### 2. Location Search (Partially Operational) 
- **Basic Location Search**
  - Search bars by address
  - Get coordinates for locations
- **Route Planning** (Basic Implementation)
  - Calculate routes between two points
  - Distance and duration calculations

### Frontend

#### 1. User Authentication
- **User Registration**
  - Create a new account with a username, email, first and last name, and password
  - Validation of user credentials
  - Automatic Login with registration

- **User Login/Logout**
  - Login using username and password
  - Logout deletes authentication token

#### 2. Bar Search
- **Search Parameters**
   - Radius
   - Type
- **Results**
   - List of locations provided with ratings and distance
   - Sortable by Distance, Rating, Name, and Most Reviewed

## In Development Use Cases

### Backend

#### 1. Bar Search
- Search bars by address
- Get coordinates for locations
- Display nearby bars
  
#### 2. Route Optimization
- Calculate routes between points
- Distance and duration calculations
- Multi-Stop Planning
    - Optimal route calculation
    - Time-based optimization
    - Multiple bar visits

### Frontend

#### 1. Bar Crawl Creation
- Allow for selection of locations to start route planning
- Invitations for others to join the crawl and share route
#### 2. Map Route Display
- Display directions/current location on map within app
- Display the locations of the selected bars

## Future Features
- **Reviews & Ratings**: Share your experiences and read others' reviews.
- **Social Sharing**: Invite friends and share your planned crawls through social media.

## Technologies Used

- **Frontend**: Flutter
- **Backend**: Django REST Framework
- **Database**: PostgreSQL
- **Authentication**: Django authentication with JWT (JSON Web Tokens)
- **APIs**: Open Route Services for POI searching and route solving

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
