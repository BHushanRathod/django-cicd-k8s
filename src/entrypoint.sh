#!/bin/sh

set -e

if [ "x$DJANGO_MANAGEPY_COLLECTSTATIC" = 'xon' ]; then
    python /code/manage.py collectstatic --noinput
fi

if [ "x$DJANGO_MANAGEPY_MIGRATE" = 'xon' ]; then
    echo "Apply database migrations"
    sleep 3
    python manage.py migrate --noinput
fi

if [ "$1" = "service" ]; then
#    exec uwsgi --py-autoreload 1 /docker/app/uwsgi.ini
    echo "Apply database migrations"
    sleep 3
    python manage.py migrate --noinput
    exec python manage.py runserver 0.0.0.0:8000
else
    exec uwsgi --ini /code/uwsgi.ini
fi
exec "$@"