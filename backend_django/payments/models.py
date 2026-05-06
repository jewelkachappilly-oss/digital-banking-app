from django.db import models
from accounts.models import User


class Transaction(models.Model):
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent')
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received')
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    status = models.CharField(max_length=20, default='SUCCESS')
    remark = models.CharField(max_length=120, default='UPI Payment')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'{self.sender.upi_id} -> {self.receiver.upi_id}: ₹{self.amount}'


class OTP(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    code = models.CharField(max_length=6)
    is_used = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'OTP for {self.user.email}'
