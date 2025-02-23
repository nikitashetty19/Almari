
from flask import Flask, request, jsonify
from llama import answer_query
import pandas as pd

app = Flask(__name__)

@app.route('/query', methods=['POST'])
def handle_query():
    try:
        data = request.get_json()
        query = data.get("query")
        liked_images_id = data.get("liked_images", [])

        liked_images = extract_liked_images(liked_images_id)

        if not query:
            return jsonify({"error": "Query is missing"}), 400

        response = answer_query(query, liked_images)

        return jsonify({"response": response}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

def extract_liked_images(liked_images_id):
    file_path = "outfit_dataset.xlsx"

    # liked_images_id = ["1", "2", "3", "4"]
    liked_images_id = list(map(int, liked_images_id))

    df = pd.read_excel(file_path)

    liked_images = df[df["id"].isin(liked_images_id)]
    liked_images = liked_images[["id", "top", "bottom", "category", "color", "season", "fit", "tags"]]

    return liked_images

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)