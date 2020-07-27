from flask import Flask, request, Response
import subprocess
import requests

app = Flask(__name__)


@app.route('/')
def a():
    sp_id = request.args.get("id")
    url = f"https://p.scdn.co/mp3-preview/{sp_id}"

    with requests.get(url) as g:
        print(g.status_code)
        pipe = subprocess.Popen(
            ["audiowaveform", "--input-format", "mp3", "--output-format",
             "json"],
            stdout=subprocess.PIPE, stdin=subprocess.PIPE,
            stderr=subprocess.STDOUT)

        stdout, error = pipe.communicate(input=g.content)

        stdout = b'{"' + stdout.split(b'{"')[1].split(B"Done")[0]

        return Response(stdout)


app.run("0.0.0.0", 3000)
