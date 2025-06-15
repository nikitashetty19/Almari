# import os
# import sys
# import traceback
# from transformers import CLIPProcessor, CLIPModel
# from PIL import Image
# import torch

# DEVICE = "cuda" if torch.cuda.is_available() else "cpu"
# CLIP_MODEL_PATH = "MODELS/fashion-clip"

# # Load the CLIP model
# if os.path.exists(CLIP_MODEL_PATH):
#     print("Loading CLIP model...")
#     try:
#         clip_model = CLIPModel.from_pretrained(CLIP_MODEL_PATH).to(DEVICE)
#         clip_processor = CLIPProcessor.from_pretrained(CLIP_MODEL_PATH)
#         print("CLIP model loaded successfully")
#     except Exception as e:
#         print(f"Error loading CLIP model: {e}")
#         traceback.print_exc()
#         sys.exit(1)
# else:
#     print(f"CLIP model path not found: {CLIP_MODEL_PATH}")
#     sys.exit(1)

# # Load images
# def load_images_from_folder(folder_path):
#     images = []
#     paths = []
#     for filename in os.listdir(folder_path):
#         if filename.lower().endswith((".jpg", ".jpeg", ".png")):
#             full_path = os.path.join(folder_path, filename)
#             try:
#                 print(f"Processing image: {filename}")
#                 image = Image.open(full_path).convert("RGB")
#                 image = image.resize((224, 224))        
#                 images.append(image)
#                 paths.append(full_path)
#             except Exception as e:
#                 print(f"Failed to load image {full_path}: {e}")
#     return images, paths

# # Find best matching image
# def find_best_match(prompt, gender):
#     folder_path = gender.lower()  # expects 'men' or 'women' in same directory

#     if not os.path.exists(folder_path):
#         return {"error": f"Folder '{folder_path}' does not exist."}

#     images, image_paths = load_images_from_folder(folder_path)

#     if not images:
#         return {"error": "No images found."}

#     inputs = clip_processor(text=[prompt] * len(images), images=images, return_tensors="pt", padding=True)
#     inputs = {k: v.to(DEVICE) for k, v in inputs.items()}

#     with torch.no_grad():
#         outputs = clip_model(**inputs)
#         logits_per_image = outputs.logits_per_image
#         probs = logits_per_image.softmax(dim=0)[:, 0]

#     best_idx = torch.argmax(probs).item()
#     return {"best_match_path": image_paths[best_idx], "similarity_score": probs[best_idx].item()}

# # if __name__ == "__main__":
# #     prompt = 'white shirt blue pants'
# #     gender = 'women'

# #     result = find_best_match(prompt, gender)

# #     if "error" in result:
# #         print("Error:", result["error"])
# #     else:
# #         print(f"\nBest Match:\nPath: {result['best_match_path']}\nSimilarity: {result['similarity_score']:.4f}")


import os
import sys
import traceback
from transformers import CLIPProcessor, CLIPModel
from PIL import Image
import torch

DEVICE = "cuda" if torch.cuda.is_available() else "cpu"
CLIP_MODEL_PATH = "MODELS/fashion-clip"

# Load the CLIP model
if os.path.exists(CLIP_MODEL_PATH):
    print("Loading CLIP model...")
    try:
        clip_model = CLIPModel.from_pretrained(CLIP_MODEL_PATH).to(DEVICE)
        clip_processor = CLIPProcessor.from_pretrained(CLIP_MODEL_PATH)
        print("CLIP model loaded successfully")
    except Exception as e:
        print(f"Error loading CLIP model: {e}")
        traceback.print_exc()
        sys.exit(1)
else:
    print(f"CLIP model path not found: {CLIP_MODEL_PATH}")
    sys.exit(1)

# Load images
def load_images_from_folder(folder_path):
    images = []
    paths = []
    for filename in os.listdir(folder_path):
        if filename.lower().endswith((".jpg", ".jpeg", ".png")):
            full_path = os.path.join(folder_path, filename)
            try:
                print(f"Processing image: {filename}")
                image = Image.open(full_path).convert("RGB")
                # Resize to a smaller size before adding to list
                image = image.resize((512, 512))  # or even smaller like (256, 256)
                images.append(image)
                paths.append(full_path)
            except Exception as e:
                print(f"Failed to load image {full_path}: {e}")
    return images, paths

# Find best matching image
def find_best_match(prompt, gender):
    folder_path = gender.upper()  # expects 'men' or 'women' in same directory

    if not os.path.exists(folder_path):
        return {"error": f"Folder '{folder_path}' does not exist."}

    images, image_paths = load_images_from_folder(folder_path)

    if not images:
        return {"error": "No images found."}

    inputs = clip_processor(text=[prompt] * len(images), images=images, return_tensors="pt", padding=True)
    inputs = {k: v.to(DEVICE) for k, v in inputs.items()}

    with torch.no_grad():
        outputs = clip_model(**inputs)
        logits_per_image = outputs.logits_per_image
        probs = logits_per_image.softmax(dim=0)[:, 0]

    best_idx = torch.argmax(probs).item()
    return {"best_match_path": image_paths[best_idx], "similarity_score": probs[best_idx].item()}

# if __name__ == "__main__":
#     prompt = 'white shirt blue pants'
#     gender = 'women'

#     result = find_best_match(prompt, gender)

#     if "error" in result:
#         print("Error:", result["error"])
#     else:
#         print(f"\nBest Match:\nPath: {result['best_match_path']}\nSimilarity: {result['similarity_score']:.4f}")


