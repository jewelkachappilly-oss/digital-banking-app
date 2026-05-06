# Digital Banking App - Flutter + Django

Premium mobile banking demo UI matching the provided reference style.

## Included screens
- Splash screen
- Login screen
- Home dashboard with red balance card
- Quick actions
- Top services grid
- Quick transfer beneficiaries
- Send money with OTP + UPI PIN
- Transactions with money in/out/service payments
- Airtime & Data purchase
- Pay Bills
- Profile page
- Bottom navigation

## Demo login
- UPI ID: `jewelkj5112@bank`
- Password: `12345678`
- UPI PIN: `1234`

Beneficiary UPI IDs:
- `shubhamrai@upi`
- `olumide@upi`
- `dadaolu@upi`
- `anumary@upi`

## Run backend first
```bash
cd backend_django
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python manage.py makemigrations
python manage.py migrate
python manage.py runserver 0.0.0.0:8000
```

## Run Flutter on emulator
Open another terminal:
```bash
cd frontend_flutter
flutter clean
flutter pub get
flutter run -d emulator-5554
```

The app uses `http://10.0.2.2:8000` for Android emulator.
For a real phone, run with your PC IP:
```bash
flutter run -d <device-id> --dart-define=API_BASE_URL=http://YOUR_PC_IP:8000
```
