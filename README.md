# html2pdf-api
This container runs a web service that converts Japanese HTML files to PDF using Chromium.

## Usage
### Build
    docker build -t html2pdf-api .
### Run
    docker run -it --rm -p 8000:80 html2pdf-api
### Convert file
    curl -F file=@filename http://127.0.0.1:8000 -o out.pdf
