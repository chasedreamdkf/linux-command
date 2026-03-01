import fastapi_cdn_host
from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from utils.parser import parserMarkdown
from utils.getCommandsList import get_commands_list


app = FastAPI()
fastapi_cdn_host.patch_docs(app)
@app.get('/commandslist')
async def get_commandslist():
    return {"commandslist": get_commands_list(comamnds_dir="../public/commands", cache_dir="./cache/")}
  
@app.get('/command/{cmd}')
async def command(cmd: str):
    html = parserMarkdown(cmd)
    return HTMLResponse(html)
