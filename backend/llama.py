
from groq import Groq

GROQ_API_KEY = "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"

client = Groq(
    api_key = GROQ_API_KEY
)

def answer_query(query, liked_images):
    prompt = f"""
    below given is the question asked by the user 
    {query}
    and these are the users liked outfit images data
    {liked_images}
    answer this by giving one single choice to the user 
    """

    chat_completion = client.chat.completions.create(

        messages=[
            {
                "role": "user",
                "content": prompt,
            }
        ],
        model="llama3-8b-8192",
    )

    return chat_completion.choices[0].message.content