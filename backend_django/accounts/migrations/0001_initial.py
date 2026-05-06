# Generated manually for the complete working banking demo
from django.db import migrations, models

class Migration(migrations.Migration):
    initial = True
    dependencies = []
    operations = [
        migrations.CreateModel(
            name='User',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('email', models.EmailField(max_length=254, unique=True)),
                ('password', models.CharField(max_length=128)),
                ('upi_id', models.CharField(blank=True, max_length=100, unique=True)),
                ('upi_pin', models.CharField(default='1234', max_length=128)),
                ('balance', models.DecimalField(decimal_places=2, default=5000, max_digits=12)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
            ],
        ),
    ]
