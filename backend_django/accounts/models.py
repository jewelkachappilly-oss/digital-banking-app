from django.db import models
from django.contrib.auth.hashers import make_password, check_password
import random


def generate_upi(name: str):
    base = ''.join(ch for ch in name.lower().replace(' ', '') if ch.isalnum()) or 'user'
    return f"{base}{random.randint(1000,9999)}@bank"


class User(models.Model):
    name = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)
    upi_id = models.CharField(max_length=100, unique=True, blank=True)
    upi_pin = models.CharField(max_length=128, default='1234')
    balance = models.DecimalField(max_digits=12, decimal_places=2, default=5000)
    created_at = models.DateTimeField(auto_now_add=True)

    def set_password(self, raw_password: str):
        self.password = make_password(raw_password)

    def check_password(self, raw_password: str) -> bool:
        if self.password.startswith('pbkdf2_'):
            return check_password(raw_password, self.password)
        return self.password == raw_password

    def set_pin(self, raw_pin: str):
        self.upi_pin = make_password(raw_pin)

    def check_pin(self, raw_pin: str) -> bool:
        if self.upi_pin.startswith('pbkdf2_'):
            return check_password(raw_pin, self.upi_pin)
        return self.upi_pin == str(raw_pin)

    def save(self, *args, **kwargs):
        if not self.upi_id:
            upi = generate_upi(self.name)
            while User.objects.filter(upi_id=upi).exists():
                upi = generate_upi(self.name)
            self.upi_id = upi
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.name} ({self.upi_id})"
