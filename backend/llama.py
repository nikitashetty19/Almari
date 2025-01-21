from groq import Groq

GROQ_API_KEY = ""

client = Groq(
    api_key = GROQ_API_KEY
)

def answer_query(query):
    prompt = f"""{query}"""

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