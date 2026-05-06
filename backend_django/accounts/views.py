import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.db.models import Q
from .models import User


def get_data(request):
    try:
        return json.loads(request.body.decode('utf-8') or '{}')
    except Exception:
        return request.POST


def ensure_demo_users():
    """Creates demo users so the Flutter app works immediately after migrate."""
    demo = [
        ('jewel kj', 'jewel@example.com', 'jewelkj5112@bank', '12345678', '1234', 50000),
        ('Shubham Rai', 'shubham@example.com', 'shubhamrai@upi', '12345678', '1234', 30000),
        ('Olumide A.', 'olumide@example.com', 'olumide@upi', '12345678', '1234', 28000),
        ('Dada Olu', 'dada@example.com', 'dadaolu@upi', '12345678', '1234', 35000),
        ('Anu Mary', 'anu@example.com', 'anumary@upi', '12345678', '1234', 25000),
        ('Electricity Board', 'electricity@example.com', 'electricity@bill', '12345678', '1234', 0),
        ('Water Board', 'water@example.com', 'water@bill', '12345678', '1234', 0),
        ('Internet Bill', 'internet@example.com', 'internet@bill', '12345678', '1234', 0),
        ('TV Subscription', 'tv@example.com', 'tv@bill', '12345678', '1234', 0),
        ('Education Fees', 'education@example.com', 'education@bill', '12345678', '1234', 0),
        ('Airtime Service', 'airtime@example.com', 'airtime@service', '12345678', '1234', 0),
    ]
    for name, email, upi, password, pin, balance in demo:
        user, created = User.objects.get_or_create(email=email, defaults={'name': name, 'upi_id': upi, 'balance': balance})
        changed = False
        if user.upi_id != upi:
            user.upi_id = upi; changed = True
        if created or not user.password.startswith('pbkdf2_'):
            user.set_password(password); changed = True
        if created or not user.upi_pin.startswith('pbkdf2_'):
            user.set_pin(pin); changed = True
        if changed:
            user.save()


def user_json(user: User):
    return {
        'user_id': user.id,
        'name': user.name,
        'email': user.email,
        'upi': user.upi_id,
        'balance': float(user.balance),
    }


@csrf_exempt
def register(request):
    ensure_demo_users()
    if request.method != 'POST':
        return JsonResponse({'error': 'POST only'}, status=405)
    data = get_data(request)
    name = (data.get('name') or '').strip()
    email = (data.get('email') or '').strip().lower()
    password = data.get('password') or ''
    pin = str(data.get('pin') or '1234')

    if not name or not email or not password:
        return JsonResponse({'error': 'Name, email and password are required'}, status=400)
    if User.objects.filter(email=email).exists():
        return JsonResponse({'error': 'Email already exists. Use Login instead.'}, status=400)

    user = User(name=name, email=email)
    user.set_password(password)
    user.set_pin(pin)
    user.save()
    return JsonResponse(user_json(user), status=201)


@csrf_exempt
def login(request):
    ensure_demo_users()
    if request.method != 'POST':
        return JsonResponse({'error': 'POST only'}, status=405)
    data = get_data(request)
    identifier = (data.get('identifier') or data.get('email') or '').strip().lower()
    password = data.get('password') or ''
    try:
        user = User.objects.get(Q(email=identifier) | Q(upi_id=identifier))
    except User.DoesNotExist:
        return JsonResponse({'error': 'Invalid UPI/email or password'}, status=401)
    if not user.check_password(password):
        return JsonResponse({'error': 'Invalid UPI/email or password'}, status=401)
    return JsonResponse(user_json(user))


def profile(request, user_id):
    ensure_demo_users()
    try:
        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        return JsonResponse({'error': 'User not found'}, status=404)
    return JsonResponse(user_json(user))
