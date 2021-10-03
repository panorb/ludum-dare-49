
with open("input.txt", "r") as f:
    text = f.read()

# Remove all new lines
text = text.replace("\n", " ")
output_text = ""
words = text.split(" ")


for i in range(0, len(words), 2):
    output_text += words[i]

    if len(words) > i+1:
        output_text += " " + words[i+1]

    output_text += "\n\n"

with open("output.txt", "w+") as f:
    f.write(output_text)
