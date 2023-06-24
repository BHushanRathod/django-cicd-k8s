"""config URL Configuration
"""
from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path('admin/', admin.site.urls),
    path('auth/', include('django-cbv.auth.urls')),
    path('', include('django-cbv.app.urls')),
    # path('', include('django.contrib.auth.urls')),
]
