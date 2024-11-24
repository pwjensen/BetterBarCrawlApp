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

### Prerequisites

- Flutter SDK
- Java JDK 17
- Python 3.x
- Django
- PostgreSQL
- Git

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

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd src/backend
   ```

2. Create a virtual environment and activate it:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows use `venv\Scripts\activate`
   ```

3. Install required packages:
   ```bash
   pip install -r requirements.txt
   ```

4. Configure your database settings in `settings.py`.

5. Run migrations:
   ```bash
   python manage.py migrate
   ```

6. Create a superuser to access the admin panel:
   ```bash
   python manage.py createsuperuser
   ```

7. Start the Django server:
   ```bash
   python manage.py runserver
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

## Current Usage

1. **Sign Up**: Create an account and log in.
2. **Explore Bars**: Browse through the list of nearby bars or search for specific ones.


## Future Implementations

3. **Plan a Crawl**: Select bars and create a customized crawl.
4. **Review & Share**: Leave reviews and share your crawls with friends.

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
