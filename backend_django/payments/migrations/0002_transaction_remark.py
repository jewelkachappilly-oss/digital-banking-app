from django.db import migrations, models

class Migration(migrations.Migration):
    dependencies = [('payments', '0001_initial')]
    operations = [
        migrations.AddField(
            model_name='transaction',
            name='remark',
            field=models.CharField(default='UPI Payment', max_length=120),
        ),
    ]
