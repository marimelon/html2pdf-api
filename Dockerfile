# Build Container
FROM python:3.9-slim-buster

# install packages
RUN apt-get update \
&& apt-get install -y --no-install-recommends wget gnupg unzip locales fonts-ipafont \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# install google chrome and chromedriver
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
&& sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' \
&& apt-get -y update && apt-get install -y google-chrome-stable \
\
&& wget -q -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/`wget -q -O - chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip \
&& unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/

# set display port to avoid crash
ENV DISPLAY=:99

# set japanese
RUN sed -i -E 's/# (ja_JP.UTF-8)/\1/' /etc/locale.gen && locale-gen
ENV LANG ja_JP.UTF-8

COPY requirements.txt /

RUN pip3 install -r /requirements.txt

COPY ./app/ /opt/app/

WORKDIR /opt/app

EXPOSE 80

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]