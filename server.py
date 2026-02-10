from flask import Flask, request, jsonify
from flask_cors import CORS
import subprocess
import os

app = Flask(__name__)
CORS(app)

BUCKET_NAME = "VarsitySportsLiveStreams"  

@app.post("/upload")
def upload():
    file = request.files.get("file")
    if not file:
        return jsonify({"message": "No file uploaded"}), 400

    filename = file.filename
    temp_path = f"temp_{filename}"
    file.save(temp_path)

    try:
        result = subprocess.run(
            ["b2", "upload-file", BUCKET_NAME, temp_path, filename],
            capture_output=True,
            text=True,
        )

        if result.returncode != 0:
            return jsonify({"message": result.stderr}), 500

        os.remove(temp_path)
        return jsonify({"message": "Upload successful"})

    except Exception as e:
        return jsonify({"message": str(e)}), 500

app.run(host="0.0.0.0", port=5000)