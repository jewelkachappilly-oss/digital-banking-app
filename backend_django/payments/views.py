import json
import random
from decimal import Decimal, InvalidOperation
from datetime import timedelta
from django.db import transaction
from django.http import JsonResponse
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt
from .models import Transaction, OTP
from accounts.models import User
from accounts.views import ensure_demo_users


def get_data(request):
    try:
        return json.loads(request.body.decode('utf-8') or '{}')
    except Exception:
        return request.POST


@csrf_exempt
def send_otp(request):
    ensure_demo_users()
    user_id = request.GET.get('user_id')
    if not user_id:
        return JsonResponse({'error': 'user_id required'}, status=400)
    try:
        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        return JsonResponse({'error': 'User not found'}, status=404)

    OTP.objects.filter(user=user, is_used=False).update(is_used=True)
    code = str(random.randint(100000, 999999))
    OTP.objects.create(user=user, code=code)
    print(f'DEV OTP for {user.email}: {code}')
    return JsonResponse({'message': 'OTP sent', 'dev_otp': code})


@csrf_exempt
def pay(request):
    ensure_demo_users()
    if request.method != 'POST':
        return JsonResponse({'error': 'POST only'}, status=405)
    data = get_data(request)
    sender_id = data.get('sender')
    upi = (data.get('upi') or '').strip().lower()
    pin = str(data.get('pin') or '')
    otp = str(data.get('otp') or '')
    remark = (data.get('remark') or 'UPI Payment').strip()[:120]

    try:
        amount = Decimal(str(data.get('amount')))
    except (InvalidOperation, TypeError):
        return JsonResponse({'error': 'Invalid amount'}, status=400)

    if amount <= 0:
        return JsonResponse({'error': 'Amount must be greater than zero'}, status=400)

    try:
        with transaction.atomic():
            sender = User.objects.select_for_update().get(id=sender_id)
            receiver = User.objects.select_for_update().get(upi_id=upi)
            if sender.id == receiver.id:
                return JsonResponse({'error': 'Cannot pay to your own UPI ID'}, status=400)
            if not sender.check_pin(pin):
                return JsonResponse({'error': 'Wrong UPI PIN'}, status=401)
            valid_after = timezone.now() - timedelta(minutes=10)
            otp_obj = OTP.objects.filter(user=sender, code=otp, is_used=False, created_at__gte=valid_after).order_by('-created_at').first()
            if not otp_obj:
                return JsonResponse({'error': 'Invalid or expired OTP'}, status=400)
            if sender.balance < amount:
                return JsonResponse({'error': 'Low balance'}, status=400)
            sender.balance -= amount
            receiver.balance += amount
            sender.save(update_fields=['balance'])
            receiver.save(update_fields=['balance'])
            otp_obj.is_used = True
            otp_obj.save(update_fields=['is_used'])
            tx = Transaction.objects.create(sender=sender, receiver=receiver, amount=amount, remark=remark)
    except User.DoesNotExist:
        return JsonResponse({'error': 'Receiver UPI not found. Try shubhamrai@upi, olumide@upi or dadaolu@upi'}, status=404)

    return JsonResponse({'message': 'Payment success', 'balance': float(sender.balance), 'transaction_id': tx.id})


@csrf_exempt
def service_pay(request):
    ensure_demo_users()
    if request.method != 'POST':
        return JsonResponse({'error': 'POST only'}, status=405)
    data = get_data(request)
    user_id = data.get('user_id')
    service = (data.get('service') or 'Bill Payment').strip()[:80]
    try:
        amount = Decimal(str(data.get('amount')))
    except (InvalidOperation, TypeError):
        return JsonResponse({'error': 'Invalid amount'}, status=400)
    if amount <= 0:
        return JsonResponse({'error': 'Amount must be greater than zero'}, status=400)

    service_map = {
        'Electricity': 'electricity@bill', 'Water': 'water@bill', 'Internet': 'internet@bill',
        'TV Subscription': 'tv@bill', 'Education': 'education@bill'
    }
    if service.startswith('Airtime') or service.startswith('Data'):
        receiver_upi = 'airtime@service'
    else:
        receiver_upi = service_map.get(service, 'electricity@bill')

    try:
        with transaction.atomic():
            user = User.objects.select_for_update().get(id=user_id)
            receiver = User.objects.select_for_update().get(upi_id=receiver_upi)
            if user.balance < amount:
                return JsonResponse({'error': 'Low balance'}, status=400)
            user.balance -= amount
            receiver.balance += amount
            user.save(update_fields=['balance'])
            receiver.save(update_fields=['balance'])
            tx = Transaction.objects.create(sender=user, receiver=receiver, amount=amount, remark=service)
    except User.DoesNotExist:
        return JsonResponse({'error': 'User/service not found'}, status=404)
    return JsonResponse({'message': 'Service payment success', 'balance': float(user.balance), 'transaction_id': tx.id})


def transactions(request, user_id):
    ensure_demo_users()
    qs = Transaction.objects.filter(sender_id=user_id) | Transaction.objects.filter(receiver_id=user_id)
    items = []
    for tx in qs.select_related('sender', 'receiver').order_by('-created_at')[:50]:
        is_sent = tx.sender_id == user_id
        is_service = tx.receiver.upi_id.endswith('@bill') or tx.receiver.upi_id.endswith('@service')
        items.append({
            'id': tx.id,
            'type': 'service' if is_service and is_sent else ('sent' if is_sent else 'received'),
            'amount': float(tx.amount),
            'party_name': tx.receiver.name if is_sent else tx.sender.name,
            'party_upi': tx.receiver.upi_id if is_sent else tx.sender.upi_id,
            'status': tx.status,
            'remark': tx.remark,
            'created_at': tx.created_at.isoformat(),
        })
    return JsonResponse({'transactions': items})
