from fastapi import FastAPI, HTTPException, Response
from pydantic import BaseModel
import subprocess
import tempfile
import os

app = FastAPI()

class MermaidRequest(BaseModel):
    code: str
    width: int = 800
    height: int = 600  
    scale: float = 1.0

@app.post("/generate")
async def generate_diagram(req: MermaidRequest):
    puppeteer_config = "puppeteer-config.json"
    
    with tempfile.NamedTemporaryFile(suffix=".mmd", delete=False) as f_in, \
         tempfile.NamedTemporaryFile(suffix=".png", delete=False) as f_out:
        
        f_in.write(req.code.encode("utf-8"))
        f_in.flush()
        
        try:
            cmd = [
                "mmdc",
                "-i", f_in.name,           # Input flag + file
                "-o", f_out.name,          # Output flag + file  
                "-w", str(req.width),      # Width flag + value
                "-H", str(req.height),     # Height flag + value
                "-s", str(req.scale),      # Scale flag + value
                "-p", puppeteer_config     # Puppeteer config flag + file
            ]
            
            print(f"Running mmdc: {' '.join(cmd)}")  # Debug in Cloud Run logs
            
            result = subprocess.run(cmd, check=True, capture_output=True, text=True)
            
            with open(f_out.name, "rb") as img:
                img_data = img.read()
                
            return Response(content=img_data, media_type="image/png")
            
        except subprocess.CalledProcessError as e:
            print(f"mmdc stderr: {e.stderr}")  # Debug
            raise HTTPException(status_code=400, detail=f"mmdc failed: {e.stderr}")
        except FileNotFoundError:
            raise HTTPException(status_code=500, detail="mmdc command not found")
        finally:
            try:
                os.remove(f_in.name)
                os.remove(f_out.name)
            except OSError:
                pass
