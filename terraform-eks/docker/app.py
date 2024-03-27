from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello, Les amis today c est le 3/27/2024'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
