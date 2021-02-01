# Build Container
FROM python:3.9-alpine

# Default Port 
EXPOSE 80

# Set Japanese
ENV LANG ja_JP.UTF-8

# Set Display Port To Avoid Crash
ENV DISPLAY=:99

# Install Packages & Fonts
RUN apk update && apk add --no-cache wget gnupg unzip chromium chromium-chromedriver fontconfig \
    && cd /usr/share/fonts \
    && wget -q --trust-server-names "https://ja.osdn.net/frs/redir.php?m=acc&f=ipafonts%2F51867%2Fipag00303.zip" \
    && unzip ipag00303.zip && mv ipag00303/*.ttf /usr/share/fonts && fc-cache -fv \
    && rm -f ipag00303.zip && rm -rf ipag00303 && apk del --purge wget unzip

COPY requirements.txt /

RUN pip3 install -r /requirements.txt

COPY ./app/ /opt/app/

WORKDIR /opt/app

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]