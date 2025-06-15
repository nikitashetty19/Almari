from flask import Flask, request, jsonify, send_file
from llama import answer_query
from outfit import find_best_match
import pandas as pd
import requests
from io import BytesIO
import os
import traceback
import logging

logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
app = Flask(__name__)
file_path = "C:/Users/User/Desktop/be proj/almari/backend/outfit_dataset.xlsx"

@app.route('/prompt', methods=['POST'])
def generate_prompt():
    try:
        data = request.get_json()
        query = data.get("query")
        liked_images_id = data.get("liked_images_id", [])
        gender = data.get("gender")

        if not query:
            return jsonify({"error": "Query is missing"}), 400

        liked_images = extract_liked_images(liked_images_id, gender)
        response = answer_query(query, liked_images, gender)

        return jsonify({"response": response}), 200

    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500
    
@app.route('/image', methods=['POST'])
def generate_image():
    try:
        data = request.get_json()
        prompt = data.get("prompt")
        gender = data.get("gender")

        if not prompt or not gender:
            return jsonify({"error": "Prompt and gender are required"}), 400

        clip_result = find_best_match(prompt, gender)
        if "best_match_path" in clip_result:
            best_image_path = clip_result["best_match_path"]
            logging.debug(f"Sending file from path: {best_image_path}")
            if not os.path.exists(best_image_path):
                raise FileNotFoundError(f"{best_image_path} does not exist")
            return send_file(best_image_path, mimetype='image/jpeg')


        diffusion_api_url = "https://6b4c-34-145-50-206.ngrok-free.app/generate"
        payload = {"prompt": prompt, "gender": gender}
        headers = {'Content-Type': 'application/json'}

        response = requests.post(diffusion_api_url, json=payload, headers=headers)
        if response.status_code != 200:
            return jsonify({"error": "Fallback Stable Diffusion also failed"}), 500

        return send_file(BytesIO(response.content), mimetype='image/png')

    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500



def extract_liked_images(liked_images_id, gender):
    liked_images_id = list(map(int, liked_images_id))
    df = pd.read_excel(file_path, sheet_name=gender)
    liked_images = df[df["id"].isin(liked_images_id)]
    return liked_images[["id", "top", "bottom", "category", "color", "season", "fit", "tags"]]

if __name__ == "__main__":
    app.run(host="0.0.0.0",port=5000, debug=False, use_reloader=False)

