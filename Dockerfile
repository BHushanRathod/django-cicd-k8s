FROM python:3.9.0

RUN pip install --upgrade pip
RUN pip install pipenv

WORKDIR /build

COPY Pipfile Pipfile.lock ./

ENV PYTHONUSERBASE /pyenv
ENV PATH /pyenv/bin:$PATH

ARG PIPENV_PYUP_API_KEY=
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

RUN PIP_USER=1 \
    PIP_IGNORE_INSTALLED=1 \
    pipenv install --system --deploy && \
    pipenv check --system


ENV PYTHONUSERBASE /pyenv
ENV PATH /pyenv/bin:$PATH

WORKDIR /code

COPY src/django-cbv ./django-cbv
COPY src/entrypoint.sh /code/entrypoint.sh
COPY src/manage.py .
COPY src/uwsgi.ini .
#COPY src/django-cbv/service/test/pytest.ini /code

RUN chmod a+x /code/entrypoint.sh

RUN python3 -m compileall -q ./django-cbv
#RUN python3 manage.py collectstatic --noinput

ENTRYPOINT ["/code/entrypoint.sh"]
CMD ["service"]
