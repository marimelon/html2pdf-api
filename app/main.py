import base64
import json
import shutil
import tempfile
from pathlib import Path

from fastapi import FastAPI, File, Response, UploadFile
from fastapi.responses import HTMLResponse
from selenium import webdriver

app = FastAPI(docs_url=None,redoc_url=None)

options = webdriver.ChromeOptions()
options.add_argument('--no-sandbox')
options.add_argument("--headless")
options.add_argument("--disable-gpu")

def send_devtools(driver, cmd, params={}):
    resource = f"/session/{driver.session_id}/chromium/send_command_and_get_result"
    url = driver.command_executor._url + resource
    body = json.dumps({'cmd': cmd, 'params': params})
    response = driver.command_executor._request('POST', url, body)
    return response.get('value')


def save_as_pdf(driver,  options={}):
    # https://timvdlippe.github.io/devtools-protocol/tot/Page#method-printToPDF
    if result := send_devtools(driver, "Page.printToPDF", options):
        return base64.b64decode(result['data'])
    else:
        return None


@app.get("/")
def read_root():
    content = """
    <!DOCTYPE html>
    <html>
    <body>
    <form ENCTYPE="multipart/form-data" method="post" action="/">
    <input name="file" type="file"/>
    <input type="submit" value="upload"/>
    </form>
    </body>
    </html>
    """
    return HTMLResponse(content=content)

driver = webdriver.Chrome(options=options)

@app.post("/")
def html2pdf(file: UploadFile = File(...)):
    with tempfile.NamedTemporaryFile(suffix='.html') as temp:
        shutil.copyfileobj(file.file, temp)
        temp.seek(0)

        driver.get(fr"file://{Path(temp.name).resolve()}")
        result = save_as_pdf(driver, {'landscape': False,'paperWidth':8.27,'paperHeight':11.69})

    if not result:
        return {"error":"Conversion failed."}

    return Response(content=result, media_type='application/pdf')