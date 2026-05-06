from django.urls import path
from .views import send_otp, pay, service_pay, transactions

urlpatterns = [
    path('otp/', send_otp),
    path('pay/', pay),
    path('service-pay/', service_pay),
    path('transactions/<int:user_id>/', transactions),
]
