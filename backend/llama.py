
from groq import Groq

GROQ_API_KEY = ""

client = Groq(
    api_key = GROQ_API_KEY
)

def answer_query(query, liked_images,gender):
    prompt = f"""
    You are a fashion styling assistant. Your job is to provide *short, precise* outfit suggestions based on the user's liked outfits.
    
    *Users Gender*
    "{gender}"

    *User Query*
    "{query}"

    *Users Liked Outfits*
    {liked_images}

    *Instructions*
    1. Analyze the users liked outfits to understand their style.
    2. Recommend *one best outfit choice* based on the query.
    3. Keep the response *short and to the point* (1 sentences max).
    4. Avoid unnecessary explanations. Provide *only the recommended outfit* in a clear format.
    
    Now, provide your best recommendation:

 
    """

    chat_completion = client.chat.completions.create(

        messages=[
            {
                "role": "user",
                "content": prompt,
            }
        ],
        # model="llama3-8b-8192",
        model="llama-3.3-70b-versatile",
    )

    return chat_completion.choices[0].message.content
